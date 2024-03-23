REM Template make.bat file
REM MM/DD/YYYY

REM Clean up
del *.bin
del *.obj
del *.lst
del *.sym

REM Compile asm to object files
WDC02AS -G -L -DUSING_02 <TopLevelModule>.asm
WDC02AS -G -L -DUSING_02 <NextLevelModule(s)>.asm
WDC02AS -G -L -DUSING_02 ..\lib\<LibModule>.asm -O <LibModule>.obj

REM build the Intel HEX file then output to VHD ROM file. Note the address for -C must match expected start address
REM in VHDL pkg_6502.vhd 
WDCLN -CFC00 -HI <NameOfExe> <Included>.obj <Included>.obj -O .\<NameOfExe>.hex
python ..\HexToVHDLTools\ConvertHexToVHD_ROM.py --hex_file .\<NameOfExe>.hex --vhd_template "..\..\WD6502 Computer.srcs\sources_1\new\ROM.vhd" --start_address 0xFC00 --end_address 0xFFF9 --output_vhd ROM.vhd

REM Build the simulator exe. 
WDCLN -CFC00 -G -SZ -T -V -HZ <NameOfExe> <Included>.obj <Included>.obj

REM Start the simulator
WDCDB.exe
