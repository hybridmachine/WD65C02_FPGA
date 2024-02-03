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
use work.TIMER_CONTROL.ALL;

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
           CONTROL_REG : in STD_LOGIC_VECTOR (7 downto 0);
           STATUS_REG : out STD_LOGIC_VECTOR (7 downto 0);
           TICKS_MS : out STD_LOGIC_VECTOR (31 downto 0));
end COMPONENT;

signal T_CLOCK : STD_LOGIC := '0';
signal T_CONTROL_REG : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
signal T_STATUS_REG  : STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
signal T_TICKS_MS : STD_LOGIC_VECTOR(31 downto 0);

constant CLOCK_PERIOD : time := 100 ns; -- 10 MHZ

begin

-- Generate the clock
T_CLOCK <= not T_CLOCK after (CLOCK_PERIOD / 2);

DUT : PIO_ELAPSED_TIMER
    generic map (CLOCK_DIVIDER => 10000)
    port map (
        CLOCK => T_CLOCK,
        CONTROL_REG => T_CONTROL_REG,
        STATUS_REG => T_STATUS_REG,
        TICKS_MS => T_TICKS_MS);
        
-- Main testing procss
process
variable TICKS_RECORDED : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
begin
    T_CONTROL_REG(CTL_BIT_RESET) <= CTL_TIMER_RESET;
    wait until T_STATUS_REG(STS_BIT_STATE) = STS_TIMER_RESETTING;
    TICKS_RECORDED := T_TICKS_MS;
    T_CONTROL_REG(CTL_BIT_RESET) <= CTL_TIMER_RUN;
    wait until T_STATUS_REG(STS_BIT_STATE) = STS_TIMER_RUNNING;
    wait for 20ms;
    assert (to_integer(unsigned(T_TICKS_MS)) - to_integer(unsigned(TICKS_RECORDED))) = 0 report "Timer elapsed but read wasn't set" severity failure;
    T_CONTROL_REG(CTL_BIT_READREQ) <= READ_REQUESTED;
    wait until T_STATUS_REG(STS_BIT_READRDY) = READ_READY;
    assert (to_integer(unsigned(T_TICKS_MS)) - to_integer(unsigned(TICKS_RECORDED))) >= 19 report "Timer did not elapse as expected" severity failure;
    TICKS_RECORDED := T_TICKS_MS;
    wait for 20ms;
    --Verify nothing changed on the value
    assert (to_integer(unsigned(TICKS_RECORDED)) = to_integer(unsigned(T_TICKS_MS))) report "Timer elapsed when expected to be stable" severity failure;
    T_CONTROL_REG(CTL_BIT_READREQ) <= READ_CLEAR; -- Tell the timer we are done with the read
    wait for 20ms;
    -- For now when we clear the read request, the timer is expected to just leave the last read value in place
    assert (to_integer(unsigned(TICKS_RECORDED)) = to_integer(unsigned(T_TICKS_MS))) report "Timer elapsed when expected to be stable" severity failure;
    T_CONTROL_REG(CTL_BIT_READREQ) <= READ_REQUESTED;
    wait until T_STATUS_REG(STS_BIT_READRDY) = READ_READY;
    assert (to_integer(unsigned(T_TICKS_MS)) - to_integer(unsigned(TICKS_RECORDED))) >= 19 report "Timer did not elapse as expected" severity failure;
    
    assert (false) report "Test completed succesfully" severity failure;
end process;
end Behavioral;
