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
use IEEE.NUMERIC_STD.ALL;

package W65C02_DEFINITIONS is
    -- Pin types
    subtype ADDRESS_65C02_T      is std_logic_vector(15 downto 0);         -- Address bus
    subtype BE_T           is std_logic;                        -- Bus Enable
    subtype DATA_65C02_T         is std_logic_vector (7 downto 0);    -- Data bus
    subtype IRQB_T         is std_logic;                        -- Interrupt Request
    subtype MLB_T          is std_logic;                        -- Memory Lock
    subtype NMIB_T         is std_logic;                        -- Non-Maskable Interrupt
    subtype PHI1O_T        is std_logic;                        -- Phase 1 out clock
    subtype PHI2_T         is std_logic;                        -- Phase 2 in clock (main clock)
    subtype PHI2O_T        is std_logic;                        -- Phase 2 out clock
    subtype RDY_T          is std_logic;                        -- Ready
    subtype RESB_T         is std_logic;                        -- Reset
    subtype RWB_T          is std_logic;                        -- Read/Write
    subtype SOB_T          is std_logic;                        -- Set Overflow
    subtype SYNC_T         is std_logic;                        -- Synchronize
    subtype VPB_T          is std_logic;                        -- Vector Pull  constant output : output_t;  -- Value assign is deferred

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
    constant CPU_WRITING_DATA : std_logic := '0'; -- RWB  is low when the CPU is writing
    constant CPU_READING_DATA : std_logic := '1'; -- RWB is high when the CPU is reading data
    constant I2C_STREAMING  : DATA_65C02_T := x"02";
    constant I2C_STORING    : DATA_65C02_T := x"01";
    -- Memory Map
    
    -- ROM ends at FFF9, FFFA - FFFF are managed directly by the memory manager
    constant ROM_END                    : ADDRESS_65C02_T := x"FFFF";
    constant ROM_BASE                   : ADDRESS_65C02_T := x"FC00";
    
    constant BOOT_VEC                   : ADDRESS_65C02_T := ROM_BASE; -- Jump to the start of ROM
    constant BOOT_VEC_ADDRESS_LOW       : ADDRESS_65C02_T := x"FFFC";
    constant BOOT_VEC_ADDRESS_HIGH      : ADDRESS_65C02_T := x"FFFD";

    constant RAM_END                    : ADDRESS_65C02_T := x"FBFF";
    constant RAM_BASE                   : ADDRESS_65C02_T := x"0000";
    
    constant MEM_MAPPED_IO_END          : ADDRESS_65C02_T := x"03FF";
    constant MEM_MAPPED_IO_BASE         : ADDRESS_65C02_T := x"0200";
    
    constant PIO_LED_ADDR               : ADDRESS_65C02_T := MEM_MAPPED_IO_BASE; -- 1 byte
    
    constant PIO_7SEG_VAL_LOW           : ADDRESS_65C02_T := x"0201"; -- 1 bytes
    constant PIO_7SEG_VAL_HIGH          : ADDRESS_65C02_T := x"0202"; -- 1 bytes
    constant PIO_7SEG_CONTROL           : ADDRESS_65C02_T := x"0203"; -- 2 byte
    
    constant PIO_ELAPSED_TIMER_CTL      : ADDRESS_65C02_T := x"0205"; -- 1 byte
    constant PIO_ELAPSED_TIMER_STATUS   : ADDRESS_65C02_T := x"0206"; -- 1 byte
    constant PIO_ELAPSED_TIMER_VAL_MS   : ADDRESS_65C02_T := x"0207"; -- 4 bytes
    constant PIO_ELAPSED_TIMER_VAL_MS_1 : ADDRESS_65C02_T := x"0208"; 
    constant PIO_ELAPSED_TIMER_VAL_MS_2 : ADDRESS_65C02_T := x"0209"; 
    constant PIO_ELAPSED_TIMER_VAL_MS_3 : ADDRESS_65C02_T := x"0210";
    
    constant PIO_FIRMWARE_VERSION       : ADDRESS_65C02_T := x"0211"; -- 1 byte (streams one character at a time)
    
    constant PIO_I2C_DATA_STRM_STATUS   : ADDRESS_65C02_T := x"0212";
    constant PIO_I2C_DATA_STRM_CTRL     : ADDRESS_65C02_T := x"0213";
    constant PIO_I2C_DATA_STRM_DATA_ADDRESS_LOW     : ADDRESS_65C02_T := x"0214";
    constant PIO_I2C_DATA_STRM_DATA_ADDRESS_HIGH    : ADDRESS_65C02_T := x"0215";
    constant PIO_I2C_DATA_STRM_DATA         : ADDRESS_65C02_T := x"0216";
    constant PIO_I2C_DATA_STRM_I2C_ADDRESS  : ADDRESS_65C02_T := x"0217"; -- First 7 bits is address, 8th bit is ignored and used internally for read/write mode
    
    constant PIO_IRQ_TIMER_CTL          : ADDRESS_65C02_T := x"0218"; -- 1 byte
    constant PIO_IRQ_TIMER_PERIOD_MS    : ADDRESS_65C02_T := x"0219";
    constant PIO_IRQ_TIMER_PERIOD_MS_1  : ADDRESS_65C02_T := x"0220";
    constant PIO_IRQ_TIMER_PERIOD_MS_2  : ADDRESS_65C02_T := x"0221";
    constant PIO_IRQ_TIMER_PERIOD_MS_3  : ADDRESS_65C02_T := x"0222";

    -- Which IRQ the controller just signaled for
    constant PIO_IRQ_CONTROLLER_IRQNUM  : ADDRESS_65C02_T := x"0223";
    constant PIO_IRQ_CONTROLLER_IRQACK  : ADDRESS_65C02_T := x"0224";

    constant PIO_SWITCHES_PREV_STATEVEC_L : ADDRESS_65C02_T := x"0225";
    constant PIO_SWITCHES_PREV_STATEVEC_H : ADDRESS_65C02_T := x"0226";
    constant PIO_SWITCHES_UPDATED_VEC_L : ADDRESS_65C02_T := x"0227";
    constant PIO_SWITCHES_UPDATED_VEC_H : ADDRESS_65C02_T := x"0228";

    constant STACK_END                  : ADDRESS_65C02_T := x"01FF";
    constant STACK_BASE                 : ADDRESS_65C02_T := x"0100";
    
    constant SYS_RESERVED_END           : ADDRESS_65C02_T := x"00FF";
    constant SYS_RESERVED_BASE          : ADDRESS_65C02_T := x"0001";
    
    constant MEM_MANAGER_STATUS         : ADDRESS_65C02_T := x"0000";

    -- Timing delays as specified in the 65C02 data sheet
    -- Times in nanoseconds unless otherwise specified
    constant tACC   : natural := 290; -- Access Time
    constant tAH    : natural := 20;  -- Address Hold Time
    constant tADS   : natural := 150; -- Address setup time
    constant tBVD   : natural := 30;  -- Bus enable to valid data
    constant tPWH   : natural := 250; -- Clock Pulse Width Hight
    constant tPWL   : natural := 250; -- Clock Pulse Width Low
    constant tCYC   : natural := 500; -- Cycle Time
    constant tF     : natural := 5;   -- Fall time
    constant tR     : natural := 5;   -- Rise time
    constant tPCH   : natural := 10;  -- Processor control hold time
    constant tPCS   : natural := 60;  -- Processor control setup time
    constant tDHR   : natural := 10;  -- Read data hold time
    constant tDSR   : natural := 60;  -- Read data setup time
    constant tMDS   : natural := 140; -- Write Data Delay time
    constant tDHW   : natural := 10;  -- Write Data hold time
end package;