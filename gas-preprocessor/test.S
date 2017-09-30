.macro m param
    .if \param
        .macro inner
            mov r0, #1
        .endm
    .else
        .macro inner
            mov r0, #0
        .endm
    .endif

    inner
    mov r1, #\param

    .purgem inner
.endm

m 1
m 0

.irpc i, 0123
    mov r1, #\i
    .iflt \i-2
        mov r2, #42
    .else
        mov r3, #42
    .endif
.endr

.irpc i, 01
    m \i
.endr

.macro outer
    .macro inner
        .if VAR1 > 10
            mov r4, #42
        .endif
    .endm

    .set VAR1, 5
    inner
    .set VAR1, 15
    inner
    .purgem inner
.endm

.if 2 > 1
    outer
.endif

.macro argtest1 first, second, third
    mov r0, #\first
    mov r0, #\second
    mov r0, #\third
.endm
.macro argtest2 first second third
    mov r1, #\first
    mov r1, #\second
    mov r1, #\third
.endm
# test for comma between macro name and first parameter
.macro argtest3, first, second, third
    mov r0, #\first
    mov r0, #\second
    mov r0, #\third
.endm

argtest1 1, 2, 3
argtest1 1 2 3
argtest2 1, 2, 3
argtest2 1 2 3
argtest1 1 2 3 + 1
argtest2 1 2 < 1 3
argtest3 1, 2, 3
argtest3 1 2 3
argtest3 1 2 6 / 2

.irpc i, 0123
    .irpc j, 0123
        mov r\i, #\j
    .endr
.endr

.macro alttest param
    .if param < 10
        mov r0, #param
    .endif
.endm

.altmacro
alttest 5
alttest 15
.noaltmacro
