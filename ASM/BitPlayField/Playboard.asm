;***************************************************************************
;  FILE_NAME: Playboard.asm
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
;  DESCRIPTION: This is a 2 dimensional playfield implemented using bits directly. This file implements a N x M sized
;  board, where N is any integer (limited by RAM) and M is evenly divisible by 8. A contiguous array of memory is allocated, where each row is M/8 bytes
;  long. The sizeof(row) is saved off and used when indexing into the start of each row. 
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
        INCLUDE "../common/MemoryMap.inc"

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
        ROWCOUNT:       	equ 32
        COLCOUNT:       	equ 32
        ROWSIZE:        	equ COLCOUNT/8 ; Size in bytes of each row
        PLAYFIELDSTART: 	equ RAM_BASE
        PLAYFIELDEND:   	equ PLAYFIELDSTART+(ROWSIZE*ROWCOUNT)
		CELLBYTEADDRESS:	equ $10 ; $10 and $11 hold the pointer to the current cell address. 

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
INITPLAYBOARD:
    LDA #PLAYFIELDEND
	STA CELLBYTEADDRESS
	LDA #>PLAYFIELDEND
	STA CELLBYTEADDRESS+1
ZEROMEM:
	LDA CELLBYTEADDRESS ; Load the low byte value , just store it in the byte pointed to
						; This is for testing, we'll put 0 in production
	STA (CELLBYTEADDRESS)

	; See if we have hit the start address, if so , move on to test
	LDA #PLAYFIELDSTART
	CMP CELLBYTEADDRESS
	BNE LOOPZEROMEM
	LDA #>PLAYFIELDSTART
	CMP CELLBYTEADDRESS+1
	BNE LOOPZEROMEM
	; If we get here, low and high match PLAYFIELDSTART low and high, we reached the end, test
	JMP TESTPLAYFIELD

LOOPZEROMEM:
	; Decrement the address, we are zeroing mem backwards
	SEC
	LDA CELLBYTEADDRESS
	SBC #1
	STA CELLBYTEADDRESS
	LDA CELLBYTEADDRESS+1
	SBC #0
	STA CELLBYTEADDRESS+1
	JMP ZEROMEM; We'll break out when CELLBYTEADDRESS == PLAYFIELDSTART

TESTPLAYFIELD:
	LDX #28
	LDY #$01
	JSR GETCELLVALUE
	LDY #$02
	JSR GETCELLVALUE
	LDY #$1F
	JSR GETCELLVALUE
	BRK; Just halt for testing for now

; Calling convention is Column is in X, Row is in Y register. Return bit status in in A
GETCELLVALUE:
	LDA #PLAYFIELDSTART
	STA CELLBYTEADDRESS

	CLC
	TYA ; Put the Y row index in A
	; Multiply by 4 (we assume 4 byte wide rows), this is the address offset for the row header
	ASL A 
	ASL A
	ADC CELLBYTEADDRESS ; Move the cellbyteaddress to the first byte in the row.
	STA CELLBYTEADDRESS
	LDA #$00
	ADC CELLBYTEADDRESS+1
	STA CELLBYTEADDRESS+1
	
	; For easy tracing in the debugger
	LDA CELLBYTEADDRESS+1
	LDA CELLBYTEADDRESS

	; Now that we have the row header, lets get the column address then we'll find the bit in question
	TXA
	LDX #0
	; Calculate the byte address offset based on the column value
CMP24:
	CMP #24
	BLT CMP16
	LDX #3
	JMP GETBIT
CMP16:
	CMP #16
	BLT CMP8
	LDX #2
	JMP GETBIT
CMP8:
	CMP #8
	BLT GETBIT
	LDX #1
	JMP GETBIT
GETBIT:
	LDA (CELLBYTEADDRESS,X)
	RTS
;This code is here in case the system gets an NMI.  It clears the intterupt flag and returns.
unexpectedInt:		; $FFE0 - IRQRVD2(134)
	PHP
	PHA
	LDA #$FF
	
	;clear Irq
	PLA
	PLP
	RTI

IRQHandler:
		PLA
		RTI

;***************************************************************************
vectors	SECTION OFFSET $FFFA
					;65C02 Interrupt Vectors
					; Common 8 bit Vectors for all CPUs

		DW	unexpectedInt		; $FFFA -  NMIRQ (ALL)
		DW	START		        ; $FFFC -  RESET (ALL)
		DW	IRQHandler      	; $FFFE -  IRQBRK (ALL)

    ends

END ; CODE