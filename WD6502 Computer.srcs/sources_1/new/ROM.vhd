----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/08/2023 04:00:45 PM
-- Design Name: 
-- Module Name: rom - inferred_rom
-- Project Name: WD6502 Computer
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.W65C02_DEFINITIONS.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--! \author Brian Tabone
--! @brief Contains the executable that will run when the 65C02 boots
--! @details This ROM file contains the executable that will run when the 65C02 boots. To load it
--! use the Intel HEX to ROM converter ASM\HexToVHDLTools\ConvertHexToVHD_ROM.py . See an example of its usage in
--! ASM\SieveOfEratosthenes\make.bat
entity ROM is
    PORT (
	addra: IN std_logic_VECTOR(15 downto 0); --! Address to be read
	clka: IN std_logic; --! Memory clock (typically just FPGA clock)
	douta: OUT std_logic_VECTOR(7 downto 0) --! Data 
  );
end ROM;

-- Adapted from example on Page 516 of "Effective Coding with VHDL"
architecture inferred_rom_arch of ROM is
    subtype BYTE is STD_LOGIC_VECTOR(7 downto 0);
    type ROM_BYTES is array(natural range 0 to 1023) of BYTE;

    constant ROM_DATA : ROM_BYTES := 
        (
              -- ROM CONTENT BEGIN
-- Source File: .\TestI2CStreamer.hex
x"78", x"18", x"D8", x"A2",
x"FF", x"9A", x"20", x"00",
x"FD", x"20", x"06", x"FD",
x"A9", x"00", x"8D", x"00",
x"02", x"20", x"B2", x"FC",
x"C9", x"76", x"F0", x"03",
x"20", x"9C", x"FC", x"20",
x"4C", x"FC", x"20", x"C3",
x"FC", x"8A", x"F0", x"06",
x"8D", x"00", x"02", x"20",
x"9C", x"FC", x"A2", x"00",
x"A0", x"00", x"A9", x"00",
x"48", x"DA", x"5A", x"20",
x"C7", x"FC", x"F0", x"03",
x"20", x"9C", x"FC", x"7A",
x"FA", x"68", x"E8", x"1A",
x"DA", x"48", x"20", x"E9",
x"FC", x"68", x"68", x"D0",
x"E7", x"20", x"E1", x"FC",
x"DA", x"A9", x"80", x"48",
x"A9", x"00", x"48", x"20",
x"70", x"FC", x"68", x"68",
x"FA", x"8E", x"00", x"02",
x"DA", x"A9", x"00", x"48",
x"AD", x"12", x"02", x"48",
x"20", x"E9", x"FC", x"68",
x"68", x"FA", x"E8", x"4C",
x"4C", x"FC", x"00", x"00",
x"BA", x"E8", x"E8", x"E8",
x"BD", x"00", x"01", x"38",
x"E9", x"01", x"90", x"06",
x"9D", x"00", x"01", x"4C",
x"70", x"FC", x"BA", x"E8",
x"E8", x"E8", x"E8", x"38",
x"BD", x"00", x"01", x"F0",
x"0E", x"E9", x"01", x"9D",
x"00", x"01", x"CA", x"A9",
x"FF", x"9D", x"00", x"01",
x"4C", x"70", x"FC", x"60",
x"20", x"E9", x"FC", x"4C",
x"9C", x"FC", x"00", x"00",
x"08", x"48", x"A9", x"FF",
x"68", x"28", x"40", x"68",
x"40", x"01", x"00", x"00",
x"00", x"0A", x"48", x"A5",
x"00", x"8D", x"13", x"02",
x"EA", x"EA", x"68", x"D0",
x"02", x"A9", x"76", x"8D",
x"17", x"02", x"60", x"AE",
x"12", x"02", x"60", x"8C",
x"15", x"02", x"8E", x"14",
x"02", x"8D", x"16", x"02",
x"A9", x"01", x"8D", x"13",
x"02", x"EA", x"EA", x"A9",
x"03", x"8D", x"13", x"02",
x"EA", x"EA", x"A9", x"00",
x"60", x"A9", x"02", x"8D",
x"13", x"02", x"EA", x"EA",
x"60", x"A9", x"01", x"8D",
x"03", x"02", x"BA", x"E8",
x"E8", x"E8", x"BD", x"00",
x"01", x"8D", x"01", x"02",
x"E8", x"BD", x"00", x"01",
x"8D", x"02", x"02", x"60",
x"A9", x"00", x"8D", x"03",
x"02", x"60", x"A9", x"ED",
x"85", x"00", x"A9", x"FE",
x"85", x"01", x"A9", x"04",
x"85", x"02", x"A9", x"00",
x"85", x"03", x"A2", x"00",
x"A5", x"03", x"8D", x"00",
x"02", x"E8", x"8A", x"92",
x"02", x"D2", x"02", x"F0",
x"03", x"4C", x"63", x"FD",
x"18", x"A5", x"02", x"69",
x"01", x"85", x"02", x"A5",
x"03", x"69", x"00", x"85",
x"03", x"A5", x"03", x"C9",
x"01", x"D0", x"03", x"4C",
x"28", x"FD", x"A5", x"03",
x"C9", x"02", x"D0", x"03",
x"4C", x"28", x"FD", x"A5",
x"03", x"C9", x"03", x"D0",
x"03", x"4C", x"28", x"FD",
x"A5", x"03", x"C9", x"FB",
x"F0", x"03", x"4C", x"18",
x"FD", x"A5", x"02", x"C9",
x"FF", x"F0", x"03", x"4C",
x"18", x"FD", x"60", x"A5",
x"03", x"48", x"A5", x"02",
x"48", x"20", x"E9", x"FC",
x"68", x"68", x"20", x"84",
x"FD", x"A9", x"AA", x"48",
x"B2", x"02", x"48", x"20",
x"E9", x"FC", x"68", x"68",
x"20", x"84", x"FD", x"4C",
x"63", x"FD", x"00", x"00",
x"A2", x"FF", x"88", x"F0",
x"06", x"CA", x"D0", x"FD",
x"4C", x"84", x"FD", x"60",
x"A9", x"00", x"85", x"02",
x"A9", x"00", x"85", x"03",
x"A9", x"ED", x"D2", x"02",
x"D0", x"C5", x"18", x"A9",
x"01", x"85", x"02", x"A9",
x"FE", x"D2", x"02", x"D0",
x"BA", x"60", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"00", x"00",
x"00", x"00", x"A4", x"FC",
x"00", x"00", x"00", x"00"
-- ROM CONTENT END
        );
begin

    process(clka)
    variable read_address : natural := 0;
    begin
        if (clka'event and clka = '1') then
            read_address := to_integer(unsigned(addra));
            douta <= ROM_DATA(read_address);
        end if;        
    end process;
end inferred_rom_arch;