;***************************************************************************
;  FILE_NAME: I2CLogger.asm
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
;  DESCRIPTION: I2C logging to allow printf style debugging , users can watch the I2C line for ascii text (or any byte value) using their favorite (Analog Discovery for exmple) data logger
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
	INCLUDE "InterruptTimerCtl.inc"
	INCLUDE "MemoryMap.inc"
    INCLUDE "I2Cconstants.inc"


;***************************************************************************
;                              Global Modules
;***************************************************************************
    GLOBAL LOGSTR
    GLOBAL LOGBYTE
    GLOBAL FLUSH
    GLOBAL INITLOG
    GLOBAL HIGH_NIBBLE_TO_HEX
    GLOBAL LOW_NIBBLE_TO_HEX

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
;

    DEFAULT_I2C_DBG_ADDRESS:    equ $0D
    LOG_STR_PTR:				equ $40 ; The active pointer address ($40, $41)
    LOG_BUFFER_IDX:             equ #LOG_STR_PTR+2 ; The buffer index value ($42, $43)
    STACK_ARG_IDX:              equ #LOG_BUFFER_IDX+2 ; One byte index of which stack arg to read
    MAX_BUF_LEN:                equ $50 ; 80 bytes max
    STACK_BASE_ADDR:            equ $0100
;***************************************************************************
;                               Library Code
;***************************************************************************
;
    ; Initialize the buffer and setup the address; If 0 is in A, default address is used, otherwise user can 
    ; specify desired address in the A register. Legal values are 0x08 to 0x77
INITLOG:
    ; If A is not 0, check address range, otherwise we'll set default
    BNE CHECK_LOW_RESERVED
    LDA #DEFAULT_I2C_DBG_ADDRESS
    JMP SET_LEGAL_ADDRESS ; No need to check if we are using our builtin default
CHECK_LOW_RESERVED:   
    CMP #I2C_RESERVED_LOW_END_ADDRESS+1
    BCS CHECK_HIGH_RESERVED
    LDA #$FF ; Set A to -1 for error return
    RTS
CHECK_HIGH_RESERVED:
    CMP #I2C_RESERVED_HIGH_END_ADDRESS
    BCC SET_LEGAL_ADDRESS
    LDA #$FF ; Set A to -1 for error return
    RTS
SET_LEGAL_ADDRESS:
    ; I2C address will be in A already    
	JSR SUB_I2CSTREAM_INITIALIZE
    STZ LOG_BUFFER_IDX;
    STZ LOG_BUFFER_IDX+1;
    LDA #$00 ; Return status success
    RTS


; Print format string with16 bit hexadecimal values, one for each %X in the fmt string (case sensitive)
; Not trying to be a full printf, just simple hex values. Calling convention is
; Push low byte val, push high byte val, put string address in X,Y (LOW, HIGH).
; This function will stream the string, replacing %X with the 16 bit hex string (0000 - FFFF)
; Note %% prints single %
; Returns bytes written in A
; 
; Example: 
; LDA #$00
; PHA 
; LDA #$FF
; PHA
; LDX, LDY (LOW, HIGH) for "Test string, hex value %X"
; This will stream out (sans quotes) over I2C: "Test string, hex value FF00" with return of 27 for bytes written
LOGSTR:
    ; Reset data and log buffer. We flush our strings at the end of every write
    STZ LOG_BUFFER_IDX
    STZ LOG_BUFFER_IDX+1
    STZ STACK_ARG_IDX
    
    TXA
    STA LOG_STR_PTR
    TYA
    STA LOG_STR_PTR+1

LOOP_WRITE:
	; Load string data
	LDY LOG_BUFFER_IDX
	LDA (LOG_STR_PTR),Y
	BEQ FLUSH ; If we hit the null, stream the buffer.
	CMP #"%"
    BNE WRITESTR
    INY
    LDA (LOG_STR_PTR),Y
	CMP #"X"
    BNE NOFORMAT
    ; Read low byte and convert to hex, stream those bytes, then do same for highbyte
    TSX ; Load stack pointer into X
    INX ; Move pointer to return address Low        
    INX ; Move pointer over return address High
    INX ; Move pointer over return address to first free space
    ; Transfer value in stack to output address
    LDA STACK_BASE_ADDR,X ; Load low byte
NOFORMAT:
    DEY
    LDA (LOG_STR_PTR),Y ; Just a regular %, so write as usual
WRITESTR:
	; Set stream buffer address to write to
	LDY LOG_BUFFER_IDX+1
	LDX LOG_BUFFER_IDX
	JSR SUB_I2CSTREAM_WRITEBYTE
	BEQ BYTE_BUFFERED ; accumulator should be set to 0 for success
	; TODO Handle error condition

BYTE_BUFFERED:

    LDA LOG_BUFFER_IDX
    INA ; Avoid the compare to 0 issue with CMP
    CMP #MAX_BUF_LEN; Test have we hit the end of the buffer
    BEQ FLUSH

    ; 16 bit add, not really needed for max buf len < 255 but just in case we expand later
    CLC
	LDA LOG_BUFFER_IDX
	ADC #$01
    STA LOG_BUFFER_IDX
    LDA LOG_BUFFER_IDX+1
    ADC #$00 ; Add in the cary flag if set
    STA LOG_BUFFER_IDX+1

	JMP LOOP_WRITE ; 

    RTS

LOW_NIBBLE_TO_HEX:
    AND #$0F
    CMP #$09
    BCS ATOF ; Branch greater than
    CLC
    ADC #"0" ; Add ascii 0 start value
    RTS
ATOF:
    SEC
    SBC #$0A
    CLC
    ADC #"A"
    RTS

; High Nibble To HEX
; Read the higher 4 bits and convert value to Hex
; A will contain the ASCII 0-F when done
HIGH_NIBBLE_TO_HEX:
    AND #$F0 ; Set value in A to lower 4 bits
    ; Shift right 4 bits (0 fill on the left)
    LSR
	LSR
	LSR
	LSR
    JSR LOW_NIBBLE_TO_HEX
    RTS
    

; Write byte value in A to log buffer
LOGBYTE:
    RTS

; Write stream to I2C
FLUSH:
    CLI ; Ensure interrupts enabled
	JSR SUB_I2CSTREAM_STREAM
    RTS

END ; CODE