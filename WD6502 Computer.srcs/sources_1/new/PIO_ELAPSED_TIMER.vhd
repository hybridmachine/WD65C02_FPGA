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
use work.TIMER_CONTROL.ALL;

entity PIO_ELAPSED_TIMER is
    GENERIC(
        CLOCK_DIVIDER : natural := 100000 -- Assuming 100MHZ clock, this gives 1ms resolution
    );
    Port ( CLOCK : in STD_LOGIC;
           CONTROL_REG : in STD_LOGIC_VECTOR (7 downto 0);
           STATUS_REG  : out STD_LOGIC_VECTOR (7 downto 0);
           TICKS_MS : out STD_LOGIC_VECTOR (31 downto 0));
end PIO_ELAPSED_TIMER;

architecture Behavioral of PIO_ELAPSED_TIMER is
--Internal registers
signal TICKS_MS_REG : STD_LOGIC_VECTOR (31 downto 0);
signal STATUS_REG_REG : STD_LOGIC_VECTOR (7 downto 0);
begin

process (CONTROL_REG,CLOCK)
variable COUNTER : unsigned(31 downto 0) := (others => '0');
variable DIVIDER : natural := CLOCK_DIVIDER;
variable READ_COMPLETE : boolean := false;
begin   
    IF (CONTROL_REG(CTL_BIT_RESET) = CTL_TIMER_RESET) then
        COUNTER := (others => '0'); -- Reset counter
        DIVIDER := CLOCK_DIVIDER;

        TICKS_MS_REG <= (others => '0');
        TICKS_MS <= (others => '0');
        
        STATUS_REG <= (STS_BIT_STATE => STS_TIMER_RESETTING, others => '0');
    elsif (rising_edge(CLOCK)) then
        TICKS_MS_REG <= TICKS_MS_REG; -- Keep the last set value in memory
        STATUS_REG_REG <= STATUS_REG_REG;
        
        TICKS_MS <= TICKS_MS_REG; -- Propogate out the last set value
        STATUS_REG <= STATUS_REG_REG;
        
        STATUS_REG(STS_BIT_STATE) <= STS_TIMER_RUNNING;
        
        if (DIVIDER > 0) then
            DIVIDER := DIVIDER - 1;
        else
            COUNTER := COUNTER+1;
            DIVIDER := CLOCK_DIVIDER;
        end if;
        
        if(CONTROL_REG(CTL_BIT_READREQ) = READ_REQUESTED AND READ_COMPLETE = false) then
            TICKS_MS_REG <= std_logic_vector(COUNTER);
            STATUS_REG_REG(STS_BIT_READRDY) <= READ_READY;
            READ_COMPLETE := true;
        elsif(CONTROL_REG(CTL_BIT_READREQ) = READ_CLEAR) then
            READ_COMPLETE := false;
            STATUS_REG_REG(STS_BIT_READRDY) <= READ_CLEAR;
            -- For now leave TICKS_MS at last read value, we may blank it
            -- on READ_CLEAR on CTL_BIT_READREQ
        end if;
    end if;
end process;

end Behavioral;
