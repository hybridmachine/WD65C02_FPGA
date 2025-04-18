----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/07/2025 08:59:46 PM
-- Design Name: 
-- Module Name: PIO_IRQ_TIMER - Behavioral
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

entity PIO_IRQ_TIMER is
    Generic (
        CLOCK_DIVIDER : natural := 100000 -- Assuming 100MHZ FPGA clock, this gives 1ms resolution
    );
    Port ( I_CLK : in STD_LOGIC;
           I_RST : in STD_LOGIC;
           I_PIO_IRQ_TIMER_CTL : in STD_LOGIC_VECTOR(7 downto 0);
           I_PIO_IRQ_TIMER_PERIOD_MS : in STD_LOGIC_VECTOR (31 downto 0);
           I_IRQ_ACK : in STD_LOGIC;
           O_PIO_IRQ : out STD_LOGIC);
end PIO_IRQ_TIMER;

architecture Behavioral of PIO_IRQ_TIMER is

TYPE timer_state_t IS (reset, running, sending_interrupt, waiting_for_ack);
signal R_PIO_IRQ_TIMER_PERIOD_MS : natural := 10;
signal R_TIMER_STATE : timer_state_t := reset;
signal R_PIO_IRQ_TIMER_CTL : STD_LOGIC_VECTOR(7 downto 0) := IRQ_TIMER_CTL_RST;

begin
    
    timer_fsm : process (I_CLK)
    variable v_clock_ticks : natural := CLOCK_DIVIDER;
    variable v_milliseconds : natural := 0;
    begin
        if (I_RST = '0') then
            R_PIO_IRQ_TIMER_PERIOD_MS <= to_integer(unsigned(I_PIO_IRQ_TIMER_PERIOD_MS));
            R_TIMER_STATE <= reset;
            O_PIO_IRQ <= '0';
            R_PIO_IRQ_TIMER_CTL <= I_PIO_IRQ_TIMER_CTL;
        else
            if (I_CLK'event and I_CLK = '1') then
                case R_TIMER_STATE is
                    when reset =>
                        O_PIO_IRQ <= '0';
                        v_clock_ticks := CLOCK_DIVIDER;
                        v_milliseconds := 0;
                        
                        if (R_PIO_IRQ_TIMER_CTL = IRQ_TIMER_CTL_RUN) then
                            R_TIMER_STATE <= running;   
                        else
                            R_TIMER_STATE <= reset;
                        end if;
                    when running =>
                        R_TIMER_STATE <= running;
                        O_PIO_IRQ <= '0';
                        if (v_clock_ticks = 0) then
                            v_clock_ticks := CLOCK_DIVIDER;
                            v_milliseconds := v_milliseconds + 1;
                        else
                            v_clock_ticks := v_clock_ticks - 1;
                        end if;
                        
                        if (v_milliseconds >= R_PIO_IRQ_TIMER_PERIOD_MS) then
                            R_TIMER_STATE <= sending_interrupt;
                        end if;
                    when sending_interrupt =>
                        O_PIO_IRQ <= '1';
                        R_TIMER_STATE <= waiting_for_ack;
                    when waiting_for_ack =>
                        O_PIO_IRQ <= '1';
                        R_TIMER_STATE <= waiting_for_ack;
                        if (I_IRQ_ACK = '1') then
                            O_PIO_IRQ <= '0';
                            R_TIMER_STATE <= reset;
                        end if;
                    when others =>
                        R_TIMER_STATE <= reset;
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;
