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
    LOG_BUFFER_IDX:             equ $42 ; The buffer index value ($42, $43)
    MAX_BUF_LEN:                equ $50 ; 80 bytes max
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


; C style string address in X,Y (LOW, HIGH). Null terminated max 80 characters (auto return at 80 chars)
; Returns bytes written in A
LOGSTR:
    ; Reset data and log buffer. We flush our strings at the end of every write
    STZ LOG_BUFFER_IDX
    STZ LOG_BUFFER_IDX+1

    TXA
    STA LOG_STR_PTR
    TYA
    STA LOG_STR_PTR+1

LOOP_WRITE:
	; Load string data
	LDY LOG_BUFFER_IDX
	LDA (LOG_STR_PTR),Y
	BEQ FLUSH ; If we hit the null, stream the buffer.
	
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

; Write byte value in A to log buffer
LOGBYTE:
    RTS

; Write stream to I2C
FLUSH:
    CLI ; Ensure interrupts enabled
	JSR SUB_I2CSTREAM_STREAM
    RTS

END ; CODE