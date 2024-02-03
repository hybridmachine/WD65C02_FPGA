;***************************************************************************
;  FILE_NAME: GameBoardV2.asm
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
;  DESCRIPTION: 2 dimensional on/off bit gameboard. This version avoids multiplication, uses 
;  the row start address vector instead. Assumes vector was setup for each board
;
;
;***************************************************************************    


CODE
; Relocatable by the assembler (so is Multiply and Divide), address specifed by -CFC00 on the assembler options
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

    GLOBAL SUB_GET_CELL_VALUE
    GLOBAL SUB_SET_CELL_VALUE
    GLOBAL SUB_GET_CELL_BYTE_ADDRESS
    GLOBAL SUB_LOAD_ROW_POINTERS
    GLOBAL CELL_DEAD
    GLOBAL CELL_LIVE

    XREF MULT
    XREF MCAND1
    XREF MCAND2
    XREF DIV
    XREF DIVDND
    XREF DIVSOR
    XREF CUR_CELL_PTR
    XREF BOARD_PTR
    XREF CELL_MASK_BASE
    XREF CELL_MASK_INVERT
    XREF BOARD_WIDTH
    XREF BOARD_HEIGHT
    XREF BRD1_ROW_POINTERS
    XREF BRD2_ROW_POINTERS

    ; Constants for cell values
    CELL_DEAD:              equ 0
    CELL_LIVE:              equ 1

; Initialize the row pointers for the board pointed to by BOARD_PTR. Note that 
; the two bytes after BOARD_PTR is the pointer to the start of BRD#_ROW_POINTERS
; Arguments are in BOARD_PTR .. BOARD_PTR+3
SUB_LOAD_ROW_POINTERS:
    LDX #0
LOOP_ROW_PTRS:
    ; Formula is BOARD_PTR+(BOARD_WIDTH*X)
    RTS

; Subroutine to get the current cell value. Arguments are in X,Y , return value goes into A
SUB_GET_CELL_VALUE:
    JSR SUB_GET_CELL_BYTE_ADDRESS
    LDX CUR_CELL_PTR+2 ; Put the bit offset into X
    LDA (CUR_CELL_PTR)
    AND CELL_MASK_BASE,X
    BEQ RETURN_CELL_DEAD ; If AND returns 0, cell was dead
    LDA #CELL_LIVE ; Otherwise cell was live
    RTS
RETURN_CELL_DEAD
    LDA #CELL_DEAD
    RTS

; Subroutine to set the cell value. Arguments are in X, Y, and A (X, Y are position, A is CELL_LIVE/CELL_DEAD value)
SUB_SET_CELL_VALUE:
    ; We assume X and Y already have values loaded by our caller, get cell address and its offset in that byte
    PHA  ; Save off A
    JSR SUB_GET_CELL_BYTE_ADDRESS
    LDX CUR_CELL_PTR+2 ; Put the bit offset into X
    PLA
    CMP #CELL_DEAD   ; If A is CELL_DEAD, turn cell off
    BEQ CELL_OFF
CELL_ON:
    LDA (CUR_CELL_PTR)
    ORA CELL_MASK_BASE,X
    STA (CUR_CELL_PTR)
    RTS
CELL_OFF:
    LDA CELL_MASK_BASE,X
    EOR #$FF ; Invert mask
    STA CELL_MASK_INVERT
    LDA (CUR_CELL_PTR)
    AND CELL_MASK_INVERT
    STA (CUR_CELL_PTR)
    RTS

; Subroutine to get cell address given an X and Y value (passed in X and Y registers). Board pointer is pushed high, low on to 
; stack by caller
; Formula is (Y * (BOARD_WIDTH/8)) + (X/8), this gets you the byte that the cell is in, the remainder of X/8 gives you the 
; bit which is the cell.
; The byte address is in CUR_CELL_PTR,CUR_CELL_PTR+1 (low, high) and the remainder (bit location) is in CUR_CELL_PTR + 2
SUB_GET_CELL_BYTE_ADDRESS:
    ; Arguments X and Y are passed in via X and Y registers
    ; Calculate (Y * (BOARD_WIDTH/8))
    ; Zero out multiply argument locations
    ; First set cell pointer to base of board memory
    lda BOARD_PTR
    sta CUR_CELL_PTR    
    lda BOARD_PTR+1
    sta CUR_CELL_PTR+1
    LDA #0
    STA MCAND1
    STA MCAND1+1
    STA MCAND2
    STA MCAND2+1
    STY MCAND1
    LDA #(BOARD_WIDTH/8)
    STA MCAND2
    ; Preserve X and Y registers
    PHX
    PHY 
    JSR MULT
    ; Save off pointer calculation thus far, next up add X offset
    CLC
    TYA
    ADC CUR_CELL_PTR
    STA CUR_CELL_PTR
    LDA #0
    ADC CUR_CELL_PTR+1 ; Add any carry bit
    STA CUR_CELL_PTR+1
    TXA
    ADC CUR_CELL_PTR+1 
    BCS OVERFLOW_DETECTED
    STA CUR_CELL_PTR+1
    PLY
    PLX
    ; Clear out divide memory locations
    LDA #0
    STA DIVDND
    STA DIVDND+1
    STA DIVSOR
    STA DIVSOR+1
    ; Divide X by 8
    STX DIVDND
    LDA #8
    STA DIVSOR
    JSR DIV
    ; Sixteen bit add of A which is low byte of result (should be one byte only value so ignore high)
    CLC
    ADC CUR_CELL_PTR
    STA CUR_CELL_PTR
    LDA #0 ; Add any carry bit
    ADC CUR_CELL_PTR+1
    BCS OVERFLOW_DETECTED
    STA CUR_CELL_PTR+1
    LDA DIVDND  ; Load the remainder, which is the bit offset
    STA CUR_CELL_PTR+2
    rts

OVERFLOW_DETECTED:
    BRK ; Overflow detected, bail out
