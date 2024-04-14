;***************************************************************************
;  FILE_NAME: BitBoard.asm
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
;  DESCRIPTION: 2 dimensional bit board with init, get, set methods. 
;               Used by recursive games like Game Of Life
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

    INCLUDE "inc/PageZero.inc" ; Page zero usage locations


;***************************************************************************
;                              Global Modules
;***************************************************************************

    ; void InitBoard(uint16 baseAddr:PTR1, uint8 width:ARG1, uint8 height:ARG2, uint8 initval:ARG3)
    GLOBAL SUB_INITBOARD
    ; void SetBit(uint16 baseAddr:PTR1, uint8 x:ARG1, uint8 y:ARG2, uint8 bit:ARG3)
    GLOBAL SUB_SETBIT
    ; uint8 GetBit(uint16 baseAddr:PTR1, uint8 x:ARG1, uint8 y:ARG2)
    GLOBAL SUB_GETBIT
;***************************************************************************
;                              External Modules
;***************************************************************************
    XREF MULT ; Multiply subroutine

;***************************************************************************
;                              External Variables
;***************************************************************************
    ; Multiply arguments
    XREF MCAND1
    XREF MCAND2


;***************************************************************************
;                               Local Constants
;***************************************************************************

    STACK_BASE:     EQU     $0100
    INITVAL:        EQU     ARG3
    WIDTH:          EQU     ARG1
    HEIGHT:         EQU     ARG2
    BOARD_OFFSET:   EQU     SCRATCH+2
    NBR_CNT:        EQU     SCRATCH+2
    ROW_PTR:        EQU     SCRATCH
    CELL_PTR:       EQU     PTR2

;***************************************************************************
;                               Library Code
;***************************************************************************
;

; void InitBoard(uint16 baseAddr, uint8 width, uint8 height, uint8 initval)
; Conceptually a board is
; struct {
;   uint16 rowptrs[height];
;   uint8  rows[height][width];
; }
SUB_INITBOARD:
    ; Calculate the bytes offset for rowptrs
    ; 2*HEIGHT
    lda #0
    sta MCAND1
    sta MCAND1+1
    sta MCAND2
    sta MCAND2+1
    ; MCAND1 = 2
    lda #2
    sta MCAND1
    ; MCAND2 = HEIGHT
    lda HEIGHT
    sta MCAND2
    jsr MULT
    ; X,Y is high,low of 2*HEIGHT
    ; Save low byte
    tya
    sta BOARD_OFFSET
    ; Save high byte
    txa
    sta BOARD_OFFSET+1

    ; Create row pointers
    ldx #0
LOOP_ROW_PTR:
    lda #0
    ; Zero out the scratch space
    sta SCRATCH 
    sta SCRATCH+1
    txa
    asl ; Multiply by 2
    tay ; Save off y*2 into x, used in pointer index below
    ; Preserve X anx Y
    phx
    phy
    txa ; Want row offset, not row * 2
    sta MCAND1
    lda #0
    sta MCAND1+1
    lda WIDTH
    sta MCAND2
    lda #0
    sta MCAND2+1
    jsr MULT
    ; Save off the base address row offset
    tya
    sta SCRATCH 
    txa
    sta SCRATCH+1
    ; Restore X and Y
    ply
    plx
    lda PTR1
    clc
    adc SCRATCH
    sta SCRATCH
    lda PTR1+1
    adc SCRATCH+1
    sta SCRATCH+1
    ; Add rowptr offset
    clc
    lda BOARD_OFFSET
    adc SCRATCH
    sta SCRATCH
    lda BOARD_OFFSET+1
    adc SCRATCH+1
    sta SCRATCH+1
 
    lda SCRATCH
    sta (PTR1),Y
    lda SCRATCH+1
    iny
    sta (PTR1),Y
    inx
    cpx HEIGHT
    bne LOOP_ROW_PTR
    ldx #0
    ldy #0
    ; 0 indexed to subtract one from width and height, we go from 0 to N-1 for N positions
LOOP_ROW:
LOOP_COL:
    ; Save arg1 and arg2
    lda ARG1
    pha
    lda ARG2
    pha
    ; Save off x and y
    phx
    phy
 
    ; Setup arguments to set bit
    txa 
    sta ARG1
    tya
    sta ARG2
    lda INITVAL
    sta ARG3
    ; PTR1 is already set to the board
    jsr SUB_SETBIT
    ; restore x,y, and args
    ply
    plx
    pla
    sta ARG2
    pla
    sta ARG1
    inx
    cpx WIDTH 
    bne LOOP_COL ; When x == WIDTH, we are done with this row
    ldx #0
    iny
    cpy HEIGHT ; when y == HEIGHT, we are done with the board
    bne LOOP_ROW
    rts

; void SetBit(boardAddr ptr1, uint8 x:ARG1, uint8 y:ARG2, uint8 bitval:ARG3)
SUB_SETBIT:
    ; Put the target row start location in scratch
    asl ARG2 # Multiply by 2, since each pointers is two bytes
    ldy ARG2
    lda (PTR1),Y
    sta SCRATCH
    iny
    lda (PTR1),Y
    sta SCRATCH+1
    ; We have the row start, now find the byte in that row (the X position)
    ldy ARG1
    ; Load the bit pattern we want to set in this position
    lda ARG3
    sta (SCRATCH),Y
    rts

; uint8 GetBit(boardAddr ptr1, uint8 x:ARG1, uint8 y:ARG2) - Returns value in accumulator
SUB_GETBIT:
    ; Put the target row start location in scratch
    asl ARG2 # Multiply by 2, since each pointers is two bytes
    ldy ARG2
    lda (PTR1),Y
    sta SCRATCH
    iny
    lda (PTR1),Y
    sta SCRATCH+1
    ; We have the row start, now find the byte in that row (the X position)
    ldy ARG1
    lda (SCRATCH),Y
    rts

; uint8 GetLiveNeighborCount(boardAddr ptr1, uint8 x:ARG1, uint8 y:ARG2, uint8 width:ARG3))
; Returns the number of live neighbors immediately bounding the x,y position
; Important NOTE: This routine assumes it is not on the board boundary, that there is always a valid
; X-1, X+1, Y-1, Y+1 position.
SUB_GET_LIVE_NEHIHBOR_COUNT:
    ; Zero out the neighbor count
    lda #0
    sta NBR_CNT

    ; PT1 is already setup, ARG1 and ARG2 have the offsets already, get the cell pointer
    jsr PRIV_GETCELLADDR
    ; Cell address is now in CELL_PTR

    ldy #-1
    ; Check left neighbor
    lda (CELL_PTR),Y
    clc
    adc NBR_CNT
    sta NBR_CNT

    ; Check right neighbor
    ldy #1
    lda (CELL_PTR),Y
    clc
    adc NBR_CNT
    sta NBR_CNT

    ; Check top neighbor
    sec
    ;lda 
    rts

; uint16 GetBitAddr(boardAddr ptr1, uint8 x:ARG1, uint8 y:ARG2)
; Returns the address of the bit at x,y, into ptr2
PRIV_GETCELLADDR:
    ; Put the target row start location in scratch
    asl ARG2 # Multiply by 2, since each pointers is two bytes
    ldy ARG2
    lda (PTR1),Y
    sta CELL_PTR
    iny
    lda (PTR1),Y
    sta CELL_PTR+1
    ; We have the row start, now find the byte in that row (the X position)
    lda ARG1
    clc
    adc CELL_PTR
    rts

END ; CODE