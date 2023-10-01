----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2023 03:35:52 PM
-- Design Name: 
-- Module Name: PKG_65C02 - Behavioral
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

package W65C02_DEFINITIONS is
    -- Pin types
    subtype ADDRESS_T      is STD_LOGIC_VECTOR(15 downto 0);         -- Address bus
    subtype BE_T           is STD_LOGIC;                        -- Bus Enable
    subtype DATA_T         is STD_LOGIC_VECTOR (7 downto 0);    -- Data bus
    subtype IRQB_T         is STD_LOGIC;                        -- Interrupt Request
    subtype MLB_T          is STD_LOGIC;                        -- Memory Lock
    subtype NMIB_T         is STD_LOGIC;                        -- Non-Maskable Interrupt
    subtype PHI1O_T        is STD_LOGIC;                        -- Phase 1 out clock
    subtype PHI2_T         is STD_LOGIC;                        -- Phase 2 in clock (main clock)
    subtype PHI2O_T        is STD_LOGIC;                        -- Phase 2 out clock
    subtype RDY_T          is STD_LOGIC;                        -- Ready
    subtype RESB_T         is STD_LOGIC;                        -- Reset
    subtype RWB_T          is STD_LOGIC;                        -- Read/Write
    subtype SOB_T          is STD_LOGIC;                        -- Set Overflow
    subtype SYNC_T         is STD_LOGIC;                        -- Synchronize
    subtype VPB_T          is STD_LOGIC;                        -- Vector Pull  constant output : output_t;  -- Value assign is deferred

    -- State constants
    -- From the W65C02 spec
    -- When in the high state, the microprocessor is reading data from memory or I/O. 
    -- When in the low state, the Data Bus contains valid data 
    -- to be written from the microprocessor and stored at the addressed memory or I/O location
    constant PROCESSOR_READING_FROM_MEMORY : std_logic := '1';
    constant PROCESSOR_WRITING_TO_MEMORY : std_logic := '0';
    
    -- From the WD65C02 spec 
    -- When a positive edge (on RESB) is detected, there will be a reset sequence lasting seven clock cycles.
    constant CPU_RESET_HOLDOFF_CLOCKTICKS : integer := 7; 
    
    -- RESB is held low for 2 clock cycles to start a reset
    -- RESB should be held high after reset for normal operation.
    constant CPU_RESET : std_logic := '0';
    constant CPU_RUNNING : std_logic := '1';
    constant CPU_STANDBY : std_logic := '0'; -- RDY held low to standby
    constant SYNC_READING_OPCODE : std_logic := '1'; -- SYNC high when opcode fetch in progress
    constant RESET_MIN_CLOCKS : natural := 2; -- Hold reset low for min clocks (2 based on the spec)
    
    -- Memory Map
    
    constant ROM_END            : std_logic_vector := x"FFFF";
    constant ROM_BASE           : std_logic_vector := x"FC00";
    constant RAM_END            : std_logic_vector := x"FBFF";
    constant RAM_BASE           : std_logic_vector := x"0400";
    constant MEM_MAPPED_IO_END  : std_logic_vector := x"03FF";
    constant MEM_MAPPED_IO_BASE : std_logic_vector := x"0200";
    constant STACK_END          : std_logic_vector := x"01FF";
    constant STACK_BASE         : std_logic_vector := x"0100";
    constant SYS_RESERVED_END   : std_logic_vector := x"00FF";
    constant SYS_RESERVED_BASE  : std_logic_vector := x"0001";
    constant MEM_MANAGER_STATUS : std_logic_vector := x"0000";

end package;