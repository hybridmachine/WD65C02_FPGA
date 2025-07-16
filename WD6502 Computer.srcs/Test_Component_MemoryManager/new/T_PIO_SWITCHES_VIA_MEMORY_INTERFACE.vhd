----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/01/2025 10:28:27 PM
-- Design Name: 
-- Module Name: T_PIO_SWITCHES_VIA_MEMORY_INTERFACE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Test harness for the PIO switch interface, via the memory interface to the processor
-- This is a full up integration test 
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
use WORK.W65C02_DEFINITIONS.ALL;
use WORK.TIMER_CONTROL.ALL;

entity T_PIO_SWITCHES_VIA_MEMORY_INTERFACE is
--  Port ( );
end T_PIO_SWITCHES_VIA_MEMORY_INTERFACE;

architecture Behavioral of T_PIO_SWITCHES_VIA_MEMORY_INTERFACE is
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
    signal T_SWITCH_VECTOR : std_logic_vector(15 downto 0);
    
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant address_setup_ns : time := tADS * 1 ns;
    constant address_hold_time : time := tAH * 1 ns;
    constant MODE_WRITE : std_logic := '1';
    constant MODE_READ : std_logic := not MODE_WRITE;
    constant IRQ_UNTRIGGERED : std_logic := '1';
    constant IRQ_TRIGGERED : std_logic := not IRQ_UNTRIGGERED;
    
    TYPE pio_switch_state IS (  startup, 
                                write_timeout_ms_0,
                                write_timeout_ms_1,
                                write_timeout_ms_2,
                                write_timeout_ms_3,
                                start_timer,
                                idle, 
                                switch_triggered, 
                                switch_untriggered, 
                                expecting_interrupt, 
                                request_irqnum, 
                                read_irqnum_wait_for_mem, 
                                read_irqnum, 
                                acknowledge_irq,
                                 wait_for_irq_clear);
    signal TEST_NEXT_STATE : pio_switch_state := startup;
    signal IRQ_STATE : std_logic := IRQ_UNTRIGGERED;
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
        I_SWITCH_VECTOR => T_SWITCH_VECTOR,
        IRQ => T_IRQ,
        RESET => T_RESET );

send_reset: process
begin
    T_RESET <= '0'; -- Reset
    wait for 5ms;
    T_RESET <= '1'; -- Running
    wait;
end process;

watch_irq: process(T_IRQ)
begin
    if (falling_edge(T_IRQ)) then
        IRQ_STATE <= IRQ_TRIGGERED;
    end if;
    
    if (rising_edge(T_IRQ)) then
        IRQ_STATE <= IRQ_UNTRIGGERED;
    end if;
end process;

-- TYPE pio_switch_state IS (idle, switch_triggered, switch_untriggered, expecting_interrupt, request_irqnum, read_irqnum_wait_for_mem, read_irqnum, acknowledge_irq, wait_for_irq_clear);
    
test_buttons: process(T_MEMORY_CLOCK)   
variable received_irq : STD_LOGIC_VECTOR(7 downto 0); 
begin  
    if (rising_edge(T_MEMORY_CLOCK)) then
        case TEST_NEXT_STATE is
            when startup =>
                T_WRITE_FLAG <= MODE_WRITE;
                TEST_NEXT_STATE <= write_timeout_ms_0;
            when write_timeout_ms_0 =>
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_PERIOD_MS;
                T_BUS_WRITE_DATA <= x"0A";            
                TEST_NEXT_STATE <= write_timeout_ms_1;
            when write_timeout_ms_1 =>
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_PERIOD_MS_1;
                T_BUS_WRITE_DATA <= x"00";            
                TEST_NEXT_STATE <= write_timeout_ms_2;
            when write_timeout_ms_2 =>
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_PERIOD_MS_2;
                T_BUS_WRITE_DATA <= x"00";            
                TEST_NEXT_STATE <= write_timeout_ms_3;
            when write_timeout_ms_3 =>
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_PERIOD_MS_3;
                T_BUS_WRITE_DATA <= x"00"; -- 10ms timer cycle            
                TEST_NEXT_STATE <= start_timer;
            when start_timer =>
                T_WRITE_FLAG <= MODE_WRITE;
                T_BUS_ADDRESS <= PIO_IRQ_TIMER_CTL;
                T_BUS_WRITE_DATA <= IRQ_TIMER_CTL_RUN;
                TEST_NEXT_STATE <= idle; -- trigger switches too
            when idle =>
                if (T_RESET = '1') then
                    T_SWITCH_VECTOR <= x"0000";
                    TEST_NEXT_STATE <= switch_triggered;
                else
                    TEST_NEXT_STATE <= idle;
                end if;
            when switch_triggered =>
                T_SWITCH_VECTOR <= x"0001";
                TEST_NEXT_STATE <= expecting_interrupt;
            when switch_untriggered =>
                T_SWITCH_VECTOR <= x"0000";
                TEST_NEXT_STATE <= expecting_interrupt;
            when expecting_interrupt =>
                T_WRITE_FLAG <= MODE_READ;
                TEST_NEXT_STATE <= expecting_interrupt;
                if (IRQ_STATE = IRQ_TRIGGERED) then
                    TEST_NEXT_STATE <= request_irqnum;
                end if;
            when request_irqnum =>
                T_WRITE_FLAG <= MODE_READ;
                T_BUS_ADDRESS <= PIO_IRQ_CONTROLLER_IRQNUM;
                TEST_NEXT_STATE <= read_irqnum_wait_for_mem;
            when read_irqnum_wait_for_mem =>
                TEST_NEXT_STATE <= read_irqnum;
            when read_irqnum =>
                -- Make sure either of the interrupts are fired, no unexpected IDs
                assert (T_BUS_READ_DATA = x"01" or T_BUS_READ_DATA = x"00" ) report "IRQ identity expected to be 1" severity failure;
                received_irq := T_BUS_READ_DATA;
                TEST_NEXT_STATE <= acknowledge_irq;
            when acknowledge_irq =>
                T_WRITE_FLAG <= MODE_WRITE;
                T_BUS_ADDRESS <= PIO_IRQ_CONTROLLER_IRQACK;
                T_BUS_WRITE_DATA <= received_irq;
                TEST_NEXT_STATE <= wait_for_irq_clear;
            when wait_for_irq_clear =>
                TEST_NEXT_STATE <= wait_for_irq_clear;
                if (IRQ_STATE = IRQ_UNTRIGGERED and received_irq = x"01") then
                    TEST_NEXT_STATE <= switch_untriggered;
                end if; 
                if (IRQ_STATE = IRQ_UNTRIGGERED and received_irq = x"00") then
                    -- Timer fired, we expect to be getting an 01 interrupt next(ish)
                    TEST_NEXT_STATE <= expecting_interrupt;
                end if;
            when others =>
                TEST_NEXT_STATE <= idle;
        end case;        
    end if;
end process;

end Behavioral;
