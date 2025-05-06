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
use work.INTERRUPT_CONTROLLER.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_INTERRUPT_CONTROLLER is
    port(
        clk : in STD_LOGIC;
        irq_to_cpu : out STD_LOGIC; -- Signal line that routes to CPUs IRQ line
        irq_request_vec : in STD_LOGIC_VECTOR(15 downto 0); -- One line per IRQ, vector index == irq#. Driver should only signal its specific line
        irq_acknowledge_vec : out STD_LOGIC_VECTOR(15 downto 0); --One line per IRQ, each device should listen for the ack on its line on this bus
        mem_active_irq : out STD_LOGIC_VECTOR(7 downto 0); -- This is set to the active IRQ being fired, CPU should read this right after IRQ received, value is valid until CPU ack
        mem_active_irq_ack : in STD_LOGIC_VECTOR(7 downto 0) -- CPU should write the value in mem_active_irq into this register to ack that IRQ handling is complete
    );
end PIO_INTERRUPT_CONTROLLER;

architecture Behavioral of PIO_INTERRUPT_CONTROLLER is
    signal irq_controller_state : interrupt_controller_state_t := idle;
    signal mem_active_irq_signal : STD_LOGIC_VECTOR(7 downto 0);
    constant irq_trigger_delay : natural := 50; 
begin
    irq_fsm : process (clk)
    variable irq_trigger_delay_timer : natural := irq_trigger_delay; -- Clock cylces to wait until we pull IRQ low
    begin
        case irq_controller_state is
            when idle =>
                mem_active_irq <= IRQNONE;
                irq_to_cpu <= IRQ_UNTRIGGERED;
                irq_acknowledge_vec <= x"0000";
                irq_trigger_delay_timer := irq_trigger_delay;
                
                if ((irq_request_vec xor x"FFFF") /= x"FFFF") then
                    -- One or more lines is requested, move to sending request
                    EnqueueHighestPriorityInterrupt(mem_active_irq_signal, irq_request_vec);
                    irq_controller_state <= sending_interrupt;
                end if;
            when sending_interrupt => 
                mem_active_irq <= mem_active_irq_signal;  
                if (irq_trigger_delay_timer > 0) then
                    irq_trigger_delay_timer := irq_trigger_delay_timer - 1;
                    irq_to_cpu <= IRQ_UNTRIGGERED;
                    irq_controller_state <= sending_interrupt;
                else
                    irq_to_cpu <= IRQ_TRIGGERED;
                    irq_controller_state <= waiting_for_ack;
                end if;  
            when waiting_for_ack =>
                irq_to_cpu <= IRQ_TRIGGERED;
                if (mem_active_irq_ack = mem_active_irq_signal) then
                    NotifyInterruptComplete(mem_active_irq_ack,irq_acknowledge_vec);
                    irq_controller_state <= interrupt_complete;
                end if;                
            when interrupt_complete =>
                irq_controller_state <= idle;
            when others =>
                irq_controller_state <= idle;
        end case;
    end process irq_fsm;
end Behavioral;