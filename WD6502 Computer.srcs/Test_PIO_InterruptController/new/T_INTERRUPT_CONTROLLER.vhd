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
    TYPE interrupt_controller_test_state_t IS (idle, sending_interrupt, expecting_interrupt, interrupt_received, sending_ack);
    
    signal interrupt_controller_test_state : interrupt_controller_test_state_t := idle; 
begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);

dut: entity work.PIO_INTERRUPT_CONTROLLER
Port map (
    clk => t_clk,
    irq_to_cpu => t_irq_to_cpu,
    irq_request_vec => t_irq_request_vec,
    mem_active_irq => t_mem_active_irq,
    mem_active_irq_ack => t_mem_active_irq_ack
);

stimuli_generator: process 
begin
    t_mem_active_irq_ack <= x"FF";
    wait until t_irq_to_cpu = IRQ_UNTRIGGERED for 100ns;
    t_irq_request_vec <= x"0000"; -- All IRQ lines off
    interrupt_controller_test_state <= sending_interrupt;
    t_irq_request_vec <= x"0001"; -- Trigger IRQ0
    interrupt_controller_test_state <= expecting_interrupt;
    wait until t_irq_to_cpu = IRQ_TRIGGERED;
    interrupt_controller_test_state <= idle;
    wait until t_irq_to_cpu = IRQ_UNTRIGGERED;
    t_irq_request_vec <= x"0000";
    t_mem_active_irq_ack <= x"00";
    interrupt_controller_test_state <= sending_interrupt;
    wait for 20ns;
    t_irq_request_vec <= x"0002"; -- Trigger IRQ0
    interrupt_controller_test_state <= expecting_interrupt;
    wait until t_irq_to_cpu = IRQ_TRIGGERED;
    interrupt_controller_test_state <= idle;
    wait until t_irq_to_cpu = IRQ_UNTRIGGERED;
    t_irq_request_vec <= x"0000";
    t_mem_active_irq_ack <= x"01";
    report "ALL PASS" severity note;
    wait;
end process stimuli_generator;

interrupt_controller_verifier: process(t_irq_to_cpu)
begin
    if (t_irq_to_cpu'event and t_irq_to_cpu = IRQ_UNTRIGGERED) then
        case interrupt_controller_test_state is
            when sending_interrupt =>
               report "PASS: IRQ inactive during sending phase" severity note;
            when expecting_interrupt =>
                report "IRQ not active during expecting phase" severity failure;
            when idle =>
                -- NoOp     
            when others =>
                report "Unexpected state" severity failure;
        end case;
    end if;
    
    if (t_irq_to_cpu'event and t_irq_to_cpu = IRQ_TRIGGERED) then
        case interrupt_controller_test_state is
            when sending_interrupt =>
                report "IRQ active during sending phase" severity failure;
            when expecting_interrupt =>
                report "PASS: IRQ active during expected phase" severity note;
                case t_irq_request_vec is
                    when x"0001" =>
                        assert(t_mem_active_irq = x"00") report "IRQ identity expected to be 0" severity failure;
                    when x"0002" =>
                        assert(t_mem_active_irq = x"01") report "IRQ identity expected to be 1" severity failure;
                    when others =>
                        report "Untested IRQ sent" severity failure;
                end case;
            when idle =>
                -- NoOp     
            when others =>
                report "Unexpected state" severity failure;
        end case;
    end if;
end process interrupt_controller_verifier;

end Behavioral;
