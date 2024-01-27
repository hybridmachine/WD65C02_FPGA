----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/27/2024 01:00:34 PM
-- Design Name: 
-- Module Name: T_PIO_ELAPSED_TIMER - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_PIO_ELAPSED_TIMER is
--  Port ( );
end T_PIO_ELAPSED_TIMER;

architecture Behavioral of T_PIO_ELAPSED_TIMER is
COMPONENT PIO_ELAPSED_TIMER is
    GENERIC(
        CLOCK_DIVIDER : natural := 100000 -- Assuming 100MHZ clock, this gives 1ms resolution
    );
    Port ( CLOCK : in STD_LOGIC;
           RESET : in STD_LOGIC_VECTOR (7 downto 0);
           TICKS_MS : out STD_LOGIC_VECTOR (31 downto 0));
end COMPONENT;

signal T_CLOCK : STD_LOGIC := '0';
signal T_RESET : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
signal T_TICKS_MS : STD_LOGIC_VECTOR(31 downto 0);

constant CLOCK_PERIOD : time := 100 ns; -- 10 MHZ

begin

-- Generate the clock
T_CLOCK <= not T_CLOCK after (CLOCK_PERIOD / 2);

DUT : PIO_ELAPSED_TIMER
    generic map (CLOCK_DIVIDER => 10000)
    port map (
        CLOCK => T_CLOCK,
        RESET => T_RESET,
        TICKS_MS => T_TICKS_MS);
        
-- Main testing procss
process
variable TICKS_RECORDED : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
begin
    T_RESET <= "00000001";
    wait until T_TICKS_MS = x"00000000";
    TICKS_RECORDED := T_TICKS_MS;
    T_RESET <= "00000000";
    wait for 20ms;
    assert (to_integer(unsigned(T_TICKS_MS)) - to_integer(unsigned(TICKS_RECORDED))) >= 19 report "Timer did not elapse" severity failure;
    assert (false) report "Test completed succesfully" severity failure;
end process;
end Behavioral;
