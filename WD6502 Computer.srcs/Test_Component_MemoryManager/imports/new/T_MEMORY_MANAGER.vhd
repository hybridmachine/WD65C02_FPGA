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
signal T_MEMORY_CLOCK : std_logic;
signal T_READ_WRITE_MODE : std_logic;
signal T_PIO_LED_OUT : std_logic_vector (7 downto 0);
signal T_PIO_7SEG_COMMON : std_logic_vector(3 downto 0);
signal T_PIO_7SEG_SEGMENTS : std_logic_vector(7 downto 0);
signal T_RESET : std_logic;

constant CLOCK_PERIOD : time := 10ns; -- 100mhz
constant READ_MODE : std_logic := '0';
constant WRITE_MODE : std_logic := '1';

begin

DUT : MemoryManager PORT MAP (
        MEMORY_CLOCK => T_MEMORY_CLOCK,
        WRITE_FLAG => T_READ_WRITE_MODE,
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
    wait for 10*CLOCK_PERIOD;
    T_RESET <= CPU_RUNNING;
    wait for 10*CLOCK_PERIOD;
    
    -- Check the boot vector
    T_READ_WRITE_MODE <= READ_MODE;
    T_BUS_ADDRESS <= BOOT_VEC_ADDRESS_LOW;
    wait until T_BUS_READ_DATA'event;
    assert (T_BUS_READ_DATA = BOOT_VEC(7 downto 0)) report "Invalid boot vector low bytes" severity failure;
    
    T_BUS_ADDRESS <= BOOT_VEC_ADDRESS_HIGH;
    wait until T_BUS_READ_DATA'event;
    assert (T_BUS_READ_DATA = BOOT_VEC(15 downto 8)) report "Invalid boot vector high bytes" severity failure;
    
    -- Here we read two bytes from ROM and write those two bytes to RAM
    T_READ_WRITE_MODE <= READ_MODE;    
    T_BUS_ADDRESS <= ROM_BASE;
    wait until T_BUS_READ_DATA'event;
    WRITTEN_BYTE_1 := T_BUS_READ_DATA;
    T_BUS_ADDRESS <= RAM_BASE;
    wait for CLOCK_PERIOD;
    T_READ_WRITE_MODE <= '1';
    T_BUS_WRITE_DATA <= WRITTEN_BYTE_1;
    wait for 6*CLOCK_PERIOD;
    
    T_READ_WRITE_MODE <= '0';
    T_BUS_ADDRESS <= std_logic_vector(unsigned(ROM_BASE) + 1);
    wait for 6*CLOCK_PERIOD;

    WRITTEN_BYTE_2 := T_BUS_READ_DATA;
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    wait for 4*CLOCK_PERIOD;
    T_BUS_WRITE_DATA <= WRITTEN_BYTE_2;
    T_READ_WRITE_MODE <= '1';
    wait for 6*CLOCK_PERIOD;
            
    -- Here we verify that the two bytes were written correctly to RAM
    T_READ_WRITE_MODE <= '0';
    wait for 2*CLOCK_PERIOD;
    T_BUS_ADDRESS <= RAM_BASE;
    wait for 6*CLOCK_PERIOD;

    assert (T_BUS_READ_DATA = WRITTEN_BYTE_1) report "RAM address 0 value does not match written" severity failure;
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    wait for 6*CLOCK_PERIOD;

    assert (T_BUS_READ_DATA = WRITTEN_BYTE_2) report "RAM address 1 value does not match written" severity failure;
    
    T_BUS_ADDRESS <= std_logic_vector(unsigned(PIO_LED_ADDR));
    wait for CLOCK_PERIOD;   
    T_READ_WRITE_MODE <= WRITE_MODE;
    T_BUS_WRITE_DATA <= x"FE";
    wait until T_PIO_LED_OUT'event;
    assert (T_PIO_LED_OUT = x"FE") report "LED control lines do not match requested" severity error;
    
    T_BUS_WRITE_DATA <= x"ED";
    wait until T_PIO_LED_OUT'event;
    assert (T_PIO_LED_OUT = x"ED") report "LED control lines do not match requested" severity error;

    report("Test completed successfully");
    wait;
    
    
end process;
end Behavioral;
