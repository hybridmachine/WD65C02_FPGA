----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 01/27/2024 12:41:00 PM
-- Design Name: 
-- Module Name: PIO_ELAPSED_TIMER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This PIO module runs a 1ms resolution incrementing counter that can be used by the 6502 to count how long an operation takes
--              To reset, send bXXXXXXX1 to the RESET address
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

entity PIO_ELAPSED_TIMER is
    GENERIC(
        CLOCK_DIVIDER : natural := 100000 -- Assuming 100MHZ clock, this gives 1ms resolution
    );
    Port ( CLOCK : in STD_LOGIC;
           RESET : in STD_LOGIC_VECTOR (7 downto 0);
           TICKS_MS : out STD_LOGIC_VECTOR (31 downto 0));
end PIO_ELAPSED_TIMER;

architecture Behavioral of PIO_ELAPSED_TIMER is

begin

process (RESET,CLOCK)
variable COUNTER : unsigned(31 downto 0) := (others => '0');
variable DIVIDER : natural := CLOCK_DIVIDER;
begin
    IF (RESET(0) = '1') then
        COUNTER := (others => '0'); -- Reset counter
        DIVIDER := CLOCK_DIVIDER;
        TICKS_MS <= (others => '0');
    elsif (rising_edge(CLOCK)) then
        IF (DIVIDER > 0) then
            DIVIDER := DIVIDER - 1;
        else
            COUNTER := COUNTER+1;
            TICKS_MS <= std_logic_vector(COUNTER);
            DIVIDER := CLOCK_DIVIDER;
        end if;
    end if;
end process;

end Behavioral;
