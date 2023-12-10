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
            -- Address: 0x0000
            x"78", x"D8", x"18", x"A9",
            x"00", x"8D", x"00", x"06",
            x"8D", x"01", x"06", x"85",
            x"04", x"85", x"05", x"A9",
            x"00", x"8D", x"00", x"02",
            x"8D", x"01", x"02", x"8D",
            x"01", x"02", x"A9", x"01",
            x"8D", x"03", x"02", x"A2",
            x"FE", x"A9", x"01", x"9D",
            x"00", x"04", x"CA", x"A9",
            x"01", x"9D", x"00", x"04",
            x"8A", x"9D", x"00", x"05",
            x"E0", x"02", x"D0", x"F2",
            x"A2", x"01", x"E8", x"8A",
            x"C9", x"FF", x"F0", x"54",
            x"A9", x"01", x"DD", x"00",
            x"04", x"D0", x"F3", x"8A",
            x"A8", x"A9", x"00", x"8D",
            x"80", x"07", x"8D", x"81",
            x"07", x"8D", x"82", x"07",
            x"8D", x"83", x"07", x"8A",
            x"8D", x"80", x"07", x"98",
            x"8D", x"82", x"07", x"20",
            x"BB", x"FC", x"20", x"22",
            x"FD", x"8A", x"8D", x"02",
            x"07", x"98", x"8D", x"01",
            x"07", x"20", x"C4", x"FC",
            x"AD", x"02", x"07", x"C9",
            x"00", x"D0", x"C3", x"98",
            x"C9", x"FF", x"F0", x"BE",
            x"20", x"BB", x"FC", x"AC",
            x"01", x"07", x"A9", x"00",
            x"99", x"00", x"04", x"99",
            x"00", x"05", x"20", x"C4",
            x"FC", x"C8", x"4C", x"45",
            x"FC", x"4C", x"00", x"FC",
            x"A0", x"00", x"C8", x"98",
            x"C9", x"FF", x"F0", x"F5",
            x"B9", x"00", x"05", x"C9",
            x"00", x"F0", x"F3", x"8D",
            x"00", x"02", x"20", x"F1",
            x"FC", x"A5", x"04", x"8D",
            x"01", x"02", x"A5", x"05",
            x"8D", x"02", x"02", x"20",
            x"BB", x"FC", x"20", x"CD",
            x"FC", x"20", x"C4", x"FC",
            x"4C", x"92", x"FC", x"8A",
            x"8D", x"03", x"07", x"98",
            x"8D", x"04", x"07", x"60",
            x"AD", x"03", x"07", x"AA",
            x"AD", x"04", x"07", x"A8",
            x"60", x"A9", x"00", x"8D",
            x"00", x"06", x"8D", x"01",
            x"06", x"18", x"AD", x"00",
            x"06", x"69", x"01", x"8D",
            x"00", x"06", x"A9", x"00",
            x"6D", x"01", x"06", x"8D",
            x"01", x"06", x"AD", x"01",
            x"06", x"C9", x"0F", x"F0",
            x"03", x"4C", x"D5", x"FC",
            x"60", x"48", x"A9", x"00",
            x"85", x"04", x"85", x"05",
            x"68", x"C9", x"09", x"B0",
            x"0E", x"F8", x"18", x"65",
            x"04", x"85", x"04", x"A9",
            x"00", x"65", x"05", x"85",
            x"05", x"D8", x"60", x"48",
            x"F8", x"18", x"A5", x"04",
            x"69", x"09", x"85", x"04",
            x"A5", x"05", x"69", x"00",
            x"85", x"05", x"D8", x"68",
            x"38", x"E9", x"09", x"4C",
            x"F9", x"FC", x"A2", x"00",
            x"A0", x"00", x"AD", x"80",
            x"07", x"0D", x"81", x"07",
            x"F0", x"1C", x"4E", x"81",
            x"07", x"6E", x"80", x"07",
            x"90", x"0B", x"18", x"98",
            x"6D", x"82", x"07", x"A8",
            x"8A", x"6D", x"83", x"07",
            x"AA", x"0E", x"82", x"07",
            x"2E", x"83", x"07", x"4C",
            x"26", x"FD", x"60", x"08",
            x"48", x"A9", x"FF", x"68",
            x"28", x"40", x"68", x"40",
            x"01", x"00", x"00", x"00",
            x"0A", x"00", x"00", x"00",
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