----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 03/02/2024 12:00:34 PM
-- Design Name: 
-- Module Name: T_MAPPED_PIO_ELAPSED_TIMER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Test the peripheral I/O FPGA hosted timer via the memory map (through MemoryManager)
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
use work.TIMER_CONTROL.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_MAPPED_PIO_ELAPSED_TIMER is
--  Port ( );
end T_MAPPED_PIO_ELAPSED_TIMER;

architecture Behavioral of T_MAPPED_PIO_ELAPSED_TIMER is
COMPONENT MemoryManager is
    Port ( BUS_READ_DATA : out DATA_65C02_T; --! Read data
           BUS_WRITE_DATA : in DATA_65C02_T; --! Data to be written
           BUS_ADDRESS : in ADDRESS_65C02_T; --! Read/Write address
           MEMORY_CLOCK : in STD_LOGIC; --! Memory clock, typically full FPGA clock speed
           WRITE_FLAG : in STD_LOGIC; --! When 1, write data to address, otherwise read address and output on data line
           PIO_LED_OUT : out STD_LOGIC_VECTOR (7 downto 0); --! 8 bit LED out, mapped to physical LEDs at interface
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0); --! Common drivers for seven segment displays
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0); --! Segment drivers for selected seven segment display
           RESET : in STD_LOGIC --! Reset 
           );
end COMPONENT;

signal T_BUS_READ_DATA : DATA_65C02_T;
signal T_BUS_WRITE_DATA : DATA_65C02_T;
signal T_BUS_ADDRESS : ADDRESS_65C02_T;
signal T_MEMORY_CLOCK : STD_LOGIC;
signal T_WRITE_FLAG : STD_LOGIC;
signal T_PIO_LED_OUT : STD_LOGIC_VECTOR (7 downto 0);
signal T_PIO_7SEG_COMMON : STD_LOGIC_VECTOR(3 downto 0);
signal T_PIO_7SEG_SEGMENTS : STD_LOGIC_VECTOR(7 downto 0);
signal T_RESET : STD_LOGIC;

constant CLOCK_PERIOD : time := 10ns; -- 100mhz

begin


DUT : MemoryManager PORT MAP (
        MEMORY_CLOCK => T_MEMORY_CLOCK,
        WRITE_FLAG => T_WRITE_FLAG,
        BUS_READ_DATA => T_BUS_READ_DATA,
        BUS_WRITE_DATA => T_BUS_WRITE_DATA,
        BUS_ADDRESS => T_BUS_ADDRESS,
        PIO_LED_OUT => T_PIO_LED_OUT,
        PIO_7SEG_COMMON => T_PIO_7SEG_COMMON,
        PIO_7SEG_SEGMENTS => T_PIO_7SEG_SEGMENTS,
        RESET => T_RESET
    );

-- Run the memory clock
process
begin
    T_MEMORY_CLOCK <= '0';
    wait for (CLOCK_PERIOD / 2);
    T_MEMORY_CLOCK <= '1';
    wait for (CLOCK_PERIOD / 2);
end process;

-- The test process
process
variable T_TIMER_CTL_VALUE : std_logic_vector(7 downto 0);
variable T_TIMER_LAST_READ_VALUE : TIMER_VALUE_T;
begin
-- Reset then start timer
T_TIMER_CTL_VALUE := "00000000";
T_TIMER_CTL_VALUE(CTL_BIT_RESET) := CTL_TIMER_RESET;
T_WRITE_FLAG <= '1';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_CTL;
T_BUS_WRITE_DATA <= T_TIMER_CTL_VALUE;
wait for 1ms;
T_TIMER_CTL_VALUE(CTL_BIT_RESET) := CTL_TIMER_RUN;
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_CTL;
T_BUS_WRITE_DATA <= T_TIMER_CTL_VALUE;

-- Let timer run for 20ms
wait for 20ms;

-- Verify nothing on data lines yet
T_WRITE_FLAG <= '0';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_VAL_MS;
wait for 3000ns;
assert(T_BUS_READ_DATA = x"00") report "Unexpected data on timer bus" severity error;

T_BUS_ADDRESS <= std_logic_vector(to_unsigned(to_integer(unsigned(PIO_ELAPSED_TIMER_VAL_MS))+1, T_BUS_ADDRESS'length));
assert(T_BUS_READ_DATA = x"00") report "Unexpected data on timer bus" severity error;

T_BUS_ADDRESS <= std_logic_vector(to_unsigned(to_integer(unsigned(PIO_ELAPSED_TIMER_VAL_MS))+2, T_BUS_ADDRESS'length));
assert(T_BUS_READ_DATA = x"00") report "Unexpected data on timer bus" severity error;

T_BUS_ADDRESS <= std_logic_vector(to_unsigned(to_integer(unsigned(PIO_ELAPSED_TIMER_VAL_MS))+3, T_BUS_ADDRESS'length));
assert(T_BUS_READ_DATA = x"00") report "Unexpected data on timer bus" severity error;

-- Tell timer we want to read
T_TIMER_CTL_VALUE := "00000000";
T_TIMER_CTL_VALUE(CTL_BIT_READREQ) := CTL_TIMER_RUN or READ_REQUESTED;
T_WRITE_FLAG <= '1';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_CTL;
T_BUS_WRITE_DATA <= T_TIMER_CTL_VALUE;

-- Verify data on data lines
wait for 3000ns;
T_WRITE_FLAG <= '0';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_VAL_MS;
wait for 3000ns;
assert(T_BUS_READ_DATA > x"00") report "Unexpected data on timer bus" severity error;
T_TIMER_LAST_READ_VALUE(7 downto 0) := T_BUS_READ_DATA;

-- Let timer know we are done with the read
T_TIMER_CTL_VALUE := "00000000";
T_TIMER_CTL_VALUE(CTL_BIT_READREQ) := CTL_TIMER_RUN or READ_CLEAR;
T_WRITE_FLAG <= '1';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_CTL;
T_BUS_WRITE_DATA <= T_TIMER_CTL_VALUE;

-- Verify same data on data lines
wait for 3000ns;
T_WRITE_FLAG <= '0';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_VAL_MS;
wait for 3000ns;
assert(T_BUS_READ_DATA = T_TIMER_LAST_READ_VALUE(7 downto 0)) report "Unexpected data on timer bus" severity error;
-- Tell timer we want to read again
wait for 5ms;
T_TIMER_CTL_VALUE := "00000000";
T_TIMER_CTL_VALUE(CTL_BIT_READREQ) := CTL_TIMER_RUN or READ_REQUESTED;
T_WRITE_FLAG <= '1';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_CTL;
T_BUS_WRITE_DATA <= T_TIMER_CTL_VALUE;

-- Verify new data on data lines
wait for 3000ns;
T_WRITE_FLAG <= '0';
T_BUS_ADDRESS <= PIO_ELAPSED_TIMER_VAL_MS;
wait for 5ms;
assert(T_BUS_READ_DATA > T_TIMER_LAST_READ_VALUE(7 downto 0)) report "Unexpected data on timer bus" severity error;
report "Test completed successfully!";
wait;
end process;

end Behavioral;
