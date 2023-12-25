;***************************************************************************
;  FILE_NAME: Bin2Bcd.asm
;
;	Copyright (c) 2023 Brian Tabone
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;
;  DESCRIPTION: Binary to BCD conversion routine
;
;
;***************************************************************************    

; Binary to BCD conversion routine. Converts a single byte in the A register to 4 BCD digits in BCDVAL and BCDVAL+1

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
