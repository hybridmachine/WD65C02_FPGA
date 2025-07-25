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

	INCLUDE "../../seven_segment_display/SevenSegmentDisplay.inc"


;***************************************************************************
;                              Global Modules
;***************************************************************************
	

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
    CTL_TIMER_RESET:            equ $00  ; Request timer reset
    CTL_TIMER_RUN:              equ $FF  ; Set timer to run

	LED_IO_ADDR:	equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	TIMER_CTL_ADDRESS:			equ $0218
	TIMER_PERIOD_MS_ADDRESS: 	equ $0219 ; -- Four bytes , little endian. Unsigned int millisecond period for timer
	PIO_IRQ_CONTROLLER_IRQNUM:  equ $0223
    PIO_IRQ_CONTROLLER_IRQACK:  equ $0224

	PIO_SWITCHES_PREV_STATEVEC_L: equ $0225
    PIO_SWITCHES_PREV_STATEVEC_H: equ $0226
    PIO_SWITCHES_UPDATED_VEC_L: equ $0227
    PIO_SWITCHES_UPDATED_VEC_H: equ $0228

	TIMER_CNT: 					equ $0400 ; -- Two bytes, zero'd on startup, incremented and displayed in IRQB handler

	IRQ_CHANNEL_TIMER:			equ $00 ; Timer fires on IRQ 0
	IRQ_CHANNEL_BUTTON:			equ $01 ; Buttons come in on IRQ 1

	; Interrupt handler will copy current values from device to these locations, 
	; main work thread will then write status LEDs based on state
	SWITCHES_PREV_STATEVEC_L:			equ $08 ; Previous switch state vector
	SWITCHES_PREV_STATEVEC_H:			equ $09 

	SWITCHES_UPDATED_VEC_L:		equ $10 ; Which switches have changed, to get current state, xor this against PREV_SWITCH_STATE_*
	SWITCHES_UPDATED_VEC_H:		equ $11 

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

		; Initialize counter memory
		STZ TIMER_CNT
		STZ TIMER_CNT+1

		; 0) Disable the timer
		LDA #CTL_TIMER_RESET
		STA TIMER_CTL_ADDRESS

		; 1) Program the timer period in MS (500 == 0x01F4)
		LDA #$F4
		STA TIMER_PERIOD_MS_ADDRESS
		
		LDA #$01
		STA TIMER_PERIOD_MS_ADDRESS+1
		
		LDA #00
		STA TIMER_PERIOD_MS_ADDRESS+2
		STA TIMER_PERIOD_MS_ADDRESS+3

        ; 2) Unmask interrupts
		cli             ; Allow maskable interrupts

        ; 3) Start the timer
		LDA #$FF
		STA PIO_IRQ_CONTROLLER_IRQACK ; Set this to no ack

		LDA #CTL_TIMER_RUN
		STA TIMER_CTL_ADDRESS

		LDA #$FF
		
APPLICATION_LOOP:

		; 6) Write timer value to seven segment display -- This might be a simple incremented index
		CMP TIMER_CNT
		BEQ DISPLAY_SWITCH_STATE ; If TIMER_CNT is unchanged, don't push new data to the 7 seg display
		LDA TIMER_CNT
		SEVENSEG_DISPLAY_VALUE TIMER_CNT

DISPLAY_SWITCH_STATE:
		; prev state vec xor updated vec gives current switch state
		LDA SWITCHES_PREV_STATEVEC_L
		EOR SWITCHES_UPDATED_VEC_L
		;Button mappings per the constraints file
		;set_property PACKAGE_PIN W19 [get_ports {I_SWITCHES[0]}] # BTN Left
		;set_property PACKAGE_PIN T17 [get_ports {I_SWITCHES[1]}] # BTN Right
		;set_property PACKAGE_PIN T18 [get_ports {I_SWITCHES[2]}] # BTN Up
		;set_property PACKAGE_PIN U17 [get_ports {I_SWITCHES[3]}] # BTN Down
		STA LED_IO_ADDR ; Just show the switch states on the LEDs for now

		JMP APPLICATION_LOOP
        

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
		
		PHA
		; 4) In interrupt service routine, increment timer value on every fired interrupt
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		; Not used since timer is IRQ 0, so A would be 0
		; CMP #IRQ_CHANNEL_TIMER
		BEQ HANDLE_TIMER
		CMP #IRQ_CHANNEL_BUTTON
		BEQ HANDLE_BUTTON
		; Unhandled IRQ, just send back ACK
		JMP SEND_IRQ_ACK
		
HANDLE_TIMER:
		; If we get here, this is IRQ 0, our timer
		CLC
		LDA TIMER_CNT
		ADC #01
		STA TIMER_CNT
		LDA TIMER_CNT+1
		ADC #0 ; Add carry if present
		STA TIMER_CNT+1
		JMP SEND_IRQ_ACK

HANDLE_BUTTON:
		; Transfer the button state vector and update vector from device to working memory
		LDA PIO_SWITCHES_PREV_STATEVEC_L
		STA SWITCHES_PREV_STATEVEC_L

    	LDA PIO_SWITCHES_PREV_STATEVEC_H
		STA SWITCHES_PREV_STATEVEC_H

    	LDA PIO_SWITCHES_UPDATED_VEC_L
		STA SWITCHES_UPDATED_VEC_L

    	LDA PIO_SWITCHES_UPDATED_VEC_H
		STA SWITCHES_UPDATED_VEC_H

		JMP SEND_IRQ_ACK ; Not really needed but here for when we add the next IRQ handled

SEND_IRQ_ACK:
        ; 5) Write ACK to IRQ controller, in interrupt handler
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		STA PIO_IRQ_CONTROLLER_IRQACK
		
		; Reset ack lines
		LDA #$FF
		STA PIO_IRQ_CONTROLLER_IRQACK
		
		PLA
		RTI

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