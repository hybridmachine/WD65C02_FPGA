;***************************************************************************
;  FILE_NAME: TestBitBoard.asm
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
;  DESCRIPTION: Test harness for the Game Of Life bitboard module
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

    INCLUDE "inc/PageZero.inc"    ; Page zero usage locations
    INCLUDE "inc/GameOfLifeConstants.inc"


;***************************************************************************
;                              Global Modules
;***************************************************************************
;None

;***************************************************************************
;                              External Modules
;***************************************************************************

    ; void InitBoard(uint16 baseAddr, uint8 width, uint8 height, uint8 initVal)
    XREF SUB_INITBOARD
    ; void SetBit(uint16 baseAddr, uint8 x, uint8 y, uint8 bit)
    XREF SUB_SETBIT
    ; uint8 GetBit(uint16 baseAddr, uint8 x, uint8 y)
    XREF SUB_GETBIT
    ; void LoadRPentomino(uint16 baseAddr)
    XREF SUB_LOAD_R_PENTOMINO
    ; uint8 GetLiveNeighborCount(uint16 baseAddr, uint8 x, uint8 y)
    XREF SUB_GET_LIVE_NEIGHBOR_COUNT

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************

    
    TEST_PATTERN:         equ    $CC
START:
		sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

		ldx	#$ff		; Initialize the stack pointer
		txs

;***************************************************************************
;                               Application Code
;***************************************************************************

        ; Initialize board 1
        ; baseAddr
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #TEST_PATTERN       ; initval $CC
        sta ARG3  
        jsr SUB_INITBOARD

        ; Initialize board 2
        lda #BOARD2_BASE_ADDR
        sta PTR1
        lda #>BOARD2_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #TEST_PATTERN-$11    ; initval $BB
        sta ARG3 
        jsr SUB_INITBOARD

        ; Set individual pixel 1,5 (0 indexed) off
        ; Setup arguments to set bit
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #1
        sta ARG1
        lda #5
        sta ARG2
        lda #CELL_DEAD
        sta ARG3
        jsr SUB_SETBIT

        ; Get individual pixel and test its value. First check
        ; a bit that should be at test_pattern then check a bit that should be at cell_dead
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #2
        sta ARG1
        lda #5
        sta ARG2
        jsr SUB_GETBIT
        CMP #TEST_PATTERN
        beq TEST2
        jmp FAIL_TEST

TEST2:
        lda #1
        sta ARG1
        lda #5
        sta ARG2
        jsr SUB_GETBIT
        CMP #CELL_DEAD
        beq TEST3
        jmp FAIL_TEST

TEST3:
        ; Initialize board 1
        ; baseAddr
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH        ; width
        sta ARG1
        lda #BOARD_HEIGHT       ; height
        sta ARG2
        lda #CELL_DEAD       ; initval $00
        sta ARG3  
        jsr SUB_INITBOARD

        ; Load a test pattern into the board and check the neighbor count subroutines
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        jsr SUB_LOAD_R_PENTOMINO

TEST_TOP_LEFT_EMPTY:
        lda #1
        sta ARG1
        lda #1
        sta ARG2
        jsr SUB_GETBIT
        cmp #CELL_DEAD ; Expect cell to be active
        bne FAIL_TEST
        lda #BOARD_WIDTH
        sta ARG3
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        cmp #0 ; Expect 0 neighbors
        bne FAIL_TEST

TEST_BOTTOM_RIGHT_EMPTY:
        lda #BOARD_WIDTH-2
        sta ARG1
        lda #BOARD_HEIGHT-2
        sta ARG2
        jsr SUB_GETBIT
        cmp #CELL_DEAD ; Expect cell to be active
        bne FAIL_TEST
        lda #BOARD_WIDTH
        sta ARG3
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        cmp #0 ; Expect 0 neighbors
        bne FAIL_TEST

        lda #BOARD_WIDTH/2
        sta ARG1
        lda #BOARD_HEIGHT/2-1
        sta ARG2
        jsr SUB_GETBIT
        cmp #CELL_LIVE ; Expect cell to be active
        bne FAIL_TEST
        lda #BOARD_WIDTH
        sta ARG3
        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        cmp #3 ; Expect 3 neighbors
        bne FAIL_TEST
        
        lda #BOARD_WIDTH/2
        sta ARG1
        lda #BOARD_HEIGHT/2
        sta ARG2
        jsr SUB_GETBIT
        cmp #CELL_LIVE ; Expect cell to be active
        bne FAIL_TEST
        lda #BOARD_WIDTH
        sta ARG3

        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        cmp #4 ; Expect 4 neighbors
        bne FAIL_TEST
        
        brk


FAIL_TEST:
        brk

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