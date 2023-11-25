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
BOARD_WIDTH:            equ 48  ; Must be multiple of a byte wide and both width and height must be <= 255 (one byte values)
BOARD_HEIGHT:           equ 48
BOARD_MEM_SIZE:         equ (BOARD_WIDTH/8)*BOARD_HEIGHT ; We use bits for each cell, so columns are 1 bit wide
BOARD_MEM_BASE_ADDR:    equ $0300
BOARD_MEM_END_ADDR:     equ BOARD_MEM_BASE_ADDR+BOARD_MEM_SIZE
CELL_MASK_BASE          equ $20
CELL_MASK_INVERT        equ (CELL_MASK_BASE+8) ; Temp store for when we need to save a mask invert
CELL_DEAD:              equ 0
CELL_LIVE:              equ 1
CELL_PTR:               equ $10 ; $11, $10 is a 16 bit pointer to game board, $12 is the bit location in the byte

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
    ; Note the inversion here, conceptually the LSb (least significant bit) is far right of the byte, and 
    ; the MSb is far left so to set the conceptual bit 0 in the array (X goes 0 to N left to right), we start at the MSb
    lda #CELL_LIVE
    sta CELL_MASK_BASE+7
    lda #CELL_LIVE<<1
    sta CELL_MASK_BASE+6
    lda #CELL_LIVE<<2
    sta CELL_MASK_BASE+5
    lda #CELL_LIVE<<3
    sta CELL_MASK_BASE+4
    lda #CELL_LIVE<<4
    sta CELL_MASK_BASE+3
    lda #CELL_LIVE<<5
    sta CELL_MASK_BASE+2
    lda #CELL_LIVE<<6
    sta CELL_MASK_BASE+1
    lda #CELL_LIVE<<7
    sta CELL_MASK_BASE

    ; Store off the end ptr for debugging    
    lda #BOARD_MEM_END_ADDR
    sta CELL_PTR+3    
    lda #>BOARD_MEM_END_ADDR
    sta CELL_PTR+4
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
    ; Load an R-Pentomino into gameboard
    ;   **
    ;  **
    ;   *
    LDX #23
    LDY #22
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #24
    LDY #22
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #22
    LDY #23
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #23
    LDY #23
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    LDX #23
    LDY #24
    LDA #CELL_LIVE
    JSR SUB_SET_CELL_VALUE
    BRK ; Stop for debugging for now

; Subroutine to set the cell value. Arguments are in X, Y, and A (X, Y are position, A is CELL_LIVE/CELL_DEAD value)
SUB_SET_CELL_VALUE:
    ; We assume X and Y already have values loaded by our caller, get cell address and its offset in that byte
    PHA  ; Save off A
    JSR SUB_GET_CELL_BYTE_ADDRESS
    LDX CELL_PTR+2 ; Put the bit offset into X
    PLA
    CMP CELL_DEAD   ; If A is CELL_DEAD, turn cell off
    BEQ CELL_OFF
CELL_ON:
    LDA (CELL_PTR)
    ORA CELL_MASK_BASE,X
    STA (CELL_PTR)
    RTS
CELL_OFF:
    LDA CELL_MASK_BASE,X
    EOR #$FF ; Invert mask
    STA CELL_MASK_INVERT
    LDA (CELL_PTR)
    AND CELL_MASK_INVERT
    STA (CELL_PTR)
    RTS
; Subroutine to get cell address given an X and Y value (passed in X and Y registers)
; Formula is (Y * (BOARD_WIDTH/8)) + (X/8), this gets you the byte that the cell is in, the remainder of X/8 gives you the 
; bit which is the cell.
; The byte address is in CELL_PTR,CELL_PTR+1 (low, high) and the remainder (bit location) is in CELL_PTR + 2
SUB_GET_CELL_BYTE_ADDRESS:
    ; Arguments X and Y are passed in via X and Y registers
    ; Calculate (Y * (BOARD_WIDTH/8))
    ; Zero out multiply argument locations
    ; First set cell pointer to base of board memory
    lda #BOARD_MEM_BASE_ADDR
    sta CELL_PTR    
    lda #>BOARD_MEM_BASE_ADDR
    sta CELL_PTR+1
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
    ADC CELL_PTR
    STA CELL_PTR
    LDA #0
    ADC CELL_PTR+1 ; Add any carry bit
    STA CELL_PTR+1
    TXA
    ADC CELL_PTR+1 
    BCS OVERFLOW_DETECTED
    STA CELL_PTR+1
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
    ADC CELL_PTR
    STA CELL_PTR
    LDA #0 ; Add any carry bit
    ADC CELL_PTR+1
    BCS OVERFLOW_DETECTED
    STA CELL_PTR+1
    LDA DIVDND  ; Load the remainder, which is the bit offset
    STA CELL_PTR+2
    rts

OVERFLOW_DETECTED:
    BRK ; Overflow detected, bail out

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
