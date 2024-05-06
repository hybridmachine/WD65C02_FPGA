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
-- Source File: .\GameOfLife.hex
x"78", x"18", x"D8", x"A2",
x"FF", x"9A", x"A9", x"00",
x"85", x"05", x"A9", x"03",
x"85", x"06", x"A9", x"28",
x"85", x"01", x"A9", x"28",
x"85", x"02", x"A9", x"00",
x"85", x"03", x"20", x"2D",
x"FE", x"A9", x"90", x"85",
x"05", x"A9", x"09", x"85",
x"06", x"A9", x"28", x"85",
x"01", x"A9", x"28", x"85",
x"02", x"A9", x"00", x"85",
x"03", x"20", x"2D", x"FE",
x"A9", x"00", x"85", x"05",
x"A9", x"03", x"85", x"06",
x"A9", x"14", x"85", x"01",
x"A9", x"13", x"85", x"02",
x"A9", x"01", x"85", x"03",
x"20", x"CF", x"FE", x"A9",
x"15", x"85", x"01", x"A9",
x"13", x"85", x"02", x"A9",
x"01", x"85", x"03", x"20",
x"CF", x"FE", x"A9", x"14",
x"85", x"01", x"A9", x"14",
x"85", x"02", x"A9", x"01",
x"85", x"03", x"20", x"CF",
x"FE", x"A9", x"13", x"85",
x"01", x"A9", x"14", x"85",
x"02", x"A9", x"01", x"85",
x"03", x"20", x"CF", x"FE",
x"A9", x"14", x"85", x"01",
x"A9", x"15", x"85", x"02",
x"A9", x"01", x"85", x"03",
x"20", x"CF", x"FE", x"A9",
x"00", x"85", x"0F", x"A9",
x"03", x"85", x"10", x"A9",
x"90", x"85", x"11", x"A9",
x"09", x"85", x"12", x"20",
x"8B", x"FF", x"A9", x"64",
x"48", x"20", x"CC", x"FC",
x"20", x"87", x"FD", x"68",
x"38", x"E9", x"01", x"D0",
x"F3", x"A9", x"00", x"48",
x"48", x"48", x"48", x"20",
x"94", x"FF", x"68", x"85",
x"09", x"68", x"85", x"0A",
x"68", x"85", x"0B", x"68",
x"85", x"0C", x"A5", x"0A",
x"48", x"A5", x"09", x"48",
x"20", x"D7", x"FF", x"68",
x"68", x"4C", x"97", x"FC",
x"A2", x"01", x"A0", x"01",
x"98", x"85", x"02", x"5A",
x"DA", x"8A", x"85", x"01",
x"A5", x"0F", x"85", x"05",
x"A5", x"10", x"85", x"06",
x"A5", x"01", x"48", x"A5",
x"02", x"48", x"20", x"24",
x"FF", x"85", x"09", x"68",
x"F0", x"0A", x"85", x"02",
x"68", x"F0", x"2F", x"85",
x"01", x"4C", x"24", x"FD",
x"08", x"DA", x"5A", x"48",
x"A9", x"02", x"64", x"13",
x"64", x"14", x"85", x"13",
x"A5", x"14", x"48", x"A5",
x"13", x"48", x"20", x"D7",
x"FF", x"68", x"68", x"A2",
x"FF", x"CA", x"F0", x"08",
x"A0", x"FF", x"88", x"F0",
x"F8", x"4C", x"16", x"FD",
x"68", x"7A", x"FA", x"28",
x"00", x"00", x"00", x"00",
x"A5", x"11", x"85", x"05",
x"A5", x"12", x"85", x"06",
x"A5", x"09", x"C9", x"02",
x"30", x"0A", x"F0", x"1C",
x"C9", x"03", x"F0", x"0E",
x"10", x"02", x"00", x"00",
x"A9", x"00", x"85", x"03",
x"20", x"CF", x"FE", x"4C",
x"6B", x"FD", x"A9", x"01",
x"85", x"03", x"20", x"CF",
x"FE", x"4C", x"6B", x"FD",
x"A5", x"0F", x"85", x"05",
x"A5", x"10", x"85", x"06",
x"20", x"12", x"FF", x"85",
x"03", x"A5", x"11", x"85",
x"05", x"A5", x"12", x"85",
x"06", x"20", x"CF", x"FE",
x"4C", x"6B", x"FD", x"FA",
x"E8", x"E0", x"27", x"D0",
x"03", x"4C", x"77", x"FD",
x"4C", x"D4", x"FC", x"7A",
x"C8", x"C0", x"27", x"F0",
x"09", x"A2", x"01", x"5A",
x"98", x"85", x"02", x"4C",
x"D4", x"FC", x"60", x"A5",
x"0F", x"85", x"09", x"A5",
x"10", x"85", x"0A", x"A5",
x"11", x"85", x"0F", x"A5",
x"12", x"85", x"10", x"A5",
x"09", x"85", x"11", x"A5",
x"0A", x"85", x"12", x"60",
x"08", x"48", x"A9", x"FF",
x"68", x"28", x"40", x"08",
x"DA", x"5A", x"48", x"A9",
x"0B", x"64", x"13", x"64",
x"14", x"85", x"13", x"A5",
x"14", x"48", x"A5", x"13",
x"48", x"20", x"D7", x"FF",
x"68", x"68", x"A2", x"FF",
x"CA", x"F0", x"08", x"A0",
x"FF", x"88", x"F0", x"F8",
x"4C", x"C5", x"FD", x"68",
x"7A", x"FA", x"28", x"40",
x"01", x"00", x"00", x"00",
x"0A", x"A2", x"00", x"A0",
x"00", x"A5", x"80", x"05",
x"81", x"F0", x"16", x"46",
x"81", x"66", x"80", x"90",
x"09", x"18", x"98", x"65",
x"82", x"A8", x"8A", x"65",
x"83", x"AA", x"06", x"82",
x"26", x"83", x"4C", x"D9",
x"FD", x"60", x"A9", x"00",
x"AA", x"48", x"A0", x"01",
x"A5", x"82", x"30", x"0B",
x"C8", x"06", x"82", x"26",
x"83", x"30", x"04", x"C0",
x"11", x"D0", x"F5", x"38",
x"A5", x"80", x"E5", x"82",
x"48", x"A5", x"81", x"E5",
x"83", x"90", x"06", x"85",
x"81", x"68", x"85", x"80",
x"48", x"68", x"68", x"2A",
x"48", x"8A", x"2A", x"AA",
x"46", x"83", x"66", x"82",
x"88", x"D0", x"E0", x"68",
x"60", x"A9", x"00", x"8D",
x"80", x"00", x"8D", x"81",
x"00", x"8D", x"82", x"00",
x"8D", x"83", x"00", x"A9",
x"02", x"8D", x"80", x"00",
x"A5", x"02", x"8D", x"82",
x"00", x"20", x"D5", x"FD",
x"98", x"85", x"0B", x"8A",
x"85", x"0C", x"A2", x"00",
x"A9", x"00", x"85", x"09",
x"85", x"0A", x"8A", x"0A",
x"A8", x"DA", x"5A", x"8A",
x"8D", x"80", x"00", x"A9",
x"00", x"8D", x"81", x"00",
x"A5", x"01", x"8D", x"82",
x"00", x"A9", x"00", x"8D",
x"83", x"00", x"20", x"D5",
x"FD", x"98", x"85", x"09",
x"8A", x"85", x"0A", x"7A",
x"FA", x"A5", x"05", x"18",
x"65", x"09", x"85", x"09",
x"A5", x"06", x"65", x"0A",
x"85", x"0A", x"18", x"A5",
x"0B", x"65", x"09", x"85",
x"09", x"A5", x"0C", x"65",
x"0A", x"85", x"0A", x"A5",
x"09", x"91", x"05", x"A5",
x"0A", x"C8", x"91", x"05",
x"E8", x"E4", x"02", x"D0",
x"AF", x"A2", x"00", x"A0",
x"00", x"A5", x"01", x"48",
x"A5", x"02", x"48", x"DA",
x"5A", x"8A", x"85", x"01",
x"98", x"85", x"02", x"A5",
x"03", x"85", x"03", x"20",
x"CF", x"FE", x"7A", x"FA",
x"68", x"85", x"02", x"68",
x"85", x"01", x"E8", x"E4",
x"01", x"D0", x"DE", x"A2",
x"00", x"C8", x"C4", x"02",
x"D0", x"D7", x"60", x"A5",
x"02", x"0A", x"A8", x"B1",
x"05", x"85", x"09", x"C8",
x"B1", x"05", x"85", x"0A",
x"A4", x"01", x"18", x"A5",
x"0A", x"D0", x"2A", x"08",
x"DA", x"5A", x"48", x"A9",
x"08", x"64", x"13", x"64",
x"14", x"85", x"13", x"A5",
x"14", x"48", x"A5", x"13",
x"48", x"20", x"D7", x"FF",
x"68", x"68", x"A2", x"FF",
x"CA", x"F0", x"08", x"A0",
x"FF", x"88", x"F0", x"F8",
x"4C", x"01", x"FF", x"68",
x"7A", x"FA", x"28", x"00",
x"00", x"A5", x"03", x"91",
x"09", x"60", x"A5", x"02",
x"0A", x"A8", x"B1", x"05",
x"85", x"09", x"C8", x"B1",
x"05", x"85", x"0A", x"A4",
x"01", x"B1", x"09", x"60",
x"A9", x"00", x"85", x"0B",
x"85", x"09", x"20", x"70",
x"FF", x"A0", x"00", x"B1",
x"07", x"18", x"65", x"09",
x"85", x"09", x"38", x"A5",
x"02", x"E9", x"01", x"85",
x"02", x"38", x"A5", x"01",
x"E9", x"01", x"85", x"01",
x"A0", x"00", x"18", x"5A",
x"20", x"70", x"FF", x"20",
x"61", x"FF", x"7A", x"18",
x"A9", x"01", x"65", x"02",
x"85", x"02", x"C8", x"C0",
x"03", x"D0", x"EB", x"A5",
x"0B", x"38", x"E5", x"09",
x"60", x"A0", x"00", x"B1",
x"07", x"18", x"65", x"0B",
x"85", x"0B", x"C8", x"C0",
x"03", x"D0", x"F4", x"60",
x"A5", x"02", x"0A", x"A8",
x"B1", x"05", x"85", x"07",
x"C8", x"B1", x"05", x"85",
x"08", x"A5", x"01", x"18",
x"65", x"07", x"85", x"07",
x"A9", x"00", x"65", x"08",
x"85", x"08", x"60", x"20",
x"CC", x"FF", x"A9", x"00",
x"8D", x"05", x"02", x"60",
x"A9", x"02", x"8D", x"05",
x"02", x"A2", x"14", x"CA",
x"D0", x"FD", x"AD", x"06",
x"02", x"29", x"03", x"C9",
x"03", x"D0", x"1F", x"BA",
x"E8", x"E8", x"E8", x"AD",
x"07", x"02", x"9D", x"00",
x"01", x"E8", x"AD", x"08",
x"02", x"9D", x"00", x"01",
x"E8", x"AD", x"09", x"02",
x"9D", x"00", x"01", x"E8",
x"AD", x"0A", x"02", x"9D",
x"00", x"01", x"A9", x"00",
x"8D", x"05", x"02", x"60",
x"A9", x"01", x"8D", x"05",
x"02", x"A2", x"0A", x"CA",
x"D0", x"FD", x"60", x"A9",
x"01", x"8D", x"03", x"02",
x"BA", x"E8", x"E8", x"E8",
x"BD", x"00", x"01", x"8D",
x"01", x"02", x"E8", x"BD",
x"00", x"01", x"8D", x"02",
x"02", x"60", x"A9", x"00",
x"8D", x"03", x"02", x"60",
x"00", x"00", x"00", x"00",
x"00", x"00", x"A0", x"FD",
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