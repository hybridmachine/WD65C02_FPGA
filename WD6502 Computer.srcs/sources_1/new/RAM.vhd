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

entity RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**16 -- By default 32kb ram for now, can be adjusted to leave address space for I/O
  );
    PORT (
	addra: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	addrb: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	ena : IN STD_LOGIC;
	enb : IN STD_LOGIC;
	dina: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	dinb: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	douta: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	doutb: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	wea: IN std_logic;
	web: IN std_logic
  );
end RAM;

-- Adapted from example on Page 516 of "Effective Coding with VHDL"
architecture inferred_ram_arch of RAM is
    type ram_contents_type is array (natural range<>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    shared variable ram_contents: ram_contents_type (0 to RAM_DEPTH - 1);
begin

process(CLKA)
 begin
  if CLKA'event and CLKA = '1' then
   if ENA = '1' then
    douta <= ram_contents(to_integer(unsigned(ADDRA)));
    if (wea = '1') then
     ram_contents(to_integer(unsigned(ADDRA))) := dina;
    end if;
   end if;
  end if;
 end process;

 process(CLKB)
 begin
  if CLKB'event and CLKB = '1' then
   if ENB = '1' then
    doutb <= ram_contents(to_integer(unsigned(ADDRB)));
    if WEB = '1' then
     ram_contents(to_integer(unsigned(ADDRB))) := dinb;
    end if;
   end if;
  end if;
 end process;
end inferred_ram_arch;