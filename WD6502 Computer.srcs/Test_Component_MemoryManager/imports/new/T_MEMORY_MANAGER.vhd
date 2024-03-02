----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/26/2023 11:43:29 AM
-- Design Name: 
-- Module Name: T_MEMORY_MANAGER - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_MEMORY_MANAGER is
--  Port ( );
end T_MEMORY_MANAGER;

architecture Behavioral of T_MEMORY_MANAGER is

COMPONENT MemoryManager is
    Port ( BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0); --! Read data
           BUS_WRITE_DATA : in STD_LOGIC_VECTOR (7 downto 0); --! Data to be written
           BUS_ADDRESS : in STD_LOGIC_VECTOR (15 downto 0); --! Read/Write address
           MEMORY_CLOCK : in STD_LOGIC; --! Memory clock, typically full FPGA clock speed
           WRITE_FLAG : in STD_LOGIC; --! When 1, write data to address, otherwise read address and output on data line
           PIO_LED_OUT : out STD_LOGIC_VECTOR (7 downto 0); --! 8 bit LED out, mapped to physical LEDs at interface
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0); --! Common drivers for seven segment displays
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0); --! Segment drivers for selected seven segment display
           RESET : in STD_LOGIC --! Reset 
           );
end COMPONENT;

signal T_BUS_READ_DATA : STD_LOGIC_VECTOR (7 downto 0);
signal T_BUS_WRITE_DATA : STD_LOGIC_VECTOR (7 downto 0);
signal T_BUS_ADDRESS : STD_LOGIC_VECTOR (15 downto 0);
signal T_MEMORY_CLOCK : STD_LOGIC;
signal T_WRITE_FLAG : STD_LOGIC;
signal T_PIO_LED_OUT : STD_LOGIC_VECTOR (7 downto 0);
signal T_PIO_7SEG_COMMON : STD_LOGIC_VECTOR(3 downto 0);
signal T_PIO_7SEG_SEGMENTS : STD_LOGIC_VECTOR(7 downto 0);
signal T_RESET : STD_LOGIC;

constant CLOCK_PERIOD : time := 100ns; -- 10mhz

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
variable WRITTEN_BYTE_1: std_logic_vector(7 downto 0);
variable WRITTEN_BYTE_2: std_logic_vector(7 downto 0);
begin

    T_RESET <= CPU_RESET;
    wait for 300ns;
    T_RESET <= CPU_RUNNING;
    wait for 300ns;
    
    -- Here we read two bytes from ROM and write those two bytes to RAM
    T_WRITE_FLAG <= '0'; -- READ mode    
    T_BUS_ADDRESS <= ROM_BASE;
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    WRITTEN_BYTE_1 := T_BUS_READ_DATA;
    T_WRITE_FLAG <= '1';
    T_BUS_ADDRESS <= RAM_BASE;
    T_BUS_WRITE_DATA <= WRITTEN_BYTE_1;
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    
    T_WRITE_FLAG <= '0';
    T_BUS_ADDRESS <= std_logic_vector(unsigned(ROM_BASE) + 1);
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    WRITTEN_BYTE_2 := T_BUS_READ_DATA;
    T_WRITE_FLAG <= '1';
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    T_BUS_WRITE_DATA <= WRITTEN_BYTE_2;
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    
        
    -- Here we verify that the two bytes were written correctly to RAM
    T_WRITE_FLAG <= '0';
    T_BUS_ADDRESS <= RAM_BASE;
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    assert (T_BUS_READ_DATA = WRITTEN_BYTE_1) report "RAM address 0 value does not match written" severity failure;
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    assert (T_BUS_READ_DATA = WRITTEN_BYTE_2) report "RAM address 1 value does not match written" severity failure;
       
    T_WRITE_FLAG <= '1';
    T_BUS_ADDRESS <= std_logic_vector(unsigned(PIO_LED_ADDR));
    T_BUS_WRITE_DATA <= x"FE";
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    assert (T_PIO_LED_OUT = x"FE") report "LED control lines do not match requested" severity error;
    T_BUS_WRITE_DATA <= x"ED";
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    assert (T_PIO_LED_OUT = x"ED") report "LED control lines do not match requested" severity error;

    assert (false) report "Test complete, test successful" severity failure;
    
    
end process;
end Behavioral;
