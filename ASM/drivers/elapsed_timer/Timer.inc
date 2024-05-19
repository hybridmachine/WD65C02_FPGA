;***************************************************************************
;                              Global Modules
;***************************************************************************
        XREF SUB_TIMER_START
        XREF SUB_TIMER_READ
        XREF SUB_TIMER_RESET

; Macro definitions for calling the elapsed timer driver methods
TIMER_READ MACRO DEST
    lda #0
    pha   
    pha
    pha
    pha
    jsr SUB_TIMER_READ
    pla
    sta DEST
    pla
    sta DEST+1
    pla
    sta DEST+2
    pla
    sta DEST+3
    ENDM
