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
;None

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

;***************************************************************************
;                              External Variables
;***************************************************************************
;None

;***************************************************************************
;                               Local Constants
;***************************************************************************
	CYCLE_COUNT_HIGH_ADDR:	equ 	$02
	CYCLE_COUNT_LOW_ADDR:	equ		$01

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

	LDA #00
	JSR SUB_I2CSTREAM_INITIALIZE
	; Test that accumulator has default address set
	CMP #$76
	BNE TEST_FAIL
	
	; Test for status STATUS_READY (#$00)
	JSR SUB_I2CSTREAM_GETSTATUS ; Returns status in X register
	TXA ; If X is 0, then this sets the Zero flag
	BNE TEST_FAIL ; Expect Zero to be set

	LDX #$00
	LDY #$00
	LDA #$00
	
	; Write 254 bytes of data to buffer
LOOP_WRITE:
	; Save registers
	PHA
	PHX
	PHY
	; Write byte to buffer
	JSR SUB_I2CSTREAM_WRITEBYTE
	BNE TEST_FAIL ; accumulator should be set to 0

	; Restore registers
	PLY
	PLX
	PLA

	; Increment X and A (Leave Y at 0)
	INX
	INA

	BNE LOOP_WRITE ; If hasn't rolled to 0, keep going

	; Send the stream
	JSR SUB_I2CSTREAM_STREAM

	; Spin for some clock cycles
	LDA #$01
	STA CYCLE_COUNT_HIGH_ADDR
	LDA #$00
	STA CYCLE_COUNT_LOW_ADDR
	JSR SPIN_FOR_DELAY

	BRK ; End of test 

; CYCLE_COUNT_HIGH in $02 and CYCLE_COUNT_LOW in $01
SPIN_FOR_DELAY: 
	SEC
    LDA CYCLE_COUNT_LOW_ADDR
	SBC #$01
	BCC DECREMENT_HIGH
	STA CYCLE_COUNT_LOW_ADDR
	JMP SPIN_FOR_DELAY
DECREMENT_HIGH:
	SEC
	LDA CYCLE_COUNT_HIGH_ADDR
	BEQ END_SPIN ; High is 0, we are done counting down
	SBC #$01
	STA CYCLE_COUNT_HIGH_ADDR
	LDA #$FF
	STA CYCLE_COUNT_LOW_ADDR
	JMP SPIN_FOR_DELAY
END_SPIN: 
    RTS

TEST_FAIL:
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
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE