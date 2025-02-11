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
--use IEEE.NUMERIC_STD.ALL;

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

end process stimuli_generator;

interrupt_controller_verifier: process
begin

end process interrupt_controller_verifier;

end Behavioral;
