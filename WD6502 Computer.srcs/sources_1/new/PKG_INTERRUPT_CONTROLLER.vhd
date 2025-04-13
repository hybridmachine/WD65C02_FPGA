----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 01/30/2025 7:39:58 PM
-- Design Name: 
-- Module Name: PKG_INTERRUPT_CONTROLLER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Package for programmable interrupt controller.
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
use work.W65C02_DEFINITIONS.ALL;

package INTERRUPT_CONTROLLER is
    -- Highest priority is 0, lowest 15
    constant IRQ0 : std_logic_vector(7 downto 0) := x"00";
    constant IRQ1 : std_logic_vector(7 downto 0) := x"01";
    constant IRQ2 : std_logic_vector(7 downto 0) := x"02";
    constant IRQ3 : std_logic_vector(7 downto 0) := x"03";
    constant IRQ4 : std_logic_vector(7 downto 0) := x"04";
    constant IRQ5 : std_logic_vector(7 downto 0) := x"05";
    constant IRQ6 : std_logic_vector(7 downto 0) := x"06";
    constant IRQ7 : std_logic_vector(7 downto 0) := x"07";
    constant IRQ8 : std_logic_vector(7 downto 0) := x"08";
    constant IRQ9 : std_logic_vector(7 downto 0) := x"09";
    constant IRQ10 : std_logic_vector(7 downto 0) := x"0A";
    constant IRQ11 : std_logic_vector(7 downto 0) := x"0B";
    constant IRQ12 : std_logic_vector(7 downto 0) := x"0C";
    constant IRQ13 : std_logic_vector(7 downto 0) := x"0D";
    constant IRQ14 : std_logic_vector(7 downto 0) := x"0E";
    constant IRQ15 : std_logic_vector(7 downto 0) := x"0F";
    constant IRQNONE : std_logic_vector(7 downto 0) := x"FF";

    constant IRQ_MASKED : std_logic := '1';
    constant IRQ_UNMASKED : std_logic := '0';
    
    constant IRQ_UNTRIGGERED : std_logic := '1'; -- CPU expects IRQ to be high when not triggered
    constant IRQ_TRIGGERED : std_logic := '0';

    constant IRQ_REQUESTED : std_logic := '1'; -- We expect drivers to raise their line to high when requesting IRQ
    constant IRQ_STANDBY : std_logic := '0'; -- Drivers pull their lines low when no IRQ requested

    TYPE interrupt_controller_state_t IS (idle, sending_interrupt, waiting_for_ack, interrupt_complete);
   
    
    -- Device driver calls this to raise the interrupt
    -- Takes the irq_number from the device driver and the outbound irq_vector , will set the appropriate line
    -- and leave the others untouched
    procedure EnqueueHighestPriorityInterrupt(signal irq_number : out std_logic_vector(7 downto 0); 
                             signal irq_vector : in std_logic_vector(15 downto 0)
                            );

    -- Send the ack back to the device, this is triggered when the CPU marks the interrupt request complete
    procedure NotifyInterruptComplete(signal irq_number : in std_logic_vector(7 downto 0);
                            signal irq_ack_vector : out std_logic_vector(15 downto 0)
                            );
                            
    -- Memory manager will call this when processor updates an IRQ mask
    -- When set to 1, any interrupts will be masked and the IRQ manager will 
    -- notify the driver by setting the is_masked bit on the EnqueueHighestPriorityInterrupt call
    --procedure SetIRQMask(signal irq_number : in std_logic_vector(7 downto 0); 
    --                     signal irq_mask_vector : out std_logic_vector(15 downto 0);
    ---                     signal irq_mask_state : in std_logic);


    -- Device will call this to get its IRQ mask state
    --procedure GetIRQMask(signal irq_number : in std_logic_vector(7 downto 0); 
    --                     signal irq_mask_state : out std_logic);

end package INTERRUPT_CONTROLLER;

package body INTERRUPT_CONTROLLER is
    
    procedure NotifyInterruptComplete(signal irq_number : in std_logic_vector(7 downto 0);
                            signal irq_ack_vector : out std_logic_vector(15 downto 0)
                            ) is
    begin
        irq_ack_vector <= x"0000"; 
        case irq_number is 
            when IRQ0 =>
               irq_ack_vector(0) <= '1'; 
            when IRQ1 =>
               irq_ack_vector(1) <= '1'; 
            when IRQ2 =>
               irq_ack_vector(2) <= '1'; 
            when IRQ3 =>
               irq_ack_vector(3) <= '1';
            when IRQ4 =>
               irq_ack_vector(4) <= '1';
            when IRQ5 =>
               irq_ack_vector(5) <= '1';   
            when IRQ6 =>
               irq_ack_vector(6) <= '1';
            when IRQ7 =>
               irq_ack_vector(7) <= '1';
            when IRQ8 =>
               irq_ack_vector(8) <= '1';
            when IRQ9 =>
               irq_ack_vector(9) <= '1';
            when IRQ10 =>
               irq_ack_vector(10) <= '1';
            when IRQ11 =>
               irq_ack_vector(11) <= '1';
            when IRQ12 =>
               irq_ack_vector(12) <= '1';
            when IRQ13 =>
               irq_ack_vector(13) <= '1';
            when IRQ14 =>
               irq_ack_vector(14) <= '1';      
            when IRQ15 =>
               irq_ack_vector(15) <= '1';
            when others =>
               irq_ack_vector <= x"0000";                           
        end case;
    end procedure;
    
    procedure EnqueueHighestPriorityInterrupt(signal irq_number : out std_logic_vector(7 downto 0); 
                             signal irq_vector : in std_logic_vector(15 downto 0)
                            ) is
    begin
        irq_number <= IRQNONE;
        
        if (irq_vector(0) = IRQ_REQUESTED) then
            irq_number <= IRQ0;
        elsif (irq_vector(1) = IRQ_REQUESTED) then
            irq_number <= IRQ1;
        elsif (irq_vector(2) = IRQ_REQUESTED) then
            irq_number <= IRQ2;
        elsif (irq_vector(3) = IRQ_REQUESTED) then
            irq_number <= IRQ3;
        elsif (irq_vector(4) = IRQ_REQUESTED) then
            irq_number <= IRQ4;
        elsif (irq_vector(5) = IRQ_REQUESTED) then
            irq_number <= IRQ5;
        elsif (irq_vector(6) = IRQ_REQUESTED) then
            irq_number <= IRQ6;
        elsif (irq_vector(7) = IRQ_REQUESTED) then
            irq_number <= IRQ7;
        elsif (irq_vector(8) = IRQ_REQUESTED) then
            irq_number <= IRQ8;
        elsif (irq_vector(9) = IRQ_REQUESTED) then
            irq_number <= IRQ9;
        elsif (irq_vector(10) = IRQ_REQUESTED) then
            irq_number <= IRQ10;
        elsif (irq_vector(11) = IRQ_REQUESTED) then
            irq_number <= IRQ11;
        elsif (irq_vector(12) = IRQ_REQUESTED) then
            irq_number <= IRQ12;
        elsif (irq_vector(13) = IRQ_REQUESTED) then
            irq_number <= IRQ13;
        elsif (irq_vector(14) = IRQ_REQUESTED) then
            irq_number <= IRQ14;
        elsif (irq_vector(15) = IRQ_REQUESTED) then
            irq_number <= IRQ15;
        end if;
    end procedure;
    
end package body INTERRUPT_CONTROLLER;