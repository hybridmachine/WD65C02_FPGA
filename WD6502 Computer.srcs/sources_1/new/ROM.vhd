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
x"78", x"D8", x"18", x"A9",
x"00", x"8D", x"01", x"02",
x"8D", x"02", x"02", x"85",
x"2F", x"85", x"30", x"A9",
x"01", x"8D", x"03", x"02",
x"A9", x"00", x"85", x"10",
x"A9", x"03", x"85", x"11",
x"A9", x"21", x"85", x"12",
x"A9", x"04", x"85", x"13",
x"A9", x"01", x"85", x"20",
x"A9", x"02", x"85", x"1F",
x"A9", x"04", x"85", x"1E",
x"A9", x"08", x"85", x"1D",
x"A9", x"10", x"85", x"1C",
x"A9", x"20", x"85", x"1B",
x"A9", x"40", x"85", x"1A",
x"A9", x"80", x"85", x"19",
x"A9", x"00", x"85", x"16",
x"A9", x"20", x"85", x"2C",
x"A9", x"04", x"85", x"2D",
x"A9", x"00", x"85", x"29",
x"A9", x"03", x"85", x"2A",
x"A2", x"00", x"A0", x"00",
x"A9", x"00", x"92", x"29",
x"18", x"A9", x"01", x"65",
x"29", x"85", x"29", x"90",
x"06", x"A9", x"00", x"65",
x"2A", x"85", x"2A", x"38",
x"A5", x"29", x"E9", x"20",
x"D0", x"E2", x"38", x"A5",
x"2A", x"E9", x"04", x"D0",
x"DB", x"A5", x"10", x"85",
x"14", x"A5", x"11", x"85",
x"15", x"A2", x"17", x"A0",
x"16", x"A9", x"01", x"20",
x"4C", x"FE", x"A2", x"18",
x"A0", x"16", x"A9", x"01",
x"20", x"4C", x"FE", x"A2",
x"16", x"A0", x"17", x"A9",
x"01", x"20", x"4C", x"FE",
x"A2", x"17", x"A0", x"17",
x"A9", x"01", x"20", x"4C",
x"FE", x"A2", x"17", x"A0",
x"18", x"A9", x"01", x"20",
x"4C", x"FE", x"18", x"A5",
x"2F", x"69", x"01", x"85",
x"2F", x"8D", x"01", x"02",
x"A5", x"30", x"69", x"00",
x"85", x"30", x"8D", x"02",
x"02", x"A2", x"09", x"86",
x"2D", x"A9", x"0A", x"38",
x"E5", x"2D", x"8D", x"00",
x"02", x"DA", x"20", x"DF",
x"FC", x"20", x"BA", x"FD",
x"FA", x"CA", x"D0", x"EB",
x"4C", x"14", x"FC", x"A2",
x"01", x"A0", x"01", x"A5",
x"10", x"85", x"14", x"A5",
x"11", x"85", x"15", x"86",
x"17", x"84", x"18", x"98",
x"8D", x"01", x"02", x"98",
x"38", x"E9", x"01", x"A8",
x"A5", x"17", x"38", x"E9",
x"01", x"AA", x"DA", x"5A",
x"20", x"39", x"FE", x"18",
x"65", x"16", x"85", x"16",
x"7A", x"FA", x"8A", x"18",
x"69", x"01", x"AA", x"85",
x"2D", x"A5", x"17", x"18",
x"69", x"02", x"C5", x"2D",
x"D0", x"E4", x"98", x"18",
x"69", x"01", x"A8", x"85",
x"2D", x"A5", x"18", x"18",
x"69", x"02", x"C5", x"2D",
x"D0", x"CE", x"A6", x"17",
x"A4", x"18", x"20", x"39",
x"FE", x"85", x"2D", x"A5",
x"16", x"38", x"E5", x"2D",
x"85", x"16", x"A5", x"15",
x"48", x"A5", x"14", x"48",
x"A5", x"12", x"85", x"14",
x"A5", x"13", x"85", x"15",
x"A6", x"17", x"A4", x"18",
x"A5", x"2D", x"C9", x"01",
x"D0", x"22", x"A5", x"16",
x"C9", x"02", x"30", x"0C",
x"C9", x"04", x"30", x"10",
x"A9", x"00", x"20", x"4C",
x"FE", x"4C", x"8A", x"FD",
x"A9", x"00", x"20", x"4C",
x"FE", x"4C", x"8A", x"FD",
x"A9", x"01", x"20", x"4C",
x"FE", x"4C", x"8A", x"FD",
x"A5", x"16", x"C9", x"03",
x"F0", x"08", x"A9", x"00",
x"20", x"4C", x"FE", x"4C",
x"8A", x"FD", x"A9", x"01",
x"20", x"4C", x"FE", x"4C",
x"8A", x"FD", x"68", x"85",
x"14", x"68", x"85", x"15",
x"A9", x"00", x"85", x"16",
x"A5", x"18", x"A8", x"A5",
x"17", x"18", x"69", x"01",
x"AA", x"85", x"17", x"C9",
x"2E", x"F0", x"03", x"4C",
x"F3", x"FC", x"A5", x"18",
x"18", x"69", x"01", x"A8",
x"85", x"18", x"C9", x"2E",
x"F0", x"07", x"A9", x"01",
x"85", x"17", x"4C", x"EF",
x"FC", x"60", x"A5", x"10",
x"85", x"2D", x"A5", x"11",
x"85", x"2E", x"A5", x"12",
x"85", x"10", x"A5", x"13",
x"85", x"11", x"A5", x"2D",
x"85", x"12", x"A5", x"2E",
x"85", x"13", x"60", x"08",
x"48", x"A9", x"FF", x"68",
x"28", x"40", x"68", x"40",
x"01", x"00", x"00", x"00",
x"0A", x"A2", x"00", x"A0",
x"00", x"A5", x"80", x"05",
x"81", x"F0", x"16", x"46",
x"81", x"66", x"80", x"90",
x"09", x"18", x"98", x"65",
x"82", x"A8", x"8A", x"65",
x"83", x"AA", x"06", x"82",
x"26", x"83", x"4C", x"E5",
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
x"60", x"20", x"70", x"FE",
x"AE", x"2B", x"00", x"B2",
x"29", x"3D", x"19", x"00",
x"F0", x"03", x"A9", x"01",
x"60", x"A9", x"00", x"60",
x"48", x"20", x"70", x"FE",
x"AE", x"2B", x"00", x"68",
x"C9", x"00", x"F0", x"08",
x"B2", x"29", x"1D", x"19",
x"00", x"92", x"29", x"60",
x"BD", x"19", x"00", x"49",
x"FF", x"8D", x"21", x"00",
x"B2", x"29", x"2D", x"21",
x"00", x"92", x"29", x"60",
x"AD", x"14", x"00", x"8D",
x"29", x"00", x"AD", x"15",
x"00", x"8D", x"2A", x"00",
x"A9", x"00", x"8D", x"80",
x"00", x"8D", x"81", x"00",
x"8D", x"82", x"00", x"8D",
x"83", x"00", x"8C", x"80",
x"00", x"A9", x"06", x"8D",
x"82", x"00", x"DA", x"5A",
x"20", x"E1", x"FD", x"18",
x"98", x"6D", x"29", x"00",
x"8D", x"29", x"00", x"A9",
x"00", x"6D", x"2A", x"00",
x"8D", x"2A", x"00", x"8A",
x"6D", x"2A", x"00", x"B0",
x"36", x"8D", x"2A", x"00",
x"7A", x"FA", x"A9", x"00",
x"8D", x"80", x"00", x"8D",
x"81", x"00", x"8D", x"82",
x"00", x"8D", x"83", x"00",
x"8E", x"80", x"00", x"A9",
x"08", x"8D", x"82", x"00",
x"20", x"02", x"FE", x"18",
x"6D", x"29", x"00", x"8D",
x"29", x"00", x"A9", x"00",
x"6D", x"2A", x"00", x"B0",
x"0A", x"8D", x"2A", x"00",
x"AD", x"80", x"00", x"8D",
x"2B", x"00", x"60", x"00",
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
x"00", x"00", x"D3", x"FD",
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