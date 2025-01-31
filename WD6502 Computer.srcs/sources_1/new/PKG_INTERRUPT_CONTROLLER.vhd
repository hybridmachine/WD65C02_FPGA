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

    constant IRQ_MASKED : std_logic := '1';
    constant IRQ_UNMASKED : std_logic := '0';

    TYPE interrupt_controller_state_type IS (idle, sending_interrupt, waiting_for_ack, interrupt_complete);
    
    type interrupt_controller_interface_t is record
        signal irq_vector : std_logic_vector(15 downto 0);
        signal irq_mask_vector : std_logic_vector(15 downto 0);
        signal irq_mask_state : std_logic;
    end record interrupt_controller_interface_t;
    
    -- Device driver calls this to raise the interrupt
    -- Interrupt Controller will place the masked status in the out bit
    -- If set, this means the interrupt was masked and will not be delivered
    procedure RaiseInterrupt(signal irq_number : in std_logic_vector(7 downto 0); 
                             signal irq_vector : out std_logic_vector(15 downto 0);
                             signal irq_mask_vector : in std_logic_vector(15 downto 0);
                             signal irq_mask_state : out std_logic);

    -- Memory manager will call this when processor updates an IRQ mask
    -- When set to 1, any interrupts will be masked and the IRQ manager will 
    -- notify the driver by setting the is_masked bit on the RaiseInterrupt call
    procedure SetIRQMask(signal irq_number : in std_logic_vector(7 downto 0); 
                         signal irq_mask_vector : out std_logic_vector(15 downto 0);
                         signal irq_mask_state : in std_logic);


    -- Device will call this to get its IRQ mask state
    procedure GetIRQMask(signal irq_number : in std_logic_vector(7 downto 0); 
                         signal irq_mask_state : out std_logic);

end package INTERRUPT_CONTROLLER;
