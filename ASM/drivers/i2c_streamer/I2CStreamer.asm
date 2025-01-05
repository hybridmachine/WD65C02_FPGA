;***************************************************************************
;  FILE_NAME: I2CStreamer.asm
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
;  DESCRIPTION: Driver for sending data (outbound only) via the I2C interface
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
; Public functions
    
    ; Returns status byte in X register
    GLOBAL SUB_I2CSTREAM_GETSTATUS

    ; Y: address high, X: address low, Accumulator: Byte to write to buffer
    ; Returns success/error in accumulator after write attempt
    GLOBAL SUB_I2CSTREAM_WRITEBYTE

    ; Tell the I2C subsystem to stream buffer out over I2C system
    ; This is async, stream starts and function returns, callers
    ; should read status to determine when stream is complete
    GLOBAL SUB_I2CSTREAM_STREAM

    ; Initialize the I2C Interface. Address for I2C is in accumulator (Only high 7 bits are read, low bit is unused).
    ; If value is 0, default address is used. Default address is left in accumulator, callers can check it to find the value
    GLOBAL SUB_I2CSTREAM_INITIALIZE

;***************************************************************************
;                              Macros
;***************************************************************************
SEND_CONTROL_BYTE MACRO CONTROL_BYTE
    LDA CONTROL_BYTE
    STA PIO_I2C_DATA_STRM_CTRL
    NOP
    NOP 
    ENDM

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
    ; Memory addresses for I2C interface
    PIO_I2C_DATA_STRM_STATUS:               equ $0212
    PIO_I2C_DATA_STRM_CTRL:                 equ $0213
    PIO_I2C_DATA_STRM_DATA_ADDRESS_LOW:     equ $0214
    PIO_I2C_DATA_STRM_DATA_ADDRESS_HIGH:    equ $0215
    PIO_I2C_DATA_STRM_DATA:                 equ $0216
    PIO_I2C_DATA_STRM_I2C_ADDRESS:          equ $0217 ; High 7 bits is address, least significant bit is used internally (any value here is ignored, leave 0)
    
    ; Control values for I2C interface
    CONTROL_RESET:                          equ $00
    CONTROL_WRITE_BUFFER:                   equ $01
    CONTROL_STREAM_BUFFER:                  equ $02
    CONTROL_STANDBY:                        equ $03

    STATUS_SUCCESS:                         equ $00 
    DEFAULT_I2C_ADDRESS:                    equ $76 ; 0111 011X

;***************************************************************************
;                               Library Code
;***************************************************************************
;

; Initialize the I2C Interface. Address for I2C is in accumulator (Only high 7 bits are read, low bit is unused).
; If value is 0, default address is used. Default address is left in accumulator, callers can check it to find the value
SUB_I2CSTREAM_INITIALIZE:
    ; Save off accumulator then reset the I2C interface then set it to stanby
    PHA
    SEND_CONTROL_BYTE CONTROL_RESET
    SEND_CONTROL_BYTE CONTROL_STANDBY
    ; Reload the accumulator and set the I2C target address
    PLA
    BNE I2C_SET_ADDRESS ; If 0 , we'll first load default address in accumulator
    LDA #DEFAULT_I2C_ADDRESS
I2C_SET_ADDRESS
    STA PIO_I2C_DATA_STRM_I2C_ADDRESS
    RTS

; Returns status byte in X register
SUB_I2CSTREAM_GETSTATUS:
    ; TODO we need to investigate how to properly move data from the faster FPGA clock domain out to the CPU since
    ; this value can change at FPGA speed but is read at CPU speed (100mhz vs 2mhz)
    LDX PIO_I2C_DATA_STRM_STATUS
    RTS

; Y: address high, X: address low, Accumulator: Byte to write to buffer
; Returns success/error in accumulator after write attempt
SUB_I2CSTREAM_WRITEBYTE:
    STY PIO_I2C_DATA_STRM_DATA_ADDRESS_HIGH
    STX PIO_I2C_DATA_STRM_DATA_ADDRESS_LOW
    STA PIO_I2C_DATA_STRM_DATA

    ; Tell I2C to write the byte to the address
    SEND_CONTROL_BYTE #CONTROL_WRITE_BUFFER

    ; Place I2C in standby for next command
    SEND_CONTROL_BYTE #CONTROL_STANDBY
    
    LDA #STATUS_SUCCESS
    RTS

; Tell the I2C subsystem to stream buffer out over I2C system
; This is async, stream starts and function returns, callers
; should read status to determine when stream is complete
; Overwrites the accumulator, callers should preserve it first if needed.
SUB_I2CSTREAM_STREAM:
    SEND_CONTROL_BYTE #CONTROL_STREAM_BUFFER
    RTS

END ; CODE