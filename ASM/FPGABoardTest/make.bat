REM Make system test
REM 05/25/2024

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -G -L -I ..\drivers -I ..\inc -DUSING_02 SystemTest.asm
WDC02AS -G -L -K Timer.lst -DUSING_02 ..\drivers\elapsed_timer\Timer.asm -O Timer.obj
WDC02AS -G -L -K SevenSegmentDisplay.lst -DUSING_02 ..\drivers\seven_segment_display\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj

REM build the Intel HEX file then output to VHD ROM file. Note the address for -C must match expected start address
REM in VHDL pkg_6502.vhd 
WDCLN -CFC00 -HI SystemTest Timer.obj SevenSegmentDisplay.obj -O .\SystemTest.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\SystemTest.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM Build for the simulator. 
WDCLN -CFC00 -G -SZ -T -V -HZ SystemTest Timer.obj SevenSegmentDisplay.obj

REM Start the simulator
REM WDCDB.exe
