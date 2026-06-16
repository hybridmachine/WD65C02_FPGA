REM I2C Logger test make.bat file
REM 12/14/2024

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -I../../common -G -L -DUSING_02 TestI2CLogger.asm
WDC02AS -I../../common -G -L -DUSING_02 ..\I2CLogger.asm -o I2CLogger.obj
REM WDC02AS -g -l -DUSING_02 ..\..\seven_segment_display\SevenSegmentDisplay.asm -O SevenSegmentDisplay.obj
REM WDC02AS -g -l -DUSING_02 ..\..\..\POST\MemTest\MemTest.asm -O MemTest.obj
REM build the Intel HEX file then output to VHD ROM file. Note the address for -C must match expected start address
REM in VHDL pkg_6502.vhd 
WDCLN -CFC00 -HI TestI2CLogger I2CLogger.obj -O .\TestI2CStreamer.hex
REM python ..\..\..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\TestI2CStreamer.hex --vhd_template "..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFFF --output_vhd ROM.vhd
REM Deploy ROM
REM cp .\ROM.vhd '..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd'
REM
REM Build for the simulator. 
WDCLN -CFC00 -G -SZ -T -V -HZ TestI2CLogger I2CLogger.obj

REM Start the simulator
REM WDCDB.exe
