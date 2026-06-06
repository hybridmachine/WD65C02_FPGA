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
	INCLUDE "../../../common/InterruptTimerCtl.inc"
	INCLUDE "../../../common/MemoryMap.inc"

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
	END_BYTE_VAL:			equ		$0B

	; Byte to hold number of cyles to wait. Set this then start wait, timer loop in interrupt handler will decrement this to 0
	TIMER_WAIT_CYCLES:		equ		$0A

	STACK_BASE:				equ		$0100
	
	; Memory addresses for I2C interface status
    PIO_I2C_DATA_STRM_STATUS:		equ $0212
	LED_IO_ADDR:					equ	$0200 ; Matches MEM_MAPPED_IO_BASE, this byte is mapped to the LED pins
	STR_PTR_ARRAY:					equ $0410 ; The table of pointers
	STR_PTR:						equ $40 ; The active pointer
	STATUS_READY:					equ $00
	STATUS_STREAMING_I2C_COMPLETE: 	equ $05
	DATA_BYTE_INDEX:				equ $06

	SCRATCH:						equ $0A
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

	; Initialize array of string pointer array
	LDA #I2CMESSAGE0
	STA STR_PTR_ARRAY
	LDA #>I2CMESSAGE0
	STA STR_PTR_ARRAY+1

	LDA #I2CMESSAGE1
	STA STR_PTR_ARRAY+2
	LDA #>I2CMESSAGE1
	STA STR_PTR_ARRAY+3

	LDA #I2CMESSAGE2
	STA STR_PTR_ARRAY+4
	LDA #>I2CMESSAGE2
	STA STR_PTR_ARRAY+5
	
	LDA #I2CMESSAGE3
	STA STR_PTR_ARRAY+6
	LDA #>I2CMESSAGE3
	STA STR_PTR_ARRAY+7

	; Update str ptr
	LDA #$01
	ASL ; Multiply by 2
	TAY
	LDA STR_PTR_ARRAY,Y
	STA STR_PTR
	INY
	LDA STR_PTR_ARRAY,Y
	STA STR_PTR+1

	; Initialize the pseudorandom generator
	LDA #$0F ; Any val is fine here, I just chose this.
	STA PIO_PSRND_VAL

	JSR INITIALIZE_TIMER
	
	LDA #$00
	STA LED_IO_ADDR ; Clear any LEDs
	STA CYCLE_COUNT_CURRENT ; Clear the current counter
	STA CYCLE_COUNT_LOW_ADDR ; Clear cycle 16 bits
	STA CYCLE_COUNT_HIGH_ADDR
	
	CLI ; Enable interrupts, the streamer will send interrupts.
	
	; Start the timer
	LDA #$FF
	STA PIO_IRQ_CONTROLLER_IRQACK ; Set this to no ack
	LDA #CTL_TIMER_RUN
	STA TIMER_CTL_ADDRESS	

	LDA #$00 ; Use builtin default I2C address
	JSR SUB_I2CSTREAM_INITIALIZE
	; Test that accumulator has default address set
	; STA LED_IO_ADDR ; For debug	
	CMP #$76
	BEQ WAIT_FOR_STREAMER_READY
	JSR TEST_FAIL

WAIT_FOR_STREAMER_READY:
	
	; Test for status STATUS_READY (#$00)
	JSR SUB_I2CSTREAM_GETSTATUS ; Returns status in X register
	TXA ; If X is 0, then this sets the Zero flag
	BEQ SEND_I2C_DATA ; When Zero send data
	JMP WAIT_FOR_STREAMER_READY

SEND_I2C_DATA
	LDX #$00
	STX DATA_BYTE_INDEX
	LDY #$00
	LDA #$00
	
LOOP_WRITE:

	; Load string data
	LDY DATA_BYTE_INDEX
	LDA (STR_PTR),Y
	BEQ I2CSTREAMBUFFER ; If we hit the null, stream the buffer.
	
	; Write the data buffer value to the stream, so we can debug any dropped bytes or mis aligned frames
	; more easily in the I2C data stream
	; Write byte to buffer
	; LDA DATA_BYTE_INDEX
	
	; Set stream buffer address to write to
	LDY #$00
	LDX DATA_BYTE_INDEX
	JSR SUB_I2CSTREAM_WRITEBYTE
	BEQ BYTE_BUFFERED ; accumulator should be set to 0 for success
	
BYTE_BUFFERED:

	;LDA DATA_BYTE_INDEX
	;CMP #END_BYTE_VAL
	;BEQ I2CSTREAMBUFFER

	; Increment array index into I2CMESSAGE
	LDX DATA_BYTE_INDEX
	INX
	STX DATA_BYTE_INDEX
	
	JMP LOOP_WRITE ; 

I2CSTREAMBUFFER:
	; Write random data to seven segment display
	LDA PIO_PSRND_VAL
	PHA
	LDA PIO_PSRND_VAL ; Put the random balue in the low byte
	AND #$03
	PHA
	
	; Update str ptr
	ASL ; Multiply by 2
	TAY
	LDA STR_PTR_ARRAY,Y
	STA STR_PTR
	INY
	LDA STR_PTR_ARRAY,Y
	STA STR_PTR+1

	JSR SUB_SEVENSEG_DISPLAY_VALUE
	PLA
	PLA
	LDX DATA_BYTE_INDEX ; Make sure we incrment on last written offset

	; We assume that X is no greater than END_BYTE_VAL
	LDY #$00
	INX
	LDA CYCLE_COUNT_LOW_ADDR
	JSR SUB_I2CSTREAM_WRITEBYTE ; Write the interrupt counter to the stream before we send it, for debugging

	LDY #$00
	LDX DATA_BYTE_INDEX ; Make sure we incrment on last written offset
	INX ; Account for the terminator we write
	INX ; Add one more so we are past the write count
	LDA #$AA
	JSR SUB_I2CSTREAM_WRITEBYTE ; Put terminating null on buffer, don't rely on a zero being in the buffer

	; Let's add another null, help debug the off by one issue at the end.
	LDX DATA_BYTE_INDEX ; Make sure we incrment on last written offset
	INX ; Account for the terminator we write
	INX ; Add one more so we are past the write count
	INX ; Add one more so we are past the write count
	LDA #$BB
	JSR SUB_I2CSTREAM_WRITEBYTE ; Put terminating null on buffer, don't rely on a zero being in the buffer
    
	; JSR LOG_ADDRESS
	CLI ; Ensure interrupts enabled
	JSR SUB_I2CSTREAM_STREAM

WAIT_FOR_CYCLE_COUNT_CHANGE:
	
	; Log streamer status to LEDs
	; JSR SUB_I2CSTREAM_GETSTATUS
	; TXA
	; STA LED_IO_ADDR ; Show proc status on LEDs

	; For now brute force cycling the streamer, we are still bugging the IRQ handler
	
	LDA CYCLE_COUNT_LOW_ADDR
	CMP CYCLE_COUNT_CURRENT
	BEQ WAIT_FOR_CYCLE_COUNT_CHANGE
	STA CYCLE_COUNT_CURRENT ; Value changed, save in current
	; STA LED_IO_ADDR ; Show count

WAIT_FOR_CYCLE_COUNT_CONTINUE:
	; JSR LOG_ADDRESS
	JSR SUB_I2CSTREAM_GETSTATUS
	TXA
	CMP #STATUS_STREAMING_I2C_COMPLETE
	BEQ REINIT_I2CSTREAM
	JMP WAIT_FOR_CYCLE_COUNT_CONTINUE

REINIT_I2CSTREAM:
	; We expect the SCL to stop at this point, if it's still running, we need to fix something the VHDL
	PHA
	LDA #24 ; Turn inner bits on
	STA LED_IO_ADDR ; Show the actual status on the LEDs for debugging
	
	LDA #$02 ; Wait (100 * 5) ms
	STA TIMER_WAIT_CYCLES
	JSR WAIT_FOR_TIMER
	PLA

	LDA #$00 ; Use builtin default I2C address
	JSR SUB_I2CSTREAM_INITIALIZE
	
	PHA
	LDA #129 ; Turn outer bits on
	STA LED_IO_ADDR ; Show the actual status on the LEDs for debugging
	LDA #$02 ; Wait (100 * 5) ms
	STA TIMER_WAIT_CYCLES
	JSR WAIT_FOR_TIMER
	PLA

	JMP WAIT_FOR_STREAMER_READY

TEST_FAIL:
	JSR SUB_SEVENSEG_DISPLAY_VALUE ; This will show the calling address
	LDA #$AA
	STA LED_IO_ADDR
	JMP TEST_FAIL
	BRK

LOG_ADDRESS:
	; Disable for now
	; RTS

	STX SCRATCH
	JSR SUB_SEVENSEG_DISPLAY_VALUE ; This will show the calling address
	LDX SCRATCH
	PHA
	LDA #$0A ; Wait (100 * 10) ms, 1 seconds
	STA TIMER_WAIT_CYCLES
	JSR WAIT_FOR_TIMER
	PLA
	RTS
	
WAIT_FOR_TIMER:
	LDA TIMER_WAIT_CYCLES
	BNE WAIT_FOR_TIMER
	; When wait cycles drops to 0, return
	RTS

INITIALIZE_TIMER:
	; Disable the timer
	LDA #CTL_TIMER_RESET
	STA TIMER_CTL_ADDRESS

	; Program the timer period in MS (100 == 0x0064)
	LDA #$64
	STA TIMER_PERIOD_MS_ADDRESS
	
	LDA #$00
	STA TIMER_PERIOD_MS_ADDRESS+1
	STA TIMER_PERIOD_MS_ADDRESS+2
	STA TIMER_PERIOD_MS_ADDRESS+3

	; We don't start the timer here, caller must start timer
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
		; 4) In interrupt service routine, decrement TIMER_WAIT_CYCLES if not 0
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		BNE SKIP_TIMER ; If not IRQ 0, skip timer code
		LDA TIMER_WAIT_CYCLES
		BEQ SEND_IRQ_ACK ; If already 0, skip decrement
		; STA LED_IO_ADDR
		DEC TIMER_WAIT_CYCLES
		JMP SEND_IRQ_ACK
SKIP_TIMER:
		; If IRQ is not for IRQ, send ack, skip handler
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		CMP #IRQ_CHANNEL_I2CSTRM
		BNE SEND_IRQ_ACK
		
		CLC
		LDA CYCLE_COUNT_LOW_ADDR
		ADC #$01
		STA CYCLE_COUNT_LOW_ADDR
		ORA #$C0
		; STA LED_IO_ADDR
		LDA CYCLE_COUNT_HIGH_ADDR
		ADC #$00 ; Add in any carry flag
		STA CYCLE_COUNT_HIGH_ADDR
		; Unhandled IRQ, just send back ACK
		; JMP SEND_IRQ_ACK
SEND_IRQ_ACK:
        ; 5) Write ACK to IRQ controller, in interrupt handler
		LDA PIO_IRQ_CONTROLLER_IRQNUM
		STA PIO_IRQ_CONTROLLER_IRQACK
		; ORA #$80 ; Set high bit so we know we are coming from IRQHandler
		; STA LED_IO_ADDR;
		
		; Reset ack lines
		LDA #$FF
		STA PIO_IRQ_CONTROLLER_IRQACK
		
		PLA
		RTI

I2CMESSAGE0:	db	'V 1.0.2 Hello World, I am I2C!',0 ; Null terminated string
I2CMESSAGE1: db 'Test message 2',0
I2CMESSAGE2: db 'A longer message to test alternate string length output',0
I2CMESSAGE3: db 'shrt msg',0 

;***************************************************************************
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		dw	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		dw	START		        ; $FFFC -  RESET (ALL)
		dw	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE