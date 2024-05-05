;***************************************************************************
;  FILE_NAME: GameOfLife_BitBoard.asm
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
;  DESCRIPTION: Version of GameOfLife that uses the new BitBoard library with row pointers to speed up bit get/set operations
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
    INCLUDE "inc/Trace.inc"
    INCLUDE "elapsed_timer/Timer.inc"
    INCLUDE "seven_segment_display/SevenSegmentDisplay.inc" 

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
    ; uint8 GetNeighborCount(uint16 baseAddr, uint8 x, uint8 y, uint8 width:ARG3)
    XREF SUB_GET_LIVE_NEIGHBOR_COUNT

    ; void TimerStart(void)
    XREF TIMER_START
    ; uint32 TimerRead(void); Note timer will return four bytes on stack, caller must push four empty bytes before call
    XREF TIMER_READ
    ; void TimerReset(void)
    XREF TIMER_RESET

;***************************************************************************
;                              External Variables
;***************************************************************************
;None


;***************************************************************************
;                               Local Constants
;***************************************************************************

    BOARD_WIDTH:          equ    40
    BOARD_HEIGHT:         equ    40
    ROW_PTRS_ARRAY_LEN:   equ    2*BOARD_HEIGHT
    BOARD1_BASE_ADDR:     equ    $0300
    BOARD2_BASE_ADDR:     equ    BOARD1_BASE_ADDR+(BOARD_WIDTH*BOARD_HEIGHT)+ROW_PTRS_ARRAY_LEN
    CELL_DEAD:            equ    0
    CELL_LIVE:            equ    1
    ; Argument positions for BitBoard subroutines
    COL_X:                equ    ARG1   ; x    
    ROW_Y:                equ    ARG2   ; y
    CELL_STATUS:          equ    ARG3   ; bit on/off
    CURRENT_GEN:          equ    GAMEBOARDS ; Current gen is at the base of GAMEBOARES 4 bytes range
    NEXT_GEN:             equ    CURRENT_GEN+2; Pointer for next gen right after current gen
    NBR_CNT:              equ    SCRATCH ; Use first scratch position for neihbor count
;***************************************************************************
;                               Application Code
;***************************************************************************

START:
	sei             ; Ignore maskable interrupts
        clc             ; Clear carry
    	cld             ; Clear decimal mode

	ldx	#$ff		; Initialize the stack pointer
	txs

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
        lda #CELL_DEAD          ; initval CELL_DEAD
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
        lda #CELL_DEAD          ; initval CELL_DEAD
        sta ARG3 
        jsr SUB_INITBOARD

LOAD_R_PENTOMINO:
        ; Load an R-Pentomino into gameboard
        ;   **
        ;  **
        ;   *
        ; Set the current gen board as the board we are operating on
        lda #BOARD1_BASE_ADDR
        sta PTR1 
        lda #>BOARD1_BASE_ADDR
        sta PTR1+1
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2-1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2+1
        sta COL_X
        lda #BOARD_HEIGHT/2-1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2-1
        sta COL_X
        lda #BOARD_HEIGHT/2
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT
        lda #BOARD_WIDTH/2
        sta COL_X
        lda #BOARD_HEIGHT/2+1
        sta ROW_Y
        lda #CELL_LIVE
        sta CELL_STATUS
        jsr SUB_SETBIT

        ; Establish board pointers
        ; Set the current gen board as the board we are reading from on
        lda #BOARD1_BASE_ADDR
        sta CURRENT_GEN 
        lda #>BOARD1_BASE_ADDR
        sta CURRENT_GEN+1

        ; Set the next gen board as the board we are operating on
        lda #BOARD2_BASE_ADDR
        sta NEXT_GEN 
        lda #>BOARD2_BASE_ADDR
        sta NEXT_GEN+1
LOOP_TIMER:
        jsr SUB_TIMER_START ; Reset the timer
        ; Loop over 100 generations
        lda #100 ; cnt = 100
LOOP_GENS:
        pha ; save current value of cnt to stack

        ; Calculate next gen (reads from CURRENT_GEN and writes to NEXT_GEN)
        jsr PRIV_CALCULATE_NEXT_GEN

        ; Swap generations (NEXT_GEN becomes CURRENT_GEN, and vice versa)
        jsr PRIV_SWAP_GENERATIONS

        ; Test loop condition
        pla ; load cnt off stack
        sec
        sbc #1 ; cnt--
        bne LOOP_GENS ; if (cnt != 0) then loop
        
        TIMER_READ SCRATCH
        SEVENSEG_DISPLAY_VALUE SCRATCH
        jmp LOOP_TIMER ; Loop forever

PRIV_CALCULATE_NEXT_GEN:
        ldx #1
        ldy #1
        tya
        sta ROW_Y
        phy ; Save off row position
LOOP_COL:
        phx ; Save off column position
        txa
        sta COL_X
        ; ROW_Y is already loaded

        ; Load current gen pointer and get the nbr cnt
        lda CURRENT_GEN
        sta PTR1
        lda CURRENT_GEN+1
        sta PTR1+1

        ; Save off args
        lda COL_X
        pha
        lda ROW_Y
        pha

        jsr SUB_GET_LIVE_NEIGHBOR_COUNT
        sta NBR_CNT ; Save off nbr count

        pla ; Restore row position
        beq ROW_HAS_ZERO
        sta ROW_Y

        pla ; Restore column position
        beq COL_HAS_ZERO
        sta COL_X
        jmp GET_NEXT_GEN ; Jump over the debug breaks

ROW_HAS_ZERO:
        brk ; Debug, stop if our index is wrong
COL_HAS_ZERO:
        brk ; Debug, stop if our index is wrong

GET_NEXT_GEN:
        ; Calculate the next generation
        lda NEXT_GEN
        sta PTR1
        lda NEXT_GEN+1
        sta PTR1+1
        
        ; Subroutine to generate the next generation for the game of life
        ;   Any live cell with fewer than two live neighbours dies, as if by underpopulation.
                ; if CNT < 2 then CELL_STATUS = CELL_DEAD
        ;   Any live cell with two or three live neighbours lives on to the next generation.
                ; if CNT == 2 then CELL_STATUS = CELL_SAME
                ; if CNT == 3 then CELL_STATUS = CELL_LIVE
        ;   Any live cell with more than three live neighbours dies, as if by overpopulation.
                ; if CNT > 3 then CELL_STATUS = CELL_DEAD
        ;   Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction
                ; if CNT == 3 then CELL_STATUS = CELL_LIVE (covered above so no need to re-check)

        lda NBR_CNT
        cmp #2
        bmi SET_CELL_DEAD       ; if CNT < 2 then CELL_STATUS = CELL_DEAD
        beq SET_CELL_SAME       ; if CNT == 2 then CELL_STATUS = CELL_SAME
        cmp #3
        beq SET_CELL_LIVE       ; if CNT == 3 then CELL_STATUS = CELL_LIVE
        bpl SET_CELL_DEAD       ; if CNT > 3 then CELL_STATUS = CELL_DEAD
        brk ; Shouldn't ever get here
SET_CELL_DEAD:
        lda #CELL_DEAD
        sta CELL_STATUS

        jsr DBG_TEST_CURGEN
        jsr SUB_SETBIT
        jsr DBG_TEST_CURGEN
        
        jmp TEST_FOR_LOOP
        
SET_CELL_LIVE:
        TRACELOC #01
        lda #CELL_LIVE
        sta CELL_STATUS
        
        jsr DBG_TEST_CURGEN
        jsr SUB_SETBIT
        jsr DBG_TEST_CURGEN
        
        jmp TEST_FOR_LOOP

SET_CELL_SAME:
        TRACELOC #02
        ; Load current gen pointer and get current status
        lda CURRENT_GEN
        sta PTR1
        lda CURRENT_GEN+1
        sta PTR1+1

        jsr SUB_GETBIT
        sta CELL_STATUS

        ; Point to next gen
        lda NEXT_GEN
        sta PTR1
        lda NEXT_GEN+1
        sta PTR1+1

        jsr DBG_TEST_CURGEN
        jsr SUB_SETBIT
        jsr DBG_TEST_CURGEN
        
        jmp TEST_FOR_LOOP

TEST_FOR_LOOP:
        plx
        inx
        cpx #BOARD_WIDTH-1
        bne LOOP_COL_BRA
        jmp LOOP_ROW ; Could just fall through but lets be explicit for clarity
LOOP_COL_BRA:
        jmp LOOP_COL
LOOP_ROW:
        ply
        iny
        cpy #BOARD_HEIGHT-1
        beq RETURN_TO_CALLER
        ldx #1
        phy ; Save off Y for
        tya 
        sta ROW_Y ; Upload row argument
        jmp LOOP_COL

RETURN_TO_CALLER:
        rts

; Something is clobbering the low byte of curgen after a swap, catch it in the act here
DBG_TEST_CURGEN
        ; DEBUG
        lda CURRENT_GEN+1
        cmp #$09
        bne ENDDBG
        lda CURRENT_GEN
        cmp #$90
        beq ENDDBG
        brk ; Something messed up the address
        ; END DEBUG
ENDDBG:
        rts

PRIV_SWAP_GENERATIONS:
        ; Save CURRENT_GEN to tmp
        lda CURRENT_GEN
        sta SCRATCH
        lda CURRENT_GEN+1
        sta SCRATCH+1

        ; Save NEXT_GEN to CURRENT_GEN
        lda NEXT_GEN
        sta CURRENT_GEN
        lda NEXT_GEN+1
        sta CURRENT_GEN+1

        ; Load previous CURRENT_GEN ptr into NEXT_GEN
        lda SCRATCH
        sta NEXT_GEN
        lda SCRATCH+1
        sta NEXT_GEN+1

        ; Return to caller
        rts

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