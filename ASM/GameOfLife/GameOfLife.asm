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
BOARD_WIDTH:            equ 48
BOARD_HEIGHT:           equ 48
BOARD_MEM_SIZE:         equ (BOARD_WIDTH/8)*BOARD_HEIGHT ; We use bits for each cell, so columns are 1 bit wide
BOARD_MEM_BASE_ADDR:    equ $0300
BOARD_MEM_END_ADDR:     equ BOARD_MEM_BASE_ADDR+BOARD_MEM_SIZE
CELL_MASK_BASE          equ $20
CELL_DEAD:              equ 0
CELL_LIVE:              equ 1
CELL_PTR:               equ $10 ; $11, $10 is a 16 bit pointer to game board

CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF
    org $FC00   ; Must match ROM_START in PKG_65C02.vhd
    XREF MULT
    XREF MCAND1
    XREF MCAND2
    XREF DIV
    XREF DIVDND
    XREF DIVSOR

START:
    sei             ; Mask maskable interrupts

    cld				; Clear decimal mode
    clc             ; Clear carry
    lda #CELL_LIVE
    sta CELL_MASK_BASE
    lda #CELL_LIVE<<1
    sta CELL_MASK_BASE+1
    lda #CELL_LIVE<<2
    sta CELL_MASK_BASE+2
    lda #CELL_LIVE<<3
    sta CELL_MASK_BASE+3
    lda #CELL_LIVE<<4
    sta CELL_MASK_BASE+4
    lda #CELL_LIVE<<5
    sta CELL_MASK_BASE+5
    lda #CELL_LIVE<<6
    sta CELL_MASK_BASE+6
    lda #CELL_LIVE<<7
    sta CELL_MASK_BASE+7

    ; Store off the end ptr for debugging    
    lda #BOARD_MEM_END_ADDR
    sta CELL_PTR+2    
    lda #>BOARD_MEM_END_ADDR
    sta CELL_PTR+3
    ; Load cell pointer with base address location
    lda #BOARD_MEM_BASE_ADDR
    sta CELL_PTR    
    lda #>BOARD_MEM_BASE_ADDR
    sta CELL_PTR+1
INITGAMEBOARD:
    ldx #0
    ldy #0
    lda #CELL_DEAD
    sta (CELL_PTR)
    clc
    lda #1
    adc CELL_PTR
    sta CELL_PTR
    bcc TEST_PTR ; skip the high byte if carry is clear
    lda #0 ; Carry the carry flag if set
    adc CELL_PTR+1
    sta CELL_PTR+1
TEST_PTR:
    sec ; Set carry for subtraction
    lda CELL_PTR
    sbc #BOARD_MEM_END_ADDR
    bne INITGAMEBOARD ; Low byte doesn't match, continue loop
    sec
    lda CELL_PTR+1
    sbc #>BOARD_MEM_END_ADDR
    bne INITGAMEBOARD ; High byte doesn't match, continue loop

LOAD_R_PENTOMINO:
    ; Test division
    lda #14
    sta DIVDND
    lda #3
    sta DIVSOR
    jsr DIV
    brk ; All done, brk for debugging for now

;This code is here in case the system gets an NMI.  It clears the intterupt flag and returns.
unexpectedInt:		; $FFE0 - IRQRVD2(134)
	php
	pha
	lda #$FF
	
	;clear Irq
	pla
	plp
	rti

IRQHandler:
		pla
		rti

	bits:	db	1
	cnt:	db	0
	wraps:	dw	0
	delay:	db	10

;***************************************************************************
;***************************************************************************
; New for WDCMON V1.04
;  Needed to move Shadow Vectors into proper area
;***************************************************************************
;***************************************************************************
	SH_vectors:	section
Shadow_VECTORS	SECTION OFFSET $7EFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START				; $FFFC -  RESET (ALL)
		dw	IRQHandler			; $FFFE -  IRQBRK (ALL)

	        ends


;***************************************************************************

vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		; $FFFC -  RESET (ALL)
		dw	IRQHandler	; $FFFE -  IRQBRK (ALL)

	        ends

	        end
END ; CODE
