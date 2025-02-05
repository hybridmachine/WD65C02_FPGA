----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 02/04/2025 10:41:30 PM
-- Design Name: 
-- Module Name: PIO_INTERRUPT_CONTROLLER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This is the interrupt controller that prioritizes and mediates interrupts sent by 
-- devices. It is programmable. The CPU can manage minimum time between interrupts, global maximum retries, and can set IRQ levels in each driver)
-- CPU may also pause interrupts and acknowledge interrupts.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.PKG_INTERRUPT_CONTROLLER.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_INTERRUPT_CONTROLLER is
    port(
        clk : in STD_LOGIC;
        irq_to_cpu : out STD_LOGIC; -- Signal line that routes to CPUs IRQ line
        irq_request_vec : in STD_LOGIC_VECTOR(15 downto 0); -- One line per IRQ, vector index == irq#. Driver should only signal its specific line
        mem_active_irq : out STD_LOGIC_VECTOR(7 downto 0); -- This is set to the active IRQ being fired, CPU should read this right after IRQ received, value is valid until CPU ack
        mem_active_irq_ack : in STD_LOGIC_VECTOR(7 downto 0); -- CPU should write the value in mem_active_irq into this register to ack that IRQ handling is complete
    );
end PIO_INTERRUPT_CONTROLLER;

architecture Behavioral of PIO_INTERRUPT_CONTROLLER is
end Behavioral;