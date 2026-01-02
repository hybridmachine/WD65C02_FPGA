;***************************************************************************
;  FILE_NAME: TestI2CStreamer.asm
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
;  DESCRIPTION: Test module for I2CStreamer
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

	INCLUDE "../../../common/InterruptVectors.inc"

;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************

    XREF SUB_I2CSTREAM_GETSTATUS
    XREF SUB_I2CSTREAM_WRITEBYTE
    XREF SUB_I2CSTREAM_STREAM
    XREF SUB_I2CSTREAM_INITIALIZE
	XREF SUB_SEVENSEG_DISPLAY_VALUE
    XREF SUB_SEVENSEG_DISABLE
	XREF POST_MEMORY_TEST

;***************************************************************************
;                              External Variables
;***************************************************************************
;None

;***************************************************************************
;                               Local Constants
;***************************************************************************
	CYCLE_COUNT_CURRENT:	equ		$03 ; Just track the most recent low value
	CYCLE_COUNT_HIGH_ADDR:	equ 	$02
	CYCLE_COUNT_LOW_ADDR:	equ		$05
	STACK_BASE:				equ		$0100
	
	; Memory addresses for I2C interface status
    PIO_I2C_DATA_STRM_STATUS:		equ $0212
	LED_IO_ADDR:					equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	STATUS_READY:					equ $00
	STATUS_STREAMING_I2C_COMPLETE: 	equ $05
;***************************************************************************
;                              Macros
;***************************************************************************

START:
	SEI             ; Ignore maskable interrupts
	CLC             ; Clear carry
	CLD             ; Clear decimal mode

	LDX	#$ff		; Initialize the stack pointer
	TXS

;***************************************************************************
;                               Application Code
;***************************************************************************
;
	JSR SUB_SEVENSEG_DISABLE
	; Run power on self test functions
	JSR POST_MEMORY_TEST

	; MAIN
	
	LDA #$00
	STA LED_IO_ADDR ; Clear any LEDs
	STA CYCLE_COUNT_CURRENT ; Clear the current counter
	STA CYCLE_COUNT_LOW_ADDR ; Clear cycle 16 bits
	STA CYCLE_COUNT_HIGH_ADDR
	JSR LOG_ADDRESS ; DEBUG 
	CLI ; Enable interrupts, the streamer will send interrupts.

	LDA #$00 ; Use builtin default I2C address
	JSR SUB_I2CSTREAM_INITIALIZE
	; Test that accumulator has default address set
	; STA LED_IO_ADDR ; For debug	
	CMP #$76
	BEQ WAIT_FOR_STREAMER_READY
	JSR TEST_FAIL

WAIT_FOR_STREAMER_READY:
	JSR LOG_ADDRESS ; DEBUG
	LDA PIO_I2C_DATA_STRM_STATUS
	AND #$80
	; STA LED_IO_ADDR; This should cause the high bit to flicker while we wait for streamer ready
	
	; Test for status STATUS_READY (#$00)
	JSR SUB_I2CSTREAM_GETSTATUS ; Returns status in X register
	TXA ; If X is 0, then this sets the Zero flag
	BEQ SEND_I2C_DATA ; When Zero send data
	; STA LED_IO_ADDR ; Show the actual status on the LEDs for debugging
	JMP WAIT_FOR_STREAMER_READY

SEND_I2C_DATA
	JSR LOG_ADDRESS ; DEBUG
	LDX #$00
	LDY #$00
	LDA #$00
	
LOOP_WRITE:
	LDA I2CMESSAGE,X
	; STA LED_IO_ADDR ; For debug, write byte val to LEDs
	BEQ I2CSTREAMBUFFER ; If we hit the null, stream the buffer.
	; Write byte to buffer
	JSR SUB_I2CSTREAM_WRITEBYTE
	BEQ BYTE_BUFFERED ; accumulator should be set to 0 for success
	JSR LOG_ADDRESS

BYTE_BUFFERED:
	; Increment array index into I2CMESSAGE
	INX
	
	PHY
	PHX
	; JSR SUB_SEVENSEG_DISPLAY_VALUE
	; Cleanup stack
	PLX
	PLY
	
	JMP LOOP_WRITE ; 

I2CSTREAMBUFFER:
	
	;LDA #$C0
	;STA LED_IO_ADDR

	JSR LOG_ADDRESS
	CLI ; Ensure interrupts enabled
	PHP ; Push processor status to stack
	PLA ; Pull that into the A register
	; STA LED_IO_ADDR ; Show proc status on LEDs
	
	; JSR LOG_ADDRESS ; DEBUG
	JSR SUB_I2CSTREAM_STREAM

	PHP ; Push processor status to stack
	PLA ; Pull that into the A register
	; STA LED_IO_ADDR ; Show proc status on LEDs

WAIT_FOR_CYCLE_COUNT_CHANGE:
	
	; For now brute force cycling the streamer, we are still bugging the IRQ handler
	
	LDA CYCLE_COUNT_LOW_ADDR
	CMP CYCLE_COUNT_CURRENT
	BEQ WAIT_FOR_CYCLE_COUNT_CHANGE
	STA CYCLE_COUNT_CURRENT ; Value changed, save in current

WAIT_FOR_CYCLE_COUNT_CONTINUE:
	LDA CYCLE_COUNT_HIGH_ADDR
	PHA
	LDA CYCLE_COUNT_CURRENT
	PHA
	JSR SUB_SEVENSEG_DISPLAY_VALUE
	PLA
	PLA

	JSR SUB_I2CSTREAM_GETSTATUS
	TXA
	CMP #STATUS_READY
	BEQ REINIT_I2CSTREAM
	STA LED_IO_ADDR ; Show proc status on LEDs
	CMP #STATUS_STREAMING_I2C_COMPLETE
	BEQ REINIT_I2CSTREAM
	JMP WAIT_FOR_CYCLE_COUNT_CONTINUE

REINIT_I2CSTREAM:
	LDA #$00 ; Use builtin default I2C address
	JSR SUB_I2CSTREAM_INITIALIZE
	JMP WAIT_FOR_STREAMER_READY

TEST_FAIL:
	JSR SUB_SEVENSEG_DISPLAY_VALUE ; This will show the calling address
	LDA #$AA
	STA LED_IO_ADDR
	JMP TEST_FAIL
	BRK

LOG_ADDRESS:
	; Disable for now
	RTS

	JSR SUB_SEVENSEG_DISPLAY_VALUE ; This will show the calling address
	PHX
	LDX #$00
LOOP_LOG_ADDRESS:
	INX
	CPX #$FF
	BNE LOOP_LOG_ADDRESS
	PLX
	RTS
	
;This code is here in case the system gets an NMI.  It clears the intterupt flag and returns.
unexpectedInt:		; $FFE0 - IRQRVD2(134)
	php
	pha
	lda #$FF
	JSR LOG_ADDRESS ; DEBUG
	;clear Irq
	pla
	plp
	rti

IRQHandler:
		PHA
		; JSR LOG_ADDRESS ; DEBUG
		; 4) In interrupt service routine, increment timer value on every fired interrupt
		; LDA PIO_IRQ_CONTROLLER_IRQNUM
		; Not used since timer is IRQ 0, so A would be 0
		; CMP #IRQ_CHANNEL_I2CSTRM
		; BNE SEND_IRQ_ACK
		CLC
		LDA CYCLE_COUNT_LOW_ADDR
		ADC #$01
		STA CYCLE_COUNT_LOW_ADDR
		LDA CYCLE_COUNT_HIGH_ADDR
		ADC #$00 ; Add in any carry flag
		STA CYCLE_COUNT_HIGH_ADDR
		; Unhandled IRQ, just send back ACK
		; JMP SEND_IRQ_ACK
SEND_IRQ_ACK:
        ; 5) Write ACK to IRQ controller, in interrupt handler
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		STA PIO_IRQ_CONTROLLER_IRQACK
		ORA #$80 ; Set high bit so we know we are coming from IRQHandler
		STA LED_IO_ADDR;
		
		; Reset ack lines
		LDA #$FF
		STA PIO_IRQ_CONTROLLER_IRQACK
		
		PLA
		RTI

I2CMESSAGE:	db	'HELLO WORLD!',0 ; Null terminated string


;***************************************************************************
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE