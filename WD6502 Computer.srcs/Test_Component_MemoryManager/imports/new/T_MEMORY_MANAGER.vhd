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
    signal T_MEMORY_CLOCK : STD_LOGIC;
    signal T_WRITE_FLAG : STD_LOGIC;
    signal T_PIO_LED_OUT : STD_LOGIC_VECTOR (7 downto 0);
    signal T_PIO_7SEG_COMMON : STD_LOGIC_VECTOR(3 downto 0);
    signal T_PIO_7SEG_SEGMENTS : STD_LOGIC_VECTOR(7 downto 0);
    signal T_RESET : STD_LOGIC;

    constant CLOCK_PERIOD : time := 100ns; -- 10mhz
    constant WRITE_DELAY : time := (30 * CLOCK_PERIOD);
    constant READ_DELAY : time := (4 * CLOCK_PERIOD);
    constant READ_MODE : std_logic := '0';
    constant WRITE_MODE : std_logic := '1';

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
    procedure BasicReadWriteTest is
        variable WRITTEN_BYTE_1: std_logic_vector(7 downto 0);
        variable WRITTEN_BYTE_2: std_logic_vector(7 downto 0);
    begin
        -- Here we read two bytes from ROM and write those two bytes to RAM
        T_WRITE_FLAG <= READ_MODE;    
        T_BUS_ADDRESS <= ROM_BASE;
        wait for (4 * CLOCK_PERIOD);
        
        WRITTEN_BYTE_1 := T_BUS_READ_DATA;
        
        T_WRITE_FLAG <= WRITE_MODE;
        T_BUS_ADDRESS <= RAM_BASE;
        T_BUS_WRITE_DATA <= WRITTEN_BYTE_1;
        wait for WRITE_DELAY; -- Give the delay time to wait for stable processor
        
        T_WRITE_FLAG <= READ_MODE;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(ROM_BASE) + 1);
        wait for READ_DELAY;
        
        WRITTEN_BYTE_2 := T_BUS_READ_DATA;
        T_WRITE_FLAG <= WRITE_MODE;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
        T_BUS_WRITE_DATA <= WRITTEN_BYTE_2;
        wait for WRITE_DELAY;
            
        -- Here we verify that the two bytes were written correctly to RAM
        T_WRITE_FLAG <= READ_MODE;
        T_BUS_ADDRESS <= RAM_BASE;
        wait for READ_DELAY;
        
        assert (T_BUS_READ_DATA = WRITTEN_BYTE_1) report "RAM address 0 value does not match written" severity failure;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
        wait for READ_DELAY;
        
        assert (T_BUS_READ_DATA = WRITTEN_BYTE_2) report "RAM address 1 value does not match written" severity failure;
        
        T_WRITE_FLAG <= WRITE_MODE;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(PIO_LED_ADDR));
        T_BUS_WRITE_DATA <= x"FE";
        wait for WRITE_DELAY;
        
        assert (T_PIO_LED_OUT = x"FE") report "LED control lines do not match requested" severity error;
        T_BUS_WRITE_DATA <= x"ED";
        wait for WRITE_DELAY;
        
        assert (T_PIO_LED_OUT = x"ED") report "LED control lines do not match requested" severity error;

        report("BasicReadWriteTest completed successfully");
    end procedure;
    
    procedure ReadAfterPIOWriteTest is
    begin

        -- Write to PIO then read from RAM, should return expected value on read

        T_WRITE_FLAG <= WRITE_MODE;
        wait for WRITE_DELAY;
        
        -- Write test pattern to RAM
        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE));
        T_BUS_WRITE_DATA <= x"BE";
        wait for WRITE_DELAY;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE)+1);
        T_BUS_WRITE_DATA <= x"EF";
        wait for WRITE_DELAY;

        -- Write to PIO address
        T_BUS_ADDRESS <= std_logic_vector(unsigned(PIO_7SEG_VAL_1));
        T_BUS_WRITE_DATA <= x"FE";
        wait for WRITE_DELAY;
        T_BUS_ADDRESS <= std_logic_vector(unsigned(PIO_7SEG_VAL_2));
        T_BUS_WRITE_DATA <= x"ED";
        wait for WRITE_DELAY;

        -- Read back test pattern from RAM
        T_WRITE_FLAG <= READ_MODE;
        wait for READ_DELAY;

        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE));
        wait for READ_DELAY;
        report "BUS read data is 0x" & to_hstring(T_BUS_READ_DATA);
        
        assert (T_BUS_READ_DATA = x"BE") report "RAM base pattern does not match" severity error;
        
        T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE)+1);
        wait for READ_DELAY;
        assert (T_BUS_READ_DATA = x"EF") report "RAM base + 1 pattern does not match" severity error;

        report("ReadAfterPIOWriteTest completed successfully");
    end procedure;
begin

    T_RESET <= CPU_RESET;
    wait for 300ns;
    T_RESET <= CPU_RUNNING;
    wait for 300ns;

    BasicReadWriteTest;
    
    ReadAfterPIOWriteTest;
    
    wait;
end process;
end Behavioral;
