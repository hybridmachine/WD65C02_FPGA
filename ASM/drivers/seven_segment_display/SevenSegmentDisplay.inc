;***************************************************************************
;                              Global Modules
;***************************************************************************
        XREF SUB_SEVENSEG_DISPLAY_VALUE
        XREF SUB_SEVENSEG_DISABLE

;***************************************************************************
;                             Macros
;***************************************************************************
SEVENSEG_DISPLAY_VALUE MACRO SOURCE
        ; Put lower 16 timer bits (hi byte first) onto stack then call display code
        lda SOURCE+1
        pha
        lda SOURCE
        pha
        jsr SUB_SEVENSEG_DISPLAY_VALUE
        ; Cleanup stack
        pla 
        pla
        ENDM