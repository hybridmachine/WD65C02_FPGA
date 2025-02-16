----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 02/10/2025 09:04:52 PM
-- Design Name: 
-- Module Name: T_INTERRUPT_CONTROLLER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Test bench for the programmable interrupt controller
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
use work.INTERRUPT_CONTROLLER.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_INTERRUPT_CONTROLLER is
--  Port ( );
end T_INTERRUPT_CONTROLLER;

architecture Behavioral of T_INTERRUPT_CONTROLLER is

    signal t_clk : STD_LOGIC := '0';
    signal t_irq_to_cpu : STD_LOGIC := '0'; 
    signal t_irq_request_vec : STD_LOGIC_VECTOR(15 downto 0) := x"0000"; 
    signal t_mem_active_irq : STD_LOGIC_VECTOR(7 downto 0) := x"00"; 
    signal t_mem_active_irq_ack : STD_LOGIC_VECTOR(7 downto 0) := x"00";
    
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    TYPE interrupt_controller_test_state_t IS (sending_interrupt, expecting_interrupt, interrupt_received, sending_ack);
    
    signal interrupt_controller_test_state : interrupt_controller_test_state_t := sending_interrupt; 
begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);

dut: entity work.PIO_INTERRUPT_CONTROLLER
Port map (
    clk => t_clk,
    irq_to_cpu => t_irq_to_cpu,
    irq_request_vec => t_irq_request_vec,
    mem_active_irq_ack => t_mem_active_irq_ack
);

stimuli_generator: process 
begin
    t_irq_request_vec <= x"0000"; -- All IRQ lines off
    interrupt_controller_test_state <= sending_interrupt;
    wait for 5 * CLOCK_PERIOD;
    t_irq_request_vec <= x"0001"; -- Trigger IRQ0
    interrupt_controller_test_state <= expecting_interrupt;
    wait for 5 * CLOCK_PERIOD;
    
end process stimuli_generator;

interrupt_controller_verifier: process
begin
    wait on interrupt_controller_test_state;
    case interrupt_controller_test_state is
        when sending_interrupt =>
            assert(t_irq_to_cpu = '0') report "IRQ active during sending phase" severity error;
        when expecting_interrupt =>
            wait on t_irq_to_cpu until (t_irq_to_cpu = '1') for (20 * CLOCK_PERIOD);
            assert(t_irq_to_cpu = '1') report "IRQ not active during expecting phase" severity error;
            
            case t_irq_request_vec is
                when x"0001" =>
                    assert(t_mem_active_irq = x"00") report "IRQ identity expected to be 0" severity error;
                when x"0002" =>
                    assert(t_mem_active_irq = x"01") report "IRQ identity expected to be 1" severity error;
                when others =>
                    report "Untested IRQ sent" severity error;
            end case;
            
        when others =>
            report "Unexpected state" severity error;
    end case;
    
end process interrupt_controller_verifier;

end Behavioral;
