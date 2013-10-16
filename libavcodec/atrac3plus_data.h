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

#ifndef AVCODEC_ATRAC3PLUS_DATA_H
#define AVCODEC_ATRAC3PLUS_DATA_H

#include <stdint.h>

/** VLC tables for wordlen */
extern const uint8_t ff_atrac3p_wl_huff_code1[3];
extern const uint8_t ff_atrac3p_wl_huff_bits1[3];
extern const uint8_t ff_atrac3p_wl_huff_xlat1[3];
extern const uint8_t ff_atrac3p_wl_huff_code2[5];
extern const uint8_t ff_atrac3p_wl_huff_bits2[5];
extern const uint8_t ff_atrac3p_wl_huff_xlat2[5];
extern const uint8_t ff_atrac3p_wl_huff_code3[8];
extern const uint8_t ff_atrac3p_wl_huff_bits3[8];
extern const uint8_t ff_atrac3p_wl_huff_code4[8];
extern const uint8_t ff_atrac3p_wl_huff_bits4[8];

/** VLC tables for scale factor indexes */
extern const uint16_t ff_atrac3p_sf_huff_code1[64];
extern const uint8_t  ff_atrac3p_sf_huff_bits1[64];
extern const uint8_t  ff_atrac3p_sf_huff_xlat1[64];
extern const uint8_t  ff_atrac3p_sf_huff_xlat2[64];
extern const uint16_t ff_atrac3p_sf_huff_code2[64];
extern const uint8_t  ff_atrac3p_sf_huff_bits2[64];
extern const uint16_t ff_atrac3p_sf_huff_code3[64];
extern const uint8_t  ff_atrac3p_sf_huff_bits3[64];
extern const uint8_t  ff_atrac3p_sf_huff_code4[16];
extern const uint8_t  ff_atrac3p_sf_huff_bits4[16];
extern const uint8_t  ff_atrac3p_sf_huff_xlat4[16];
extern const uint8_t  ff_atrac3p_sf_huff_xlat5[16];
extern const uint8_t  ff_atrac3p_sf_huff_code5[16];
extern const uint8_t  ff_atrac3p_sf_huff_bits5[16];
extern const uint8_t  ff_atrac3p_sf_huff_code6[16];
extern const uint8_t  ff_atrac3p_sf_huff_bits6[16];

/** VLC tables for code table indexes */
extern const uint8_t ff_atrac3p_ct_huff_code1[4];
extern const uint8_t ff_atrac3p_ct_huff_bits1[4];
extern const uint8_t ff_atrac3p_ct_huff_code2[8];
extern const uint8_t ff_atrac3p_ct_huff_bits2[8];
extern const uint8_t ff_atrac3p_ct_huff_xlat1[8];
extern const uint8_t ff_atrac3p_ct_huff_code3[8];
extern const uint8_t ff_atrac3p_ct_huff_bits3[8];

/** weights for quantized word lengths */
extern const int8_t ff_atrac3p_wl_weights[6][32];

/** weights for quantized scale factors */
extern const int8_t ff_atrac3p_sf_weights[2][32];

/** 3D base shape tables for word lengths. */
extern const int8_t ff_atrac3p_wl_shapes[8][16][9];

/** 2D base shape tables for scale factor coding. */
extern const int8_t ff_atrac3p_sf_shapes[64][9];

/** ungroup table for word length segments */
extern const uint8_t ff_atrac3p_qu_num_to_seg[32];

extern const uint16_t ff_atrac3p_qu_to_spec_pos[33];
extern const uint8_t ff_atrac3p_qu_to_subband[32];

extern const int ff_atrac3p_subband_to_num_powgrps[16];

extern const float ff_atrac3p_sf_tab[64];
extern const float ff_atrac3p_mant_tab[8];

extern const uint8_t ff_atrac3p_ct_restricted_to_full[2][7][4];

/** Tables for spectrum coding. */
typedef struct Atrac3pSpecCodeTab {
    uint8_t group_size;  ///< number of coefficients grouped together
    uint8_t num_coeffs;  ///< 1 - map index to a single value, > 1 - map index to a vector of values
    uint8_t bits;        ///< number of bits a single coefficient occupy
    uint8_t is_signed;   ///< 1 - values in that table are signed ones, otherwise - absolute ones

    int redirect;        ///< if >= 0: tells which huffman table must be reused
    const uint8_t *cb;   ///< pointer to the codebook descriptor
    const uint8_t *xlat; ///< pointer to the translation table or NULL if none
} Atrac3pSpecCodeTab;

extern const Atrac3pSpecCodeTab ff_atrac3p_spectra_tabs[112];

/* Huffman tables for gain control data. */
extern const uint8_t ff_atrac3p_huff_gain_npoints1_cb[9];
extern const uint8_t ff_atrac3p_huff_gain_npoints2_xlat[8];

extern const uint8_t ff_atrac3p_huff_gain_lev1_cb[9];
extern const uint8_t ff_atrac3p_huff_gain_lev1_xlat[16];
extern const uint8_t ff_atrac3p_huff_gain_lev2_cb[11];
extern const uint8_t ff_atrac3p_huff_gain_lev2_xlat[15];
extern const uint8_t ff_atrac3p_huff_gain_lev3_cb[11];
extern const uint8_t ff_atrac3p_huff_gain_lev3_xlat[16];
extern const uint8_t ff_atrac3p_huff_gain_lev4_cb[11];
extern const uint8_t ff_atrac3p_huff_gain_lev4_xlat[16];

extern const uint8_t ff_atrac3p_huff_gain_loc1_cb[9];
extern const uint8_t ff_atrac3p_huff_gain_loc1_xlat[31];
extern const uint8_t ff_atrac3p_huff_gain_loc2_cb[8];
extern const uint8_t ff_atrac3p_huff_gain_loc2_xlat[31];
extern const uint8_t ff_atrac3p_huff_gain_loc3_cb[7];
extern const uint8_t ff_atrac3p_huff_gain_loc3_xlat[32];
extern const uint8_t ff_atrac3p_huff_gain_loc4_cb[5];
extern const uint8_t ff_atrac3p_huff_gain_loc4_xlat[32];
extern const uint8_t ff_atrac3p_huff_gain_loc5_cb[9];
extern const uint8_t ff_atrac3p_huff_gain_loc5_xlat[32];

/* Huffman tables for GHA waves data. */
extern const uint8_t ff_atrac3p_huff_tonebands_cb[8];
extern const uint8_t ff_atrac3p_huff_numwavs1_cb[9];
extern const uint8_t ff_atrac3p_huff_numwavs2_cb[8];
extern const uint8_t ff_atrac3p_huff_numwavs2_xlat[8];
extern const uint8_t ff_atrac3p_huff_wav_ampsf1_cb[7];
extern const uint8_t ff_atrac3p_huff_wav_ampsf1_xlat[32];
extern const uint8_t ff_atrac3p_huff_wav_ampsf2_cb[7];
extern const uint8_t ff_atrac3p_huff_wav_ampsf2_xlat[32];
extern const uint8_t ff_atrac3p_huff_wav_ampsf3_cb[9];
extern const uint8_t ff_atrac3p_huff_wav_ampsf3_xlat[32];
extern const uint8_t ff_atrac3p_huff_freq_cb[13];
extern const uint8_t ff_atrac3p_huff_freq_xlat[256];

#endif /* AVCODEC_ATRAC3PLUS_DATA_H */
