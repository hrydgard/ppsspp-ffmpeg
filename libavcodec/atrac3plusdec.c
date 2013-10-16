/*
 * ATRAC3+ compatible decoder
 *
 * Copyright (c) 2010-2013 Maxim Poliakovski
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/**
 * @file
 * Sony ATRAC3+ compatible decoder.
 *
 * Container formats used to store its data:
 * RIFF WAV (.at3) and Sony OpenMG (.oma, .aa3).
 *
 * Technical description of this codec can be found here:
 * http://wiki.multimedia.cx/index.php?title=ATRAC3plus
 *
 * Kudos to Benjamin Larsson and Michael Karcher
 * for their precious technical help!
 */

#include <stdint.h>
#include <string.h>

#include "libavutil/channel_layout.h"
#include "avcodec.h"
#include "get_bits.h"
#include "internal.h"
#include "atrac.h"
#include "atrac3plus.h"
#include "atrac3plus_data.h"

typedef struct ATRAC3PContext {
    GetBitContext gb;

    DECLARE_ALIGNED(32, float, samples)[2][ATRAC3P_FRAME_SAMPLES];  ///< quantized MDCT spectrum
    DECLARE_ALIGNED(32, float, mdct_buf)[2][ATRAC3P_FRAME_SAMPLES]; ///< output of the IMDCT
    DECLARE_ALIGNED(32, float, time_buf)[2][ATRAC3P_FRAME_SAMPLES]; ///< output of the gain compensation
    DECLARE_ALIGNED(32, float, outp_buf)[2][ATRAC3P_FRAME_SAMPLES];

    AtracGCContext gainc_ctx;   ///< gain compensation context
    FFTContext mdct_ctx;
    FFTContext ipqf_dct_ctx;    ///< IDCT context used by IPQF

    Atrac3pChanUnitCtx *ch_units;   ///< global channel units

    int num_channel_blocks;     ///< number of channel blocks
    uint8_t channel_blocks[5];  ///< channel configuration descriptor
    uint64_t my_channel_layout; ///< current channel layout

    ATRAC3PVlcTabs glob_vlcs;   ///< global VLC tables
} ATRAC3PContext;

static av_cold int set_channel_params(ATRAC3PContext *ctx,
                                      AVCodecContext *avctx)
{
    memset(ctx->channel_blocks, 0, sizeof(ctx->channel_blocks));

    switch (avctx->channel_layout) {
    case AV_CH_LAYOUT_MONO:
        ctx->num_channel_blocks = 1;
        ctx->channel_blocks[0]  = CH_UNIT_MONO;
        break;
    case AV_CH_LAYOUT_STEREO:
        ctx->num_channel_blocks = 1;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        break;
    case AV_CH_LAYOUT_SURROUND:
        ctx->num_channel_blocks = 2;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        ctx->channel_blocks[1]  = CH_UNIT_MONO;
        break;
    case AV_CH_LAYOUT_4POINT0:
        ctx->num_channel_blocks = 3;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        ctx->channel_blocks[1]  = CH_UNIT_MONO;
        ctx->channel_blocks[2]  = CH_UNIT_MONO;
        break;
    case AV_CH_LAYOUT_5POINT1_BACK:
        ctx->num_channel_blocks = 4;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        ctx->channel_blocks[1]  = CH_UNIT_MONO;
        ctx->channel_blocks[2]  = CH_UNIT_STEREO;
        ctx->channel_blocks[3]  = CH_UNIT_MONO;
        break;
    case AV_CH_LAYOUT_6POINT1_BACK:
        ctx->num_channel_blocks = 5;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        ctx->channel_blocks[1]  = CH_UNIT_MONO;
        ctx->channel_blocks[2]  = CH_UNIT_STEREO;
        ctx->channel_blocks[3]  = CH_UNIT_MONO;
        ctx->channel_blocks[4]  = CH_UNIT_MONO;
        break;
    case AV_CH_LAYOUT_7POINT1:
        ctx->num_channel_blocks = 5;
        ctx->channel_blocks[0]  = CH_UNIT_STEREO;
        ctx->channel_blocks[1]  = CH_UNIT_MONO;
        ctx->channel_blocks[2]  = CH_UNIT_STEREO;
        ctx->channel_blocks[3]  = CH_UNIT_STEREO;
        ctx->channel_blocks[4]  = CH_UNIT_MONO;
        break;
    default:
        av_log(avctx, AV_LOG_ERROR,
               "Unsupported channel layout: %"PRIx64"!\n", avctx->channel_layout);
        return AVERROR_INVALIDDATA;
    }

    return 0;
}

static av_cold int decode_init(AVCodecContext *avctx)
{
    ATRAC3PContext *ctx = avctx->priv_data;
    int i, ch, ret;

    ff_atrac3p_init_vlcs(&ctx->glob_vlcs);

    /* initialize IPQF */
    ff_mdct_init(&ctx->ipqf_dct_ctx, 5, 1, 32.0 / 32768.0);

    ff_atrac3p_init_imdct(avctx, &ctx->mdct_ctx);

    ff_atrac_init_gain_compensation(&ctx->gainc_ctx, 6, 2);

    ff_atrac3p_init_wave_synth();

    if ((ret = set_channel_params(ctx, avctx)) < 0)
        return ret;

    ctx->my_channel_layout = avctx->channel_layout;

    ctx->ch_units = av_mallocz(sizeof(*ctx->ch_units) *
                               ctx->num_channel_blocks);
    if (!ctx->ch_units)
        return AVERROR(ENOMEM);

    for (i = 0; i < ctx->num_channel_blocks; i++) {
        for (ch = 0; ch < 2; ch++) {
            ctx->ch_units[i].channels[ch].ch_num          = ch;
            ctx->ch_units[i].channels[ch].wnd_shape       = &ctx->ch_units[1].channels[ch].wnd_shape_hist[0][0];
            ctx->ch_units[i].channels[ch].wnd_shape_prev  = &ctx->ch_units[i].channels[ch].wnd_shape_hist[1][0];
            ctx->ch_units[i].channels[ch].gain_data       = &ctx->ch_units[i].channels[ch].gain_data_hist[0][0];
            ctx->ch_units[i].channels[ch].gain_data_prev  = &ctx->ch_units[i].channels[ch].gain_data_hist[1][0];
            ctx->ch_units[i].channels[ch].tones_info      = &ctx->ch_units[i].channels[ch].tones_info_hist[0][0];
            ctx->ch_units[i].channels[ch].tones_info_prev = &ctx->ch_units[i].channels[ch].tones_info_hist[1][0];

            /* clear IMDCT overlapping buffer */
            memset(&ctx->ch_units[i].prev_buf[ch][0], 0,
                   sizeof(ctx->ch_units[i].prev_buf[ch][0]) *
                   ATRAC3P_FRAME_SAMPLES);
            /* clear IPQF history */
            memset(&ctx->ch_units[i].ipqf_ctx[ch], 0,
                   sizeof(ctx->ch_units[i].ipqf_ctx[ch]));
        }

        ctx->ch_units[i].waves_info      = &ctx->ch_units[i].wave_synth_hist[0];
        ctx->ch_units[i].waves_info_prev = &ctx->ch_units[i].wave_synth_hist[1];
    }

    avctx->sample_fmt = AV_SAMPLE_FMT_FLTP;

    return 0;
}

static void decode_residual_spectrum(Atrac3pChanUnitCtx *ctx,
                                     float out[2][ATRAC3P_FRAME_SAMPLES],
                                     int num_channels,
                                     AVCodecContext *avctx)
{
    int i, sb, ch, qu, nspeclines, RNG_index;
    DECLARE_ALIGNED(32, float, tmp)[ATRAC3P_SUBBAND_SAMPLES];
    float *dst, q;
    int16_t *src;
    /* calculate RNG table index for each subband */
    int sb_RNG_index[ATRAC3P_SUBBANDS] = { 0 };

    for (qu = 0, RNG_index = 0; qu < ctx->used_quant_units; qu++)
        RNG_index += ctx->channels[0].qu_sf_idx[qu] +
                     ctx->channels[1].qu_sf_idx[qu];

    for (sb = 0; sb < ctx->num_coded_subbands; sb++, RNG_index += 128)
        sb_RNG_index[sb] = RNG_index & 0x3FC;

    /* inverse quant and power compensation */
    for (ch = 0; ch < num_channels; ch++) {
        /* clear channel's residual spectrum */
        memset(out[ch], 0, ATRAC3P_FRAME_SAMPLES * sizeof(*out[ch]));

        for (qu = 0; qu < ctx->used_quant_units; qu++) {
            src        = &ctx->channels[ch].spectrum[ff_atrac3p_qu_to_spec_pos[qu]];
            dst        = &out[ch][ff_atrac3p_qu_to_spec_pos[qu]];
            nspeclines = ff_atrac3p_qu_to_spec_pos[qu + 1] -
                         ff_atrac3p_qu_to_spec_pos[qu];

            if (ctx->channels[ch].qu_wordlen[qu] > 0) {
                q = ff_atrac3p_sf_tab[ctx->channels[ch].qu_sf_idx[qu]] *
                    ff_atrac3p_mant_tab[ctx->channels[ch].qu_wordlen[qu]];
                for (i = 0; i < nspeclines; i++)
                    dst[i] = src[i] * q;
            }
        }

        for (sb = 0; sb < ctx->num_coded_subbands; sb++)
            ff_atrac3p_power_compensation(ctx, ch, &out[ch][0],
                                          sb_RNG_index[sb], sb);
    }

    if (ctx->unit_type == CH_UNIT_STEREO) {
        for (sb = 0; sb < ctx->num_coded_subbands; sb++) {
            if (ctx->swap_channels[sb]) {
                memcpy(tmp, &out[0][sb * ATRAC3P_SUBBAND_SAMPLES],
                       ATRAC3P_SUBBAND_SAMPLES * sizeof(*tmp));
                memcpy(&out[0][sb * ATRAC3P_SUBBAND_SAMPLES],
                       &out[1][sb * ATRAC3P_SUBBAND_SAMPLES],
                       ATRAC3P_SUBBAND_SAMPLES *
                       sizeof(out[0][sb * ATRAC3P_SUBBAND_SAMPLES]));
                memcpy(&out[1][sb * ATRAC3P_SUBBAND_SAMPLES], tmp,
                       ATRAC3P_SUBBAND_SAMPLES *
                       sizeof(out[1][sb * ATRAC3P_SUBBAND_SAMPLES]));
            }

            /* flip coefficients' sign if requested */
            if (ctx->negate_coeffs[sb])
                for (i = 0; i < ATRAC3P_SUBBAND_SAMPLES; i++)
                    out[1][sb * ATRAC3P_SUBBAND_SAMPLES + i] = -(out[1][sb * ATRAC3P_SUBBAND_SAMPLES + i]);
        }
    }

    if (ctx->mute_flag)
        for (ch = 0; ch < num_channels; ch++)
            memset(out[ch], 0, ATRAC3P_FRAME_SAMPLES * sizeof(*out[ch]));
}

static void reconstruct_frame(ATRAC3PContext *ctx, Atrac3pChanUnitCtx *ch_unit,
                              int num_channels, AVCodecContext *avctx)
{
    int ch, sb;

    for (ch = 0; ch < num_channels; ch++) {
        for (sb = 0; sb < ch_unit->num_subbands; sb++) {
            /* inverse transform and windowing */
            ff_atrac3p_imdct(&ctx->mdct_ctx,
                             &ctx->samples[ch][sb * ATRAC3P_SUBBAND_SAMPLES],
                             &ctx->mdct_buf[ch][sb * ATRAC3P_SUBBAND_SAMPLES],
                             (ch_unit->channels[ch].wnd_shape_prev[sb] << 1) +
                             ch_unit->channels[ch].wnd_shape[sb], sb);

            /* gain compensation and overlapping */
            ff_atrac_gain_compensation(&ctx->gainc_ctx,
                                       &ctx->mdct_buf[ch][sb * ATRAC3P_SUBBAND_SAMPLES],
                                       &ch_unit->prev_buf[ch][sb * ATRAC3P_SUBBAND_SAMPLES],
                                       &ch_unit->channels[ch].gain_data_prev[sb],
                                       &ch_unit->channels[ch].gain_data[sb],
                                       ATRAC3P_SUBBAND_SAMPLES,
                                       &ctx->time_buf[ch][sb * ATRAC3P_SUBBAND_SAMPLES]);
        }

        /* zero unused subbands in both output and overlapping buffers */
        memset(&ch_unit->prev_buf[ch][ch_unit->num_subbands * ATRAC3P_SUBBAND_SAMPLES],
               0,
               (ATRAC3P_SUBBANDS - ch_unit->num_subbands) *
               ATRAC3P_SUBBAND_SAMPLES *
               sizeof(ch_unit->prev_buf[ch][ch_unit->num_subbands * ATRAC3P_SUBBAND_SAMPLES]));
        memset(&ctx->time_buf[ch][ch_unit->num_subbands * ATRAC3P_SUBBAND_SAMPLES],
               0,
               (ATRAC3P_SUBBANDS - ch_unit->num_subbands) *
               ATRAC3P_SUBBAND_SAMPLES *
               sizeof(ctx->time_buf[ch][ch_unit->num_subbands * ATRAC3P_SUBBAND_SAMPLES]));

        /* resynthesize and add tonal signal */
        if (ch_unit->waves_info->tones_present ||
            ch_unit->waves_info_prev->tones_present) {
            for (sb = 0; sb < ch_unit->num_subbands; sb++)
                if (ch_unit->channels[ch].tones_info[sb].num_wavs ||
                    ch_unit->channels[ch].tones_info_prev[sb].num_wavs) {
                    ff_atrac3p_generate_tones(ch_unit, ch, sb,
                                              &ctx->time_buf[ch][sb * 128]);
                }
        }

        /* subband synthesis and acoustic signal output */
        ff_atrac3p_ipqf(&ctx->ipqf_dct_ctx, &ch_unit->ipqf_ctx[ch],
                        &ctx->time_buf[ch][0], &ctx->outp_buf[ch][0]);
    }

    /* swap window shape and gain control buffers. */
    for (ch = 0; ch < num_channels; ch++) {
        FFSWAP(uint8_t *, ch_unit->channels[ch].wnd_shape,
               ch_unit->channels[ch].wnd_shape_prev);
        FFSWAP(AtracGainInfo *, ch_unit->channels[ch].gain_data,
               ch_unit->channels[ch].gain_data_prev);
        FFSWAP(Atrac3pWavesData *, ch_unit->channels[ch].tones_info,
               ch_unit->channels[ch].tones_info_prev);
    }

    FFSWAP(Atrac3pWaveSynthParams *, ch_unit->waves_info, ch_unit->waves_info_prev);
}

static int decode_frame(AVCodecContext *avctx, void *data,
                        int *got_frame_ptr, AVPacket *avpkt)
{
    const uint8_t *buf  = avpkt->data;
    int buf_size        = avpkt->size;
    ATRAC3PContext *ctx = avctx->priv_data;
    AVFrame *frame      = data;
    int i, ret, ch_unit_id, ch_block = 0, out_ch_index = 0, channels_to_process;
    float **samples_p = (float **)frame->extended_data;

    frame->nb_samples = ATRAC3P_FRAME_SAMPLES;
    if ((ret = ff_get_buffer(avctx, frame, 0)) < 0) {
        av_log(avctx, AV_LOG_ERROR, "get_buffer() failed\n");
        return ret;
    }

    init_get_bits(&ctx->gb, buf, buf_size * 8);

    if (get_bits1(&ctx->gb)) {
        av_log(avctx, AV_LOG_ERROR, "Invalid start bit!\n");
        return AVERROR_INVALIDDATA;
    }

    while ((ch_unit_id = get_bits(&ctx->gb, 2)) != CH_UNIT_TERMINATOR) {
        if (ch_unit_id == CH_UNIT_EXTENSION) {
            avpriv_report_missing_feature(avctx, "Channel unit extension");
            return AVERROR_PATCHWELCOME;
        }
        if (ch_block >= ctx->num_channel_blocks ||
            ctx->channel_blocks[ch_block] != ch_unit_id) {
            av_log(avctx, AV_LOG_ERROR,
                   "Frame data doesn't match channel configuration!\n");
            return AVERROR_INVALIDDATA;
        }

        ctx->ch_units[ch_block].unit_type = ch_unit_id;
        channels_to_process               = ch_unit_id + 1;

        if ((ret = ff_atrac3p_decode_channel_unit(&ctx->gb,
                                                  &ctx->ch_units[ch_block],
                                                  channels_to_process,
                                                  &ctx->glob_vlcs, avctx)) < 0)
            return ret;

        decode_residual_spectrum(&ctx->ch_units[ch_block], ctx->samples,
                                 channels_to_process, avctx);
        reconstruct_frame(ctx, &ctx->ch_units[ch_block],
                          channels_to_process, avctx);

        for (i = 0; i < channels_to_process; i++)
            memcpy(samples_p[out_ch_index + i], ctx->outp_buf[i],
                   ATRAC3P_FRAME_SAMPLES * sizeof(**samples_p));

        ch_block++;
        out_ch_index += channels_to_process;
    }

    *got_frame_ptr = 1;

    return avctx->block_align;
}

static av_cold int decode_close(AVCodecContext *avctx)
{
    ATRAC3PContext *ctx = avctx->priv_data;

    ff_atrac3p_free_vlcs(&ctx->glob_vlcs);

    return 0;
}

AVCodec ff_atrac3p_decoder = {
    .name           = "atrac3plus",
    .long_name      = NULL_IF_CONFIG_SMALL("ATRAC3+ (Adaptive TRansform Acoustic Coding 3+)"),
    .type           = AVMEDIA_TYPE_AUDIO,
    .id             = AV_CODEC_ID_ATRAC3P,
    .priv_data_size = sizeof(ATRAC3PContext),
    .init           = decode_init,
    .close          = decode_close,
    .decode         = decode_frame,
};
