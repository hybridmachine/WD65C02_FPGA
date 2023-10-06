; File: HelloLED.asm
; 10/01/2023

	IF	USING_02
	ELSE
		EXIT         "Not Valid Processor: Use -DUSING_02, etc. ! ! ! ! ! ! ! ! ! ! ! !"
	ENDIF

;***************************************************************************
;  FILE_NAME: HelloLED.asm
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
;  DESCRIPTION: Write to a memory mapped IO location to blink an LED. This is the
;				hello world for the FPGA - 65C02 computer
;
;
;***************************************************************************

	LED_IO_ADDR:	equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	
		CHIP	65C02
		LONGI	OFF
		LONGA	OFF

		org	$FC00		; Must match ROM_START in PKG_65C02.vhd

	START:
		sei

		cld
		ldx	#$ff		; Initialize the stack pointer
		txs

; First, Turn off all of the LEDs
		lda	#$00
		sta	LED_IO_ADDR	; Turn off the LEDs
		; To make debugging carry flag easier, start with a high lower byte value
		lda #$DD
		sta $00 ; Store DD in zero page 00

BLINKER:
		; Increment a 16 bit counter, output the high byte out to the LEDs
		clc			; Clear the carry bit	
		lda $00
		adc #$01
		sta $00
		lda #$00	; Load 0 to A then add with carry , this pulls in the carry flag for the next byte
		adc $01
		sta $01
		sta LED_IO_ADDR	; Display high byte value on LEDs. 
		jmp BLINKER		; Loop forever

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
