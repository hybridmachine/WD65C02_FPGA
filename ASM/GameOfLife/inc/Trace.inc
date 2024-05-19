; Definition of tracing macro, will be a noop unless -DTRACE is passed to the assembler

SAVE_REGS MACRO
    php
    phx
    phy
    pha
    ENDM

; Assumes caller first used SAVE_REGS
RESTORE_REGS MACRO
    pla
    ply
    plx
    plp
    ENDM

TRACELOC MACRO LOCID1,LOCID2
    IFDEF TRACE

    SAVE_REGS

    stz TRACEID
    stz TRACEID+1

    lda LOCID1
    sta TRACEID
    
    lda LOCID2
    sta TRACEID+1
    
    SEVENSEG_DISPLAY_VALUE TRACEID
    
    RESTORE_REGS 
    
    ELSE
    ; Do nothing
    nop
    
    ENDIF
    ENDM

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
