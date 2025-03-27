;***************************************************************************
;  FILE_NAME: TestInterruptController.asm
;
;	Copyright (c) 2025 Brian Tabone
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
;  DESCRIPTION: Set the timer period and start timer which will fire the IRQ every MS (as programmed). Our interrupt service
;  routine will then read the timer value and write it to the seven segment display
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
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;

	STACK_BASE:                 equ $0100      ; Stack base address
    ; These values align with definitions in PKG_TIMER_CONTROL.vhd
    CTL_TIMER_RESET:            equ %00000001  ; Request timer reset
    CTL_TIMER_RUN:              equ %00000000  ; Set timer to run

	TIMER_CTL_ADDRESS			equ $0218
	TIMER_PERIOD_MS_ADDRESS 	equ $0219 ; -- Four bytes , little endian. Unsigned int millisecond period for timer

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

		; 0) Disable the timer
		LDA #CTL_TIMER_RESET
		STA TIMER_CTL_ADDRESS

		; 1) Program the timer period in MS (500 == 0x01F4)
		LDA #F4
		STA TIMER_PERIOD_MS_ADDRESS
		
		LDA #01
		STA TIMER_PERIOD_MS_ADDRESS+1
		
		LDA #00
		STA TIMER_PERIOD_MS_ADDRESS+2
		STA TIMER_PERIOD_MS_ADDRESS+3

        ; 2) Unmask interrupts
		cli             ; Allow maskable interrupts

        ; 3) Start the timer
		LDA #CTL_TIMER_RUN
		STA TIMER_CTL_ADDRESS

        ; 4) In interrupt service routine, read timer value on every fired interrupt
        ; 5) Write timer value to seven segment display -- This might be a simple incremented index
        ; 6) Write ACK to IRQ controller, in interrupt handler

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