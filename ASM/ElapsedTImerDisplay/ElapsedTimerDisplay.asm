;***************************************************************************
;  FILE_NAME: ElapsedTimerDisplay.asm
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
;  DESCRIPTION: Run the elapsed timer and output the millisecond count onto the seven segment display (will display in hex)
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
;None


;***************************************************************************
;                             Global Modules
;***************************************************************************
;None

;***************************************************************************
;                             External Modules
;***************************************************************************
;
		; Timer functions
		XREF TIMER_START
		XREF TIMER_READ
		XREF TIMER_RESET

		; Seven Segment Display Functions
		XREF SEVENSEG_DISPLAY_VALUE
    	XREF SEVENSEG_DISABLE

;***************************************************************************
;                             External Variables
;***************************************************************************
;None


;***************************************************************************
;                              Local Constants
;***************************************************************************
;
		TIMER_READ_VALUE:   equ $10 ; 4 byte value returned by timer, low byte at $10, high byte at $13

START:
		sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

		ldx	#$ff		; Initialize the stack pointer
		txs

;***************************************************************************
;                               Application Code
;***************************************************************************
;
		jsr TIMER_START
; Give the timer some time to run
WAIT_FOR_TIMER:
		ldy #$FF
DELAY_OUTER_LOOP:
		ldx #$FF
		; If Y == 0 read timer
		dey
		beq READ_TIMER
DELAY_INNER_LOOP:
		dex
		; If X > 0 repeat X--
		bne DELAY_INNER_LOOP
		jmp DELAY_OUTER_LOOP
READ_TIMER:
		lda #0
		; Put four empty bytes on the stack, function will return counter val here
		pha
		pha
		pha
		pha
		jsr TIMER_READ
		pla
		sta TIMER_READ_VALUE
		pla
		sta TIMER_READ_VALUE+1
		pla
		sta TIMER_READ_VALUE+2
		pla
		sta TIMER_READ_VALUE+3

		; Put lower 16 timer bits (hi byte first) onto stack then call display code
		lda TIMER_READ_VALUE+1
		pha
		lda TIMER_READ_VALUE
		pha
		jsr SEVENSEG_DISPLAY_VALUE
		; Cleanup stack
		pla 
		pla
		jmp WAIT_FOR_TIMER ; Loop forever

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
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE