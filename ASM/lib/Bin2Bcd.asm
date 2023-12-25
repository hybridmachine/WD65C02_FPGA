; Multiply, adapted from the 65xx programmers reference
; result: returned in X - Y (hi - lo)
; All registers are overwritten , caller must save before call

    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    GLOBAL BINTOBCD
    GLOBAL BCDVAL
CODE
    ; Assumes single byte to convert in A register
    BINTOBCD:
    BCDVAL:             equ     $04  ; 16 bits 04 and 05 to hold 4 BCD digits (max 9999)
        PHA ; Save off A
        ; Zero out BCDVAL for new calculation
        LDA #0
        STA BCDVAL
        STA BCDVAL+1
        PLA ; Reload with original value
    CONVERT2BCD:
        CMP #9
        BCS ADD9TOBCD; A is higher than 9
        ; A is equal to or less than 9
        SED ; Decimal mode
        CLC ; Clear any latent carry flag
        ADC BCDVAL ; Add what remains in A to BCDVAL
        STA BCDVAL
        LDA #0
        ADC BCDVAL+1 ; Add carry bit if any
        STA BCDVAL+1
        CLD ; Return to normal mode
        RTS ; A is drained
    ADD9TOBCD:
        PHA ; Save original value of A   
        SED ; Decimal mode
        CLC ; Clear any latent carry flag
        LDA BCDVAL
        ADC #9
        STA BCDVAL
        LDA BCDVAL+1
        ADC #0 ; Carry bit only
        STA BCDVAL+1
        CLD ; Normal mode
        PLA ; Restore A
        SEC
        SBC #9 ; Remove 9
        JMP CONVERT2BCD ; Loop
