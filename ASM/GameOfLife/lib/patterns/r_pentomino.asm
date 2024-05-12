;***************************************************************************
;  FILE_NAME: r_pentomino.asm
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
;  DESCRIPTION: Load the r_pentomino.asm pattern into a board, assumes board is already initialized
;
;
;***************************************************************************    

CODE
; Build as relocatable, specify start address in linker options, see make.bat for start address
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

;***************************************************************************
;                             Include Files
;***************************************************************************

    INCLUDE "inc/PageZero.inc" 
    INCLUDE "inc/GameOfLifeConstants.inc" 

;***************************************************************************
;                              Global Modules
;***************************************************************************

    GLOBAL SUB_LOAD_R_PENTOMINO
    
;***************************************************************************
;                              External Modules
;***************************************************************************
    XREF SUB_SETBIT

; Argument is in PTR1
SUB_LOAD_R_PENTOMINO:
        ; Load an R-Pentomino into gameboard
        ;   **
        ;  **
        ;   *
        
        lda #BOARD_WIDTH/2
        sta ARG_COL_X
        lda #BOARD_HEIGHT/2-1
        sta ARG_ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        lda #BOARD_WIDTH/2+1
        sta ARG_COL_X
        lda #BOARD_HEIGHT/2-1
        sta ARG_ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        lda #BOARD_WIDTH/2
        sta ARG_COL_X
        lda #BOARD_HEIGHT/2
        sta ARG_ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        lda #BOARD_WIDTH/2-1
        sta ARG_COL_X
        lda #BOARD_HEIGHT/2
        sta ARG_ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        lda #BOARD_WIDTH/2
        sta ARG_COL_X
        lda #BOARD_HEIGHT/2+1
        sta ARG_ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        rts
END ; CODE