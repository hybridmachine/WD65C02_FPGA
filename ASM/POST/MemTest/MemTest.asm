;***************************************************************************
;  FILE_NAME: MemTest.asm
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
;  DESCRIPTION: Write to then read back from RAM
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
	GLOBAL POST_MEMORY_TEST

;***************************************************************************
;                              External Modules
;***************************************************************************
; Driver functions
    XREF SUB_SEVENSEG_DISPLAY_VALUE
    XREF SUB_SEVENSEG_DISABLE

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************
;
	ADDRESS_PTR:    		equ $02
	ADDRESS_LOW:			equ ADDRESS_PTR
	ADDRESS_HIGH:			equ ADDRESS_PTR+1
	MEM_TO_TEST_START:		equ ADDRESS_HIGH+1
	MEM_MAPPED_IO_END: 		equ $03FF
    MEM_MAPPED_IO_BASE: 	equ $0200
	RAM_END:				equ $FBFF
	LED_IO_ADDR:	    	equ	$0200


;***************************************************************************
;                               Library Code
;***************************************************************************
;

POST_MEMORY_TEST:
		; Load a test pattern on 00 and 01, make sure nothing changes this pattern, if it does,
		; the FPGA memory manager is accidentally writing to the 0 address when it wasn't requested
		lda #$ED
		sta $00
		lda #$FE
		sta $01 

		; Load starting address (first byte after our address pointer bytes)
		lda #MEM_TO_TEST_START
		sta ADDRESS_LOW
		lda #$00
		sta ADDRESS_HIGH


		ldx #$00

WRITE_LOOP:
		lda ADDRESS_HIGH
		sta LED_IO_ADDR ; Display the high byte of the address on the LEDs
		inx
		txa
		sta (ADDRESS_PTR)
		cpa (ADDRESS_PTR)
		beq INCREMENT_ADDRESS
		jmp ERROR_FAIL 	; If value in address != X, write or read failed , jump to fail code

INCREMENT_ADDRESS:	
		; Increment the address
		clc
		lda ADDRESS_LOW
		adc #$01
		sta ADDRESS_LOW
		lda ADDRESS_HIGH
		adc #$00 ; Add in any carry flag
		sta ADDRESS_HIGH

SKIP_STACK:
		lda ADDRESS_HIGH
		cmp #$01
		bne SKIP_MEMMAPPEDIO_LOW
		jmp INCREMENT_ADDRESS ; If high byte is 01, we are in the stack zone, keep incrementing

SKIP_MEMMAPPEDIO_LOW:
		lda ADDRESS_HIGH
		cmp #$02
		bne SKIP_MEMMAPPEDIO_HIGH
		jmp INCREMENT_ADDRESS ; If high byte is 02, we are in low end of mem mapped IO

SKIP_MEMMAPPEDIO_HIGH:
		lda ADDRESS_HIGH
		cmp #$03
		bne IF_AT_END_OF_RAM
		jmp INCREMENT_ADDRESS ; If high byte is 03, we are in high end of mem mapped IO

IF_AT_END_OF_RAM:
		lda ADDRESS_HIGH
		cmp #(RAM_END>>8)
 		beq IF_AT_END_OF_RAM_2
		jmp WRITE_LOOP ; Not at end of RAM

IF_AT_END_OF_RAM_2:
		; High byte matches, check low byte
		lda ADDRESS_LOW
		cmp #RAM_END ; Gets low byte
		beq RETURN_TO_CALLER
		jmp WRITE_LOOP ; Not at end of RAM

RETURN_TO_CALLER:
		rts

ERROR_FAIL:
		; Display the address
		; Load hi then low on to stack, call display function
		lda ADDRESS_HIGH
		pha
		lda ADDRESS_LOW
		pha
		jsr SUB_SEVENSEG_DISPLAY_VALUE
		; Cleanup stack
		pla
		pla
		jsr SUB_DELAY

		; Display AA<VALUE>
		lda #$AA
		pha
		lda (ADDRESS_PTR)
		pha
		jsr SUB_SEVENSEG_DISPLAY_VALUE
		; Cleanup stack
		pla
		pla
		jsr SUB_DELAY

		jmp ERROR_FAIL
		brk

SUB_DELAY:
DELAY_OUTER_LOOP:
		ldx #$FF
		; If Y == 0 read timer
		dey
		beq RETURN_DELAY
DELAY_INNER_LOOP:
		dex
		; If X > 0 repeat X--
		bne DELAY_INNER_LOOP
		jmp DELAY_OUTER_LOOP
RETURN_DELAY:
		rts

SUB_TEST_PAGE_ZERO:
		; Expectation is caller will set ADDRESS_PTR if we return successfully
		lda #$00
		sta ADDRESS_LOW
		lda #$00
		sta ADDRESS_HIGH

		lda #$ED
		cmp (ADDRESS_PTR)
		bne ERROR_FAIL
		
		clc
		lda #$01
		sta ADDRESS_LOW

		lda #$FE
		cmp (ADDRESS_PTR) 
		bne ERROR_FAIL

		rts

END ; CODE