;***************************************************************************
;  FILE_NAME: TestTimer.asm
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
;  DESCRIPTION: Test driver for FPGA hosted millisecond resolution timer
;
;  
;
;***************************************************************************   
CODE
    CHIP	65C02
    LONGI	OFF
    LONGA	OFF

;***************************************************************************
;                             Include Files
;***************************************************************************
    INCLUDE "Timer.inc"    ; Macro definitions

;***************************************************************************
;                              External Modules
;***************************************************************************

; Constants
    TIMER_READ_VALUE:   equ $10 ; 4 byte value returned by timer, low byte at $10, high byte at $13

   
START:

    JSR SUB_TIMER_START
    LDY #$FF
; Give the timer some time to run
DELAY_OUTER_LOOP:
    LDX #$FF
    ; If Y == 0 read timer
    DEY
    BEQ READ_TIMER
DELAY_INNER_LOOP:
    DEX
    ; If X > 0 repeat X--
    BNE DELAY_INNER_LOOP
    JMP DELAY_OUTER_LOOP
READ_TIMER:
    TIMER_READ TIMER_READ_VALUE
    BRK

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
end ; SH_vectors 

END ; CODE
