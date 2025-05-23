REM ElapsedTimerDisplay make.bat file
REM 03/17/2024

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -G -L -DUSING_02 -I ..\drivers ElapsedTimerDisplay.asm
WDC02AS -G -L -DUSING_02 ..\drivers\elapsed_timer\Timer.asm -O Timer.obj
WDC02AS -G -L -DUSING_02 ..\drivers\seven_segment_display\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj

REM build the Intel HEX file then output to VHD ROM file. Note the address for -C must match expected start address
REM in VHDL pkg_6502.vhd 
WDCLN -CFC00 -HI ElapsedTimerDisplay Timer.obj SevenSegmentDisplay.obj -O .\ElapsedTimerDisplay.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\ElapsedTimerDisplay.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd

REM Build the simulator exe. 
WDCLN -CFC00 -G -SZ -T -V -HZ ElapsedTimerDisplay Timer.obj SevenSegmentDisplay.obj

REM Start the simulator
REM WDCDB.exe
