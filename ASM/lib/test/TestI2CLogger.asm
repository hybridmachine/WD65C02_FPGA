;***************************************************************************
;  FILE_NAME: TestI2CLogger.asm
;
;	Copyright (c) 2026 Brian Tabone
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
;  DESCRIPTION: <Description>
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
	INCLUDE "InterruptVectors.inc"


;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************
	XREF INITLOG
	XREF LOGSTR
	XREF POST_MEMORY_TEST
	XREF SUB_SEVENSEG_DISPLAY_VALUE
    XREF SUB_SEVENSEG_DISABLE
	XREF HIGH_NIBBLE_TO_HEX
	XREF LOW_NIBBLE_TO_HEX

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
	READYFLAG:		equ $40;
	LED_IO_ADDR:	equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	TRACE:			equ $50
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

	LDA #$00
	STA LED_IO_ADDR ; Clear any LEDs
	
	LDA #$B2
	JSR LOW_NIBBLE_TO_HEX
	CMP #"2"
	BEQ NIBBLE_TO_HEX_OVER9
	BRK
NIBBLE_TO_HEX_OVER9:
	LDA #$BD
	JSR LOW_NIBBLE_TO_HEX
	; Test A, should have "D" as its value
	CMP #"D"
	BEQ NIBBLE_SHIFT_SHOW_HIGH_BYTE
	BRK
NIBBLE_SHIFT_SHOW_HIGH_BYTE
	LDA #$BD
	JSR HIGH_NIBBLE_TO_HEX
	; Test A, should have "B" as its value
	CMP #"B"
	BEQ NIBBLE_TO_HEX_TESTED
	BRK
NIBBLE_TO_HEX_TESTED:
	STZ READYFLAG
	LDA #$BD ; Load an illegal high address, verify we get an error status back A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG
	CMP #$FF
	BEQ TEST_BAD_LOWADDRESS
	BRK
TEST_BAD_LOWADDRESS:
	LDA #$07 ; Lowest legal is #$08, this should fail
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG
	CMP #$FF
	BEQ TEST_LOAD_GOOD_ADDRESS
	BRK
TEST_LOAD_GOOD_ADDRESS:
	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; 
	JSR INITLOG
	BEQ TEST_LOG_DATA ; A should have #$00, success
	BRK
TEST_LOG_DATA:
	LDA #$01
	STA TRACE
	STA LED_IO_ADDR

	JSR INITWAIT
	LDX #LOGMESSAGELONG
	LDY #>LOGMESSAGELONG
	JSR LOGSTR
	JSR WAIT
	
	LDA #$02
	STA TRACE
	STA LED_IO_ADDR

	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG

	JSR INITWAIT
	LDA #$92
	STA TRACE
	STA LED_IO_ADDR
	LDX #LOGMESSAGE
	LDY #>LOGMESSAGE
	JSR LOGSTR
	LDA #$A2
	STA TRACE
	STA LED_IO_ADDR
	JSR WAIT
	
	LDA #$03
	STA TRACE
	STA LED_IO_ADDR

	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG

	JSR INITWAIT
	LDX #LOGMESSAGESHORT
	LDY #>LOGMESSAGESHORT
	JSR LOGSTR
    JSR WAIT
	
	LDA #$04
	STA TRACE
	STA LED_IO_ADDR

	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG

	JSR INITWAIT
	LDX #LOGMESSAGEFMT
	LDY #>LOGMESSAGEFMT
	LDA #$FA
	PHA
	LDA #$CE
	PHA
	JSR LOGSTR
	PLA
	PLA
    JSR WAIT
	
	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG

	JSR INITWAIT
	LDX #LOGMESSAGEFMT
	LDY #>LOGMESSAGEFMT
	LDA #$BE
	PHA
	LDA #$EF
	PHA
	JSR LOGSTR
	PLA
	PLA
    JSR WAIT
	
	LDA #$0A ; Should give 0 success status in A
	STA LED_IO_ADDR ; Clear any LEDs
	JSR INITLOG

	JMP TEST_LOG_DATA ; Just loop for now

INITWAIT:
	LDA #$01
	STA READYFLAG
	RTS
WAIT:
	LDA TRACE
	ORA #$80
	STA LED_IO_ADDR
	LDA READYFLAG
	BNE WAIT
	LDA #$F0
	STA LED_IO_ADDR ; Let the user know the interrupt is complete
	RTS

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
		; 5) Write ACK to IRQ controller, in interrupt handler
		lda PIO_IRQ_CONTROLLER_IRQNUM
		sta PIO_IRQ_CONTROLLER_IRQACK

		CMP #IRQ_CHANNEL_I2CSTRM
		BNE ALLCLEAR
		STZ READYFLAG ; Clear the ready flag
ALLCLEAR:
		; ORA #$80 ; Set high bit so we know we are coming from IRQHandler
		; STA LED_IO_ADDR;
		
		; Reset ack lines
		lda #$FF
		sta PIO_IRQ_CONTROLLER_IRQACK
		

		pla
		rti

	bits:	db	1
	cnt:	db	0
	wraps:	dw	0
	delay:	db	10

	LOGMESSAGELONG: 	db	'A long log string that is over 80 characters long, should flush at 80, this is a test!',0 ; Null terminated overlong string
	LOGMESSAGE: 	    db	'A 79 character long log message, this should fully print testtest test test 12',0 ; Null terminated full string
	LOGMESSAGESHORT:	db  'A less than max message',0
	LOGMESSAGEFMT:		db	'This message has a fmt: "%X"',0

;***************************************************************************
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE