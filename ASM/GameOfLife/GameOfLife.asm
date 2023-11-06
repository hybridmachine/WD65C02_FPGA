;***************************************************************************
;  FILE_NAME: GameOfLife.asm
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
;  DESCRIPTION: Implementation of John Conway's game of life to run on 
;				the FPGA / 65C02 Micro Computer
;
;
;***************************************************************************    
BOARD_WIDTH:            equ 32
BOARD_HEIGHT:           equ 32
BOARD_MEM_SIZE:         equ BOARD_WIDTH * BOARD_HEIGHT
BOARD_MEM_BASE_ADDR:    equ $0300
BOARD_ROW_PTR_ADDR:     equ $10   ; 16 bit pointer to the current row $10L $11H
EXTERN MULT             ; Multiply routine defined in Multiply.asm

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF
    org $FC00   ; Must match ROM_START in PKG_65C02.vhd

START:
    sei             ; Mask maskable interrupts

    cld				; Clear decimal mode
    clc             ; Clear carry

INITGAMEBOARD:
    ldx #0
    ldy #0
    ; Set pointer to board memory
    lda #(BOARD_MEM_BASE_ADDR).low.
    sta $BOARD_ROW_PTR_ADDR
    lda #(BOARD_MEM_BASE_ADDR).high.
    sta $BOARD_ROW_PTR_ADDR+1
    lda #0
    
INITY:
    pha         ; Save A on the stack
    tya
    pha         ; Save Y on the stack
    tyx
    pha         ; Save X on the stack
    jmp MULT    ; Get row starting address
LD_ROW_PTR:
    STY $BOARD_ROW_PTR_ADDR    ; Store row pointer low
    STX $BOARD_ROW_PTR_ADDR+1  ; Store row pointer high
    pla         ; Restore X
    tax
    pla         ; Restore Y
    tay
    pla         ; Restore A     
INITX:
    dex         ; Decrement column pointer
    sta $(BOARD_ROW_PTR_ADDR),x
    bne INITGAMEBOARD
