; Definition of tracing macro, will be a noop unless -DTRACE is passed to the assembler

TRACELOC MACRO LOCID
    IFDEF TRACE
    ; Save registers
    php
    phx
    phy
    pha
    lda LOCID
    stz TRACEID
    stz TRACEID+1
    sta TRACEID
    SEVENSEG_DISPLAY_VALUE TRACEID
; Run the CPU for 65 thousand cycles, simple delay. 
    ldx #$FF
LAB#
    dex
    beq RET#
    ldy #$FF
LAB2#
    dey
    beq LAB#
    jmp LAB2#
RET#
    ; restore registers
    pla
    ply
    plx
    plp 
    ELSE
    nop
    ENDIF
    ENDM
