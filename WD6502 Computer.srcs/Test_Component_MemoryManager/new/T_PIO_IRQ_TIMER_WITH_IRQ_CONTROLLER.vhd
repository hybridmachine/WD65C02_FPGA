----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2025 08:45:51 PM
-- Design Name: 
-- Module Name: T_PIO_IRQ_TIMER_WITH_IRQ_CONTROLLER - Behavioral
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
use WORK.W65C02_DEFINITIONS.ALL;
use WORK.TIMER_CONTROL.ALL;

entity T_PIO_IRQ_TIMER_WITH_IRQ_CONTROLLER is
--  Port ( );
end T_PIO_IRQ_TIMER_WITH_IRQ_CONTROLLER;

architecture Behavioral of T_PIO_IRQ_TIMER_WITH_IRQ_CONTROLLER is
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
    signal T_IRQ : std_logic;
    
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant address_setup_ns : time := tADS * 1 ns;
    constant address_hold_time : time := tAH * 1 ns;
    constant MODE_WRITE : std_logic := '1';
    constant MODE_READ : std_logic := not MODE_WRITE;
    
    TYPE pio_irq_timer_state IS (idle, expecting_interrupt, handling_interrupt);
    signal TEST_NEXT_STATE : pio_irq_timer_state := idle;
    signal IRQ_STATE : std_logic := '1';
    
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
        IRQ => T_IRQ,
        RESET => T_RESET );
      
      

manage_timer: process(T_MEMORY_CLOCK, T_IRQ)
    
begin
    if (falling_edge(T_IRQ)) then
        IRQ_STATE <= '0';
    end if;
    
    if (rising_edge(T_MEMORY_CLOCK)) then
        case TEST_NEXT_STATE is
            when idle =>    
                IRQ_STATE <= '1';
                T_WRITE_FLAG <= MODE_WRITE;
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_CTL;
                T_BUS_WRITE_DATA <= IRQ_TIMER_CTL_RUN;
                TEST_NEXT_STATE <= expecting_interrupt;
            when expecting_interrupt =>
                TEST_NEXT_STATE <= expecting_interrupt;
                if (IRQ_STATE = '0') then
                    TEST_NEXT_STATE <= handling_interrupt;
                end if;
            when handling_interrupt =>
                T_WRITE_FLAG <= MODE_READ;
                -- TODO read which IRQ is active, should be 0 for timer
                -- TODO send ack
            when others =>
                TEST_NEXT_STATE <= idle;
        end case;        
    end if;
end process;
  
end Behavioral;
