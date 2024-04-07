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
    ldy WIDTH
    ldx HEIGHT
LOOP_ROW:
LOOP_COL:
    lda INITVAL
    sta (PTR1),Y   
    dey
    bne LOOP_COL
    sta (PTR1),Y  ; Store pattern in last byte then reset Y
    ldy WIDTH
    dex
    bne LOOP_ROW
    rts

; void SetBit(uint8 x, uint8 y, uint8 bit)
SUB_SETBIT:
    rts

SUB_GETBIT:
    rts

PRIV_GETBITADDR:
    rts

END ; CODE