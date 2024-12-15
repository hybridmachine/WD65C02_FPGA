REM I2C Streamer test make.bat file
REM 12/14/2024

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -G -L -DUSING_02 TestI2CStreamer.asm
WDC02AS -G -L -DUSING_02 ..\I2CStreamer.asm -o I2CStreamer.obj

REM build the Intel HEX file then output to VHD ROM file. Note the address for -C must match expected start address
REM in VHDL pkg_6502.vhd 
WDCLN -CFC00 -HI TestI2CStreamer I2CStreamer.obj -O .\TestI2CStreamer.hex
python ..\..\..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\TestI2CStreamer.hex --vhd_template "..\..\..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM Build for the simulator. 
WDCLN -CFC00 -G -SZ -T -V -HZ TestI2CStreamer I2CStreamer.obj

REM Start the simulator
REM WDCDB.exe