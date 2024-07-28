----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/08/2023 04:00:45 PM
-- Design Name: 
-- Module Name: RAM - inferred_ram
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--! \author Brian Tabone
--! @brief Dual port inferred RAM (65KB)
--! @details Dual port inferred RAM , note that the peripheral IO is mapped over this so that address range
--! is masked. See PKG_65C02 for the memory map
entity RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**16 --! 65KB of RAM
  );
    PORT (
	addra: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0); --! Port a address
	addrb: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0); --! Port b address
	clka: IN std_logic; --! Port a clock
	clkb: IN std_logic; --! Port b clock
	ena : IN STD_LOGIC; --! Enable port A
	enb : IN STD_LOGIC; --! Enable port B
	dina: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0); --! Data in a
	dinb: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0); --! Data in b
	douta: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0); --! Data out a
	doutb: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0); --! Data out b
	wea: IN std_logic; --! Write enable a
	web: IN std_logic --! Write enable b
  );
end RAM;

-- Adapted from example on Page 516 of "Effective Coding with VHDL"
architecture inferred_ram_arch of RAM is
    type ram_contents_type is array (natural range<>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    shared variable ram_contents: ram_contents_type (0 to RAM_DEPTH - 1);
    
    signal douta_reg : std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
    signal doutb_reg : std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
begin

process(CLKA)
 begin
  if rising_edge(CLKA) then
   douta <= douta_reg;
   if ENA = '1' then
    douta_reg <= ram_contents(to_integer(unsigned(ADDRA)));
    if (wea = '1') then
     ram_contents(to_integer(unsigned(ADDRA))) := dina;
    end if;
   end if;
  end if;
 end process;

 process(CLKB)
 begin
  if rising_edge(CLKB) then
   doutb <= doutb_reg;
   if ENB = '1' then
    doutb_reg <= ram_contents(to_integer(unsigned(ADDRB)));
    if WEB = '1' then
     ram_contents(to_integer(unsigned(ADDRB))) := dinb;
    end if;
   end if;
  end if;
 end process;
end inferred_ram_arch;