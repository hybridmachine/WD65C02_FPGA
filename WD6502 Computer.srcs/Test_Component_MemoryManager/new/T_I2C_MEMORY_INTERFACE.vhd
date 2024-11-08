----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 11/07/2024 08:49:13 PM
-- Design Name: 
-- Module Name: T_I2C_MEMORY_INTERFACE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Test harness to test the memory interface into the I2C streamer
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
use work.W65C02_DEFINITIONS.ALL;
use work.MEMORY_MANAGER.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_I2C_MEMORY_INTERFACE is
--  Port ( );
end T_I2C_MEMORY_INTERFACE;

architecture Behavioral of T_I2C_MEMORY_INTERFACE is
    signal T_BUS_READ_DATA : DATA_65C02_T; --! Read data
    signal T_BUS_WRITE_DATA : DATA_65C02_T; --! Data to be written
    signal T_BUS_ADDRESS : ADDRESS_65C02_T; --! Read/Write address
    signal T_MEMORY_CLOCK : std_logic := '0'; --! Memory clock, typically full FPGA clock speed
    signal T_WRITE_FLAG : std_logic; --! When 1, write data to address, otherwise read address and output on data line
    signal T_PIO_LED_OUT : std_logic_vector (7 downto 0); --! 8 bit LED out, mapped to physical LEDs at interface
    signal T_PIO_7SEG_COMMON : std_logic_vector(3 downto 0); --! Common drivers for seven segment displays
    signal T_PIO_7SEG_SEGMENTS : std_logic_vector(7 downto 0); --! Segment drivers for selected seven segment display
    signal T_PIO_I2C_DATA_STREAMER_SDA : std_logic;
    signal T_PIO_I2C_DATA_STREAMER_SCL : std_logic;   
    signal T_RESET : std_logic;
    
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    
begin

T_MEMORY_CLOCK <= not T_MEMORY_CLOCK after (CLOCK_PERIOD / 2);

dut: entity work.MemoryManager 
    Port map (
        BUS_READ_DATA => T_BUS_READ_DATA,
        BUS_WRITE_DATA => T_BUS_WRITE_DATA,
        BUS_ADDRESS => T_BUS_ADDRESS,
        MEMORY_CLOCK => T_MEMORY_CLOCK,
        WRITE_FLAG => T_WRITE_FLAG,
        PIO_LED_OUT => T_PIO_LED_OUT,
        PIO_7SEG_COMMON => T_PIO_7SEG_COMMON,
        PIO_7SEG_SEGMENTS => T_PIO_7SEG_SEGMENTS,
        PIO_I2C_DATA_STREAMER_SDA => T_PIO_I2C_DATA_STREAMER_SDA,
        PIO_I2C_DATA_STREAMER_SCL => T_PIO_I2C_DATA_STREAMER_SCL,
        RESET => T_RESET );


stimuli_generator: process
begin
    T_RESET <= CPU_RESET;
    wait for 10*CLOCK_PERIOD;
    T_RESET <= CPU_RUNNING;
    wait for 10*CLOCK_PERIOD;
    
    -- Set write mode
    -- Write control register with I2C reset
    -- Write control register with I2C buffer write
    -- Set I2C buffer address
    -- Write data to I2C buffer
    -- Loop to write a few test bytes
    -- Write control register to set I2C address
    -- Set I2C address.
    -- Write control register to start streaming
end process stimuli_generator;

i2c_signal_test: process
begin
    -- Wait for I2C Start condition
    -- Verify I2C address
    -- Verify byte stream
    -- Wait for I2C Stop
end process i2c_signal_test;
end Behavioral;
