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
    generic (
        IRQ_TRIGGER_HOLD_CYCLES : natural := 20;
        IRQ_TRIGGER_DELAY_CYCLES : natural := 5;
        IRQ_ACK_TIMEOUT_CYCLES  : natural := 50_000_000 -- Give the CPU 1/2 second to ack (assume 100mhz clock
    );
    port(
        clk : in STD_LOGIC;
        irq_to_cpu : out STD_LOGIC; -- Signal line that routes to CPUs IRQ line
        irq_request_vec : in STD_LOGIC_VECTOR(15 downto 0); -- One line per IRQ, vector index == irq#. Driver should only signal its specific line
        mem_active_irq : out STD_LOGIC_VECTOR(7 downto 0); -- This is set to the active IRQ being fired, CPU should read this right after IRQ received, value is valid until CPU ack
        mem_active_irq_ack : in STD_LOGIC_VECTOR(7 downto 0) -- CPU should write the value in mem_active_irq into this register to ack that IRQ handling is complete
    );
end PIO_INTERRUPT_CONTROLLER;

architecture Behavioral of PIO_INTERRUPT_CONTROLLER is
    signal irq_controller_state : interrupt_controller_state_t := idle;
    signal mem_active_irq_signal : STD_LOGIC_VECTOR(7 downto 0); 
begin
    irq_fsm : process (clk)
    variable irq_trigger_hold_timer : natural := IRQ_TRIGGER_HOLD_CYCLES;
    variable irq_ack_timeout_timer : natural := IRQ_ACK_TIMEOUT_CYCLES;
    
    begin
        case irq_controller_state is
            when idle =>
                mem_active_irq <= IRQNONE;
                irq_trigger_hold_timer := IRQ_TRIGGER_HOLD_CYCLES;
                irq_ack_timeout_timer := IRQ_ACK_TIMEOUT_CYCLES;
                
                irq_to_cpu <= IRQ_UNTRIGGERED;
                if (irq_request_vec /= x"0000") then
                    -- One or more lines is requested, move to sending request
                    EnqueueHighestPriorityInterrupt(mem_active_irq_signal, irq_request_vec);
                    irq_controller_state <= sending_interrupt;
                end if;
            when sending_interrupt =>     
                if (irq_trigger_hold_timer > 0) then
                    mem_active_irq <= mem_active_irq_signal;
                    -- Set the active IRQ in memory first, then fire the interrupt a few cycles later
                    if ((IRQ_TRIGGER_HOLD_CYCLES - irq_trigger_hold_timer) > IRQ_TRIGGER_DELAY_CYCLES) then
                        irq_to_cpu <= IRQ_TRIGGERED;
                    else
                        irq_to_cpu <= IRQ_UNTRIGGERED;
                    end if;
                    
                    irq_trigger_hold_timer := irq_trigger_hold_timer - 1;
                    irq_controller_state <= sending_interrupt;
                else
                    irq_to_cpu <= IRQ_UNTRIGGERED;
                    irq_controller_state <= waiting_for_ack;
                end if;
            when waiting_for_ack =>
                if (irq_ack_timeout_timer > 0) then
                    irq_ack_timeout_timer := irq_ack_timeout_timer - 1;
                else
                    irq_controller_state <= interrupt_expired;
                end if;
                
                if (mem_active_irq_ack = mem_active_irq_signal) then
                    irq_controller_state <= interrupt_complete;
                end if;
                
            when interrupt_expired =>
                irq_controller_state <= interrupt_complete;
            when interrupt_complete =>
                irq_controller_state <= idle;
            when others =>
                irq_controller_state <= idle;
        end case;
    end process irq_fsm;
end Behavioral;