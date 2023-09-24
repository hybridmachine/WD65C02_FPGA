----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/26/2023 11:43:29 AM
-- Design Name: 
-- Module Name: T_RAM - Behavioral
-- Project Name: 
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
use WORK.CHAR2STD.all; 

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_RAM is
--  Port ( );
end T_RAM;

architecture Behavioral of T_RAM is
COMPONENT RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**16 -- By default 65kb ram can be adjusted to leave address space for I/O
  );
    PORT (
	addra: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	addrb: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	dinb: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	douta: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	doutb: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	wea: IN std_logic;
	web: IN std_logic;
	ena: IN std_logic;
	enb: IN std_logic
  );
end COMPONENT;

constant ADDRESS_WIDTH : natural := 16;
constant DATA_WIDTH : natural := 8;
constant RAM_DEPTH : natural := 2**16;

-- RAM signals
signal T_CLKA : STD_LOGIC;
signal T_WRE_A : STD_LOGIC;
signal T_ENA : STD_LOGIC;
signal T_ADDR_A : STD_LOGIC_VECTOR(ADDRESS_WIDTH - 1 DOWNTO 0);
signal T_DATA_IN_A : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
signal T_DATA_OUT_A : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

signal T_CLKB : STD_LOGIC;
signal T_WRE_B : STD_LOGIC;
signal T_ENB : STD_LOGIC;
signal T_ADDR_B : STD_LOGIC_VECTOR(ADDRESS_WIDTH - 1 DOWNTO 0);
signal T_DATA_IN_B : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
signal T_DATA_OUT_B : STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);

constant CLKA_PERIOD : time := 1000 ns;
constant CLKB_PERIOD : time := 2000 ns;

begin

DUT: RAM port map (
    clka => T_CLKA,
    wea => T_WRE_A,
    ena => T_ENA,
    addra => T_ADDR_A,
    dina => T_DATA_IN_A,
    douta => T_DATA_OUT_A,
    clkb => T_CLKB,
    web => T_WRE_B,
    enb => T_ENB,
    addrb => T_ADDR_B,
    dinb => T_DATA_IN_B,
    doutb => T_DATA_OUT_B
);

--clka
process
begin
    T_CLKA <= '0';
    wait for CLKA_PERIOD / 2;
    T_CLKA <= '1';
    wait for CLKA_PERIOD / 2;
end process;

--clkb
process
begin
    T_CLKB <= '0';
    wait for CLKB_PERIOD / 2;
    T_CLKB <= '1';
    wait for CLKB_PERIOD / 2;
end process;

-- Simulation process
-- Write 'HELLO' to the first five bytes of RAM, via portA. Read it back on port B
process
begin
    T_ADDR_A <= x"0000";
    T_ADDR_B <= x"0000";

    T_DATA_IN_A <= x"00";
    -- Write to A , read from B
    T_WRE_A <= '1';
    T_WRE_B <= '0';
    T_ENA <= '1';
    T_ENB <= '1';
    
    wait until T_CLKA'event and T_CLKA = '0';
    T_DATA_IN_A <= CHAR2STD('H');
    T_ADDR_A <= x"0000";
    wait until T_CLKA'event and T_CLKA = '1';
    wait until T_CLKA'event and T_CLKA = '0';
    T_DATA_IN_A <= CHAR2STD('E');
    T_ADDR_A <= x"0001";
    wait until T_CLKA'event and T_CLKA = '1';
    wait until T_CLKA'event and T_CLKA = '0';
    T_DATA_IN_A <= CHAR2STD('L');
    T_ADDR_A <= x"0002";
    wait until T_CLKA'event and T_CLKA = '1';
    wait until T_CLKA'event and T_CLKA = '0';
    T_DATA_IN_A <= CHAR2STD('L');
    T_ADDR_A <= x"0003";
    wait until T_CLKA'event and T_CLKA = '1';
    wait until T_CLKA'event and T_CLKA = '0';
    T_DATA_IN_A <= CHAR2STD('O');
    T_ADDR_A <= x"0004";
    wait until T_CLKA'event and T_CLKA = '1';
    wait until T_CLKA'event and T_CLKA = '0';
    
    wait until T_CLKB'event and T_CLKB = '0';
    T_ADDR_B <= x"0000";
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    assert (T_DATA_OUT_B = CHAR2STD('H')) report "Address 0 does not contain 'H'" severity failure;
    
    wait until T_CLKB'event and T_CLKB = '0';
    T_ADDR_B <= x"0001";
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    assert (T_DATA_OUT_B = CHAR2STD('E')) report "Address 1 does not contain 'e'" severity failure;
    
    wait until T_CLKB'event and T_CLKB = '0';
    T_ADDR_B <= x"0002";
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    assert (T_DATA_OUT_B = CHAR2STD('L')) report "Address 2 does not contain 'L'" severity failure;

    wait until T_CLKB'event and T_CLKB = '0';
    T_ADDR_B <= x"0003";
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    assert (T_DATA_OUT_B = CHAR2STD('L')) report "Address 3 does not contain 'L'" severity failure;

    wait until T_CLKB'event and T_CLKB = '0';
    T_ADDR_B <= x"0004";
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    wait until T_CLKB'event and T_CLKB = '1';
    wait until T_CLKB'event and T_CLKB = '0';
    assert (T_DATA_OUT_B = CHAR2STD('O')) report "Address 4 does not contain 'o'" severity failure;
    
    wait;
end process;

end Behavioral;
