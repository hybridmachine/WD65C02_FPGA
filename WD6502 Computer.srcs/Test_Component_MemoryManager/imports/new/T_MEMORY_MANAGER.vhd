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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_MEMORY_MANAGER is
--  Port ( );
end T_MEMORY_MANAGER;

architecture Behavioral of T_MEMORY_MANAGER is

COMPONENT MemoryManager is
    Port ( BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           BUS_WRITE_DATA: in STD_LOGIC_VECTOR (7 downto 0);
           BUS_ADDRESS : in STD_LOGIC_VECTOR (15 downto 0);
           MEMORY_CLOCK : in STD_LOGIC; -- Run at 2x CPU, since reads take two cycles
           WRITE_FLAG : in STD_LOGIC -- When 1, data to address, read address and store on data line otherwise
           );
end COMPONENT;

signal T_BUS_READ_DATA : STD_LOGIC_VECTOR (7 downto 0);
signal T_BUS_WRITE_DATA : STD_LOGIC_VECTOR (7 downto 0);
signal T_BUS_ADDRESS : STD_LOGIC_VECTOR (15 downto 0);
signal T_MEMORY_CLOCK : STD_LOGIC;
signal T_WRITE_FLAG : STD_LOGIC;

constant CLOCK_PERIOD : time := 100ns; -- 10mhz

-- For now copy/paste from MemoryManager.vhd, might 
-- move to a package later, for now this is good enough for testing
constant ROM_END: std_logic_vector := x"FFFF";
constant ROM_BASE: std_logic_vector := x"EFFF";
constant RAM_END: std_logic_vector := x"EFFE";
constant RAM_BASE: std_logic_vector := x"0400";
constant MEM_MAPPED_IO_END: std_logic_vector := x"03FF";
constant MEM_MAPPED_IO_BASE: std_logic_vector := x"0200";
constant STACK_END: std_logic_vector := x"01FF";
constant STACK_BASE: std_logic_vector := x"0100";
constant SYS_RESERVED_END: std_logic_vector := x"00FF";
constant SYS_RESERVED_BASE: std_logic_vector := x"0001";
constant MEM_MANAGER_STATUS: std_logic_vector := x"0000";


begin

DUT : MemoryManager PORT MAP (
        MEMORY_CLOCK => T_MEMORY_CLOCK,
        WRITE_FLAG => T_WRITE_FLAG,
        BUS_READ_DATA => T_BUS_READ_DATA,
        BUS_WRITE_DATA => T_BUS_WRITE_DATA,
        BUS_ADDRESS => T_BUS_ADDRESS
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
variable WRITE_TO_RAM: std_logic_vector(7 downto 0);
begin

    -- Here we read two bytes from ROM and write those two bytes to RAM
    T_WRITE_FLAG <= '0'; -- READ mode    
    T_BUS_ADDRESS <= ROM_BASE;
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    WRITE_TO_RAM := T_BUS_READ_DATA;
    assert (WRITE_TO_RAM = x"FE") report "ROM address 0 not FE" severity failure;
    T_WRITE_FLAG <= '1';
    T_BUS_ADDRESS <= RAM_BASE;
    T_BUS_WRITE_DATA <= WRITE_TO_RAM;
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
    WRITE_TO_RAM := T_BUS_READ_DATA;
    assert (WRITE_TO_RAM = x"ED") report "ROM address 1 not ED" severity failure;
    T_WRITE_FLAG <= '1';
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    T_BUS_WRITE_DATA <= WRITE_TO_RAM;
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
    assert (T_BUS_READ_DATA = x"FE") report "RAM address 0 not FE" severity failure;
    T_BUS_ADDRESS <= std_logic_vector(unsigned(RAM_BASE) + 1);
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '1';
    wait until T_MEMORY_CLOCK'event and T_MEMORY_CLOCK = '0';
    assert (T_BUS_READ_DATA = x"ED") report "RAM address 0 not ED" severity failure;
       
    assert (false) report "Test complete, test successful" severity failure;
    
    
end process;
end Behavioral;
