; Multiply, adapted from the 65xx programmers reference
; result: returned in X - Y (hi - lo)
; All registers are overwritten , caller must save before call

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF
    org $FD1B   ; Must Come after main code

    GLOBAL MULT
    GLOBAL MCAND1
    GLOBAL MCAND2

    MULT:
    MCAND1:  GEQU    $80
    MCAND2:  GEQU    $82

        LDX #$0
        LDY #$0

    MULT1:

        LDA MCAND1
        ORA MCAND1+1
        BEQ DONE
        LSR MCAND1+1
        ROR MCAND1
        BCC MULT2
        CLC
        TYA
        ADC MCAND2
        TAY
        TXA
        ADC MCAND2+1
        TAX

    MULT2:

        ASL MCAND2
        ROL MCAND2+1
        JMP MULT1
    
    DONE:
        RTS
END ; CODE