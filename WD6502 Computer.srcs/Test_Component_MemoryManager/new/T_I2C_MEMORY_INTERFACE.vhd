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
use work.I2C_DATA_STREAMER.ALL;

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
    constant address_setup_ns : time := tADS * 1 ns;
    constant address_hold_time : time := tAH * 1 ns;
    constant MODE_WRITE : std_logic := '1';
    constant MODE_READ : std_logic := not MODE_WRITE;
    
    
    procedure WriteToMemory( signal  memory_clock : in std_logic;
                             constant i_address : in ADDRESS_65C02_T;
                             signal o_address : out ADDRESS_65C02_T;
                             constant i_data    : in DATA_65C02_T;
                             signal o_data    : out DATA_65C02_T;
                             signal write_flag   : out std_logic) is
    begin
         -- Set I2C target address
    wait until falling_edge(memory_clock);
    o_address <= i_address;
    
    wait until rising_edge(memory_clock);
    wait until falling_edge(memory_clock);
    o_data <= i_data; 
    
    wait until rising_edge(memory_clock);
    wait until falling_edge(memory_clock);
    -- Set write mode
    write_flag <= MODE_WRITE;
    
    wait until rising_edge(memory_clock);
    wait until falling_edge(memory_clock);
    write_flag <= MODE_READ;
    end procedure;
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
variable stream_address : DATA_65C02_T;
variable stream_value : DATA_65C02_T;
begin
    T_RESET <= CPU_RESET;
    wait for 10*CLOCK_PERIOD;
    T_RESET <= CPU_RUNNING;
    wait for 10*CLOCK_PERIOD;
    
    -- Write control register with I2C reset
    WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_CTRL,
                    T_BUS_ADDRESS,
                    CONTROL_RESET,
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
    
    -- Write control register with I2C standby
    WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_CTRL,
                    T_BUS_ADDRESS,
                    CONTROL_STANDBY,
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
        
    -- Write control register with I2C buffer write
    WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_CTRL,
                    T_BUS_ADDRESS,
                    CONTROL_WRITE_BUFFER,
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
    
    -- Write FeedFace to first four bytes of stream buffer (conceptually 0 is leftmost, 3 is rightmost byte
    for Addr_Low in 0 to 3 loop
        stream_address := std_logic_vector( to_unsigned( Addr_Low, stream_address'length));
        WriteToMemory(  T_MEMORY_CLOCK,
                        PIO_I2C_DATA_STRM_DATA_ADDRESS_LOW,
                        T_BUS_ADDRESS,
                        stream_address,
                        T_BUS_WRITE_DATA,T_WRITE_FLAG);
        WriteToMemory(  T_MEMORY_CLOCK,
                        PIO_I2C_DATA_STRM_DATA_ADDRESS_HIGH,
                        T_BUS_ADDRESS,
                        x"00",
                        T_BUS_WRITE_DATA,
                        T_WRITE_FLAG);
        case Addr_Low is
            when 0 =>
                stream_value := x"FE";
            when 1 =>
                stream_value := x"ED";
            when 2 =>
                stream_value := x"FA";
            when 3 =>
                stream_value := x"CE";
            when others =>
                stream_value := x"FF";
        end case;
        
        -- Write data to I2C buffer
        WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_DATA,
                    T_BUS_ADDRESS,
                    stream_value,
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
    end loop;

    -- Set I2C address.
    WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_I2C_ADDRESS,
                    T_BUS_ADDRESS,
                    x"BE",
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
    
    -- Write control register to start streaming
    WriteToMemory(  T_MEMORY_CLOCK,
                    PIO_I2C_DATA_STRM_CTRL,
                    T_BUS_ADDRESS,
                    CONTROL_STREAM_BUFFER,
                    T_BUS_WRITE_DATA,
                    T_WRITE_FLAG);
    
end process stimuli_generator;

i2c_signal_test: process
begin
    -- Wait for I2C Start condition
    -- Verify I2C address
    -- Verify byte stream
    -- Wait for I2C Stop
end process i2c_signal_test;
end Behavioral;
