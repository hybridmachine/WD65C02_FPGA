;***************************************************************************
;  FILE_NAME: GameOfLifeConstants.inc
;
;	Copyright (c) 2024 Brian Tabone
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
;  DESCRIPTION: Include file with constants for the GameOfLife program
;
;***************************************************************************   

    BOARD_WIDTH:          equ    40
    BOARD_HEIGHT:         equ    40
    ROW_PTRS_ARRAY_LEN:   equ    2*BOARD_HEIGHT
    BOARD1_BASE_ADDR:     equ    $0400
    BOARD2_BASE_ADDR:     equ    BOARD1_BASE_ADDR+(BOARD_WIDTH*BOARD_HEIGHT)+ROW_PTRS_ARRAY_LEN
    CELL_DEAD:            equ    0
    CELL_LIVE:            equ    1
    ; Argument positions for BitBoard subroutines
    CELL_STATUS:          equ    ARG3   ; bit on/off
    CURRENT_GEN:          equ    GAMEBOARDS ; Current gen is at the base of GAMEBOARDS 4 bytes range
    NEXT_GEN:             equ    CURRENT_GEN+2; Pointer for next gen right after current gen
    NBR_CNT:              equ    SCRATCH ; Use first scratch position for neihbor count
    ARG_COL_X:            equ    ARG1
    ARG_ROW_Y:            equ    ARG2