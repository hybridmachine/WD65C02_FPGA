         

; Adapted from 65C02 programmers ref
; 16 divided by 16 =  16 divide for 6502 microprocessor
; divide DIVDND  / DIVSOR -> XA (hi-lo); remainder  in DIVDND
; DIVDND and  DIVSOR are direct page double byte cells
; no  special handling for divide by zero  (returns $FFFF quotient)
CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF
    org $FD3C   ; Place after multiply

    GLOBAL DIV
    GLOBAL DIVDND
    GLOBAL DIVSOR

    DIV:     
    DIVDND:   GEQU   $80
    DIVSOR:   GEQU   $82

    LDA    #0
    TAX                    initialize quotient  (hi)
    PHA                    initialize quotient  (lo)
    LDY    #1              initialize shift count  =1
    LDA    DIVSOR          get high byte of divisor
    BMI    DIV2            bra if divisor  can't be shifted left
    DIV1:   INY                  else shift divisor to leftmost position
            ASL  DIVSOR
            ROL  DIVSOR+1        test divisor
            BMI  DIV2            done if divisor in leftmost position 
            CPY  #17             max count (all zeroes in divisor) 
            BNE  DIV1            loop if not done
    
    DIV2:   SEC                  now do division by subtraction 
            LDA  DIVDND          subtract divisor from dividend 
            SBC  DIVSOR          low bytes first
            PHA                  save lo difference temporarily on stack 
            LDA  DIVDND+1        then subtract high bytes
            SBC  DIVSOR+1
            BCC  DIV3            bra if can't subtract divisor from dividend
    ; else carry is set to shift into quotient
            STA  DIVDND+1        store high byte of difference
            PLA                  get low subtract result from stack
            STA  DIVDND 
            PHA                  restore low subtract result->stack for pull 
    DIV3:   PLA                      throw away low subtract result
            PLA                  get quotient low byte from stack
            ROL A                shift carry->quotient (1 for divide, 0 for not) 
            PHA                  put back on stack
            TXA                  get quotient high byte
            ROL A                continue shift->quotient (high)
            TAX                  put back in x
            LSR  DIVSOR+1        shift divisor right for next subtract
            ROR  DIVSOR
            DEY                  decrement count
            BNE  DIV2            branch unless done (count is 0)
    
    DONE:   PLA                  get quotient (lo)
            RTS
    
END ; CODE