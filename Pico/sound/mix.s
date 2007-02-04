@ vim:filetype=armasm

.global memcpy32 @ int *dest, int *src, int count

memcpy32:
    stmfd   sp!, {r4,lr}

    subs    r2, r2, #4
    bmi     mcp32_fin

mcp32_loop:
    ldmia   r1!, {r3,r4,r12,lr}
    subs    r2, r2, #4
    stmia   r0!, {r3,r4,r12,lr}
    bpl     mcp32_loop

mcp32_fin:
    tst     r2, #3
    ldmeqfd sp!, {r4,pc}
    tst     r2, #1
    ldrne   r3, [r1], #4
    strne   r3, [r0], #4

mcp32_no_unal1:
    tst     r2, #2
    ldmneia r1!, {r3,r12}
    ldmfd   sp!, {r4,lr}
    stmneia r0!, {r3,r12}
    bx      lr



.global memset32 @ int *dest, int c, int count

memset32:
    stmfd   sp!, {lr}

    mov     r3, r1
    subs    r2, r2, #4
    bmi     mst32_fin

    mov     r12,r1
    mov     lr, r1

mst32_loop:
    subs    r2, r2, #4
    stmia   r0!, {r1,r3,r12,lr}
    bpl     mst32_loop

mst32_fin:
    tst     r2, #1
    strne   r1, [r0], #4

    tst     r2, #2
    stmneia r0!, {r1,r3}

    ldmfd   sp!, {lr}
    bx      lr



@ this assumes src is word aligned
.global mix_16h_to_32 @ int *dest, short *src, int count

mix_16h_to_32:
    stmfd   sp!, {r4-r6,lr}
/*
    tst     r1, #2
    beq     m16_32_mo_unalw
    ldrsh   r4, [r1], #2
    ldr     r3, [r0]
    sub     r2, r2, #1
    add     r3, r3, r4, asr #1
    str     r3, [r0], #4
*/
m16_32_mo_unalw:
    subs    r2, r2, #4
    bmi     m16_32_end

m16_32_loop:
    ldmia   r0, {r3-r6}
    ldmia   r1!,{r12,lr}
    subs    r2, r2, #4
    add     r4, r4, r12,asr #17 @ we use half volume
    mov     r12,r12,lsl #16
    add     r3, r3, r12,asr #17
    add     r6, r6, lr, asr #17
    mov     lr, lr, lsl #16
    add     r5, r5, lr, asr #17
    stmia   r0!,{r3-r6}
    bpl     m16_32_loop

m16_32_end:
    tst     r2, #2
    beq     m16_32_no_unal2
    ldr     r5, [r1], #4
    ldmia   r0, {r3,r4}
    mov     r12,r5, lsl #16
    add     r3, r3, r12,asr #17
    add     r4, r4, r5, asr #17
    stmia   r0!,{r3,r4}

m16_32_no_unal2:
    tst     r2, #1
    ldmeqfd sp!, {r4-r6,pc}
    ldrsh   r4, [r1], #2
    ldr     r3, [r0]
    add     r3, r3, r4, asr #1
    str     r3, [r0], #4

    ldmfd   sp!, {r4-r6,lr}
    bx      lr



.global mix_16h_to_32_s1 @ int *dest, short *src, int count

mix_16h_to_32_s1:
    stmfd   sp!, {r4-r6,lr}

    subs    r2, r2, #4
    bmi     m16_32_s1_end

m16_32_s1_loop:
    ldmia   r0, {r3-r6}
    ldr     r12,[r1], #8
    ldr     lr, [r1], #8
    subs    r2, r2, #4
    add     r4, r4, r12,asr #17
    mov     r12,r12,lsl #16
    add     r3, r3, r12,asr #17 @ we use half volume
    add     r6, r6, lr, asr #17
    mov     lr, lr, lsl #16
    add     r5, r5, lr, asr #17
    stmia   r0!,{r3-r6}
    bpl     m16_32_s1_loop

m16_32_s1_end:
    tst     r2, #2
    beq     m16_32_s1_no_unal2
    ldr     r5, [r1], #8
    ldmia   r0, {r3,r4}
    mov     r12,r5, lsl #16
    add     r3, r3, r12,asr #17
    add     r4, r4, r5, asr #17
    stmia   r0!,{r3,r4}

m16_32_s1_no_unal2:
    tst     r2, #1
    ldmeqfd sp!, {r4-r6,pc}
    ldrsh   r4, [r1], #2
    ldr     r3, [r0]
    add     r3, r3, r4, asr #1
    str     r3, [r0], #4

    ldmfd   sp!, {r4-r6,lr}
    bx      lr



.global mix_16h_to_32_s2 @ int *dest, short *src, int count

mix_16h_to_32_s2:
    stmfd   sp!, {r4-r6,lr}

    subs    r2, r2, #4
    bmi     m16_32_s2_end

m16_32_s2_loop:
    ldmia   r0, {r3-r6}
    ldr     r12,[r1], #16
    ldr     lr, [r1], #16
    subs    r2, r2, #4
    add     r4, r4, r12,asr #17
    mov     r12,r12,lsl #16
    add     r3, r3, r12,asr #17 @ we use half volume
    add     r6, r6, lr, asr #17
    mov     lr, lr, lsl #16
    add     r5, r5, lr, asr #17
    stmia   r0!,{r3-r6}
    bpl     m16_32_s2_loop

m16_32_s2_end:
    tst     r2, #2
    beq     m16_32_s2_no_unal2
    ldr     r5, [r1], #16
    ldmia   r0, {r3,r4}
    mov     r12,r5, lsl #16
    add     r3, r3, r12,asr #17
    add     r4, r4, r5, asr #17
    stmia   r0!,{r3,r4}

m16_32_s2_no_unal2:
    tst     r2, #1
    ldmeqfd sp!, {r4-r6,pc}
    ldrsh   r4, [r1], #2
    ldr     r3, [r0]
    add     r3, r3, r4, asr #1
    str     r3, [r0], #4

    ldmfd   sp!, {r4-r6,lr}
    bx      lr



@ limit
@ reg=int_sample, lr=1, r3=tmp, kills flags
.macro Limit reg
    add     r3, lr, \reg, asr #16
    bics    r3, r3, #1			@ in non-overflow conditions r3 is 0 or 1
    movne   \reg, #0x8000
    submi   \reg, \reg, #1
.endm


@ limit and shift up by 16
@ reg=int_sample, lr=1, r3=tmp, kills flags
.macro Limitsh reg
@    movs    r4, r3, asr #16
@    cmnne   r4, #1
@    beq     c32_16_no_overflow
@    tst     r4, r4
@    mov     r3, #0x8000
@    subpl   r3, r3, #1

    add     r3, lr, \reg, asr #16
    bics    r3, r3, #1			@ in non-overflow conditions r3 is 0 or 1
    moveq   \reg, \reg, lsl #16
    movne   \reg, #0x80000000
    submi   \reg, \reg, #0x00010000
.endm


@ mix 32bit audio (with 16bits really used, upper bits indicate overflow) with normal 16 bit audio with left channel only
@ warning: this function assumes dest is word aligned
.global mix_32_to_16l_stereo @ short *dest, int *src, int count

mix_32_to_16l_stereo:
    stmfd   sp!, {r4-r8,lr}

    mov     lr, #1

    mov     r2, r2, lsl #1
    subs    r2, r2, #4
    bmi     m32_16l_st_end

m32_16l_st_loop:
    ldmia   r0,  {r8,r12}
    ldmia   r1!, {r4-r7}
    mov     r8, r8, lsl #16
    mov     r12,r12,lsl #16
    add     r4, r4, r8, asr #16
    add     r5, r5, r8, asr #16
    add     r6, r6, r12,asr #16
    add     r7, r7, r12,asr #16
    Limitsh r4
    Limitsh r5
    Limitsh r6
    Limitsh r7
    subs    r2, r2, #4
    orr     r4, r5, r4, lsr #16
    orr     r5, r7, r6, lsr #16
    stmia   r0!, {r4,r5}
    bpl     m32_16l_st_loop

m32_16l_st_end:
    @ check for remaining bytes to convert
    tst     r2, #2
    beq     m32_16l_st_no_unal2
    ldrsh   r6, [r0]
    ldmia   r1!,{r4,r5}
    add     r4, r4, r6
    add     r5, r5, r6
    Limitsh r4
    Limitsh r5
    orr     r4, r5, r4, lsr #16
    str     r4, [r0], #4

m32_16l_st_no_unal2:
    ldmfd   sp!, {r4-r8,lr}
    bx      lr


@ mix 32bit audio (with 16bits really used, upper bits indicate overflow) with normal 16 bit audio (for mono sound)
.global mix_32_to_16_mono @ short *dest, int *src, int count

mix_32_to_16_mono:
    stmfd   sp!, {r4-r8,lr}

    mov     lr, #1

    @ check if dest is word aligned
    tst     r0, #2
    beq     m32_16_mo_no_unalw
    ldrsh   r5, [r0], #2
    ldr     r4, [r1], #4
    sub     r2, r2, #1
    add     r4, r4, r5
    Limit   r4
    strh    r4, [r0], #2

m32_16_mo_no_unalw:
    subs    r2, r2, #4
    bmi     m32_16_mo_end

m32_16_mo_loop:
    ldmia   r0,  {r8,r12}
    ldmia   r1!, {r4-r7}
    add     r5, r5, r8, asr #16
    mov     r8, r8, lsl #16
    add     r4, r4, r8, asr #16
    add     r7, r7, r12,asr #16
    mov     r12,r12,lsl #16
    add     r6, r6, r12,asr #16
    Limitsh r4
    Limitsh r5
    Limitsh r6
    Limitsh r7
    subs    r2, r2, #4
    orr     r4, r5, r4, lsr #16
    orr     r5, r7, r6, lsr #16
    stmia   r0!, {r4,r5}
    bpl     m32_16_mo_loop

m32_16_mo_end:
    @ check for remaining bytes to convert
    tst     r2, #2
    beq     m32_16_mo_no_unal2
    ldr     r6, [r0]
    ldmia   r1!,{r4,r5}
    add     r5, r5, r6, asr #16
    mov     r6, r6, lsl #16
    add     r4, r4, r6, asr #16
    Limitsh r4
    Limitsh r5
    orr     r4, r5, r4, lsr #16
    str     r4, [r0], #4

m32_16_mo_no_unal2:
    tst     r2, #1
    ldmeqfd sp!, {r4-r8,pc}
    ldrsh   r5, [r0], #2
    ldr     r4, [r1], #4
    add     r4, r4, r5
    Limit   r4
    strh    r4, [r0], #2

    ldmfd   sp!, {r4-r8,lr}
    bx      lr

