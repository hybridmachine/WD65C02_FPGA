;***************************************************************************
;  FILE_NAME: MemoryMap.inc
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
;  DESCRIPTION: Map of start,end ranges for PIO, ROM, and RAM. This file shadows PKG_65C02.vhd
;  Well known locations (page 0, stack, interrupt and pro start vectors) are not mapped here, only
;  PIO, ROM, and RAM locations
;
;
;***************************************************************************    

    MEM_MAPPED_IO_BASE:			    GEQU $0200 ; 
    PIO_PSRND_VAL:                  GEQU $0229 ;
    MEM_MAPPED_IO_END:              GEQU $03FF ;

    RAM_BASE:                   GEQU $0400; 
    RAM_END:                    GEQU $F9FF;

    ROM_END:                    GEQU $FFFF;
    ROM_BASE:                   GEQU $FB00;