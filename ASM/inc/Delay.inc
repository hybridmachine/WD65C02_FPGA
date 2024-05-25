DELAY_LOOP MACRO COUNT
; Does not preserve X,Y, users should preserve as needed
; Run the CPU for COUNT**2 cycles, simple delay. 
    ldx COUNT
LAB#
    dex
    beq RET#
    ldy COUNT
LAB2#
    dey
    beq LAB#
    jmp LAB2#
RET#
    ENDM