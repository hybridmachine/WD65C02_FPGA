----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2023 09:13:45 AM
-- Design Name: 
-- Module Name: T_SEVEN_SEGMENT - Behavioral
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
use work.SEVEN_SEGMENT_CA.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_SEVEN_SEGMENT is
--  Port ( );
end T_SEVEN_SEGMENT;

architecture Behavioral of T_SEVEN_SEGMENT is

COMPONENT PIO_7SEG_X_4 is
    GENERIC(
        -- On some boards, namely baysis3, the digit selector is actually low instead of high
        -- most boards are high so 1 is default, set to 0 for boards like baysis 3
        SELECT_ACTIVE : STD_LOGIC := '1';
        CLOCK_TICKS_PER_DIGIT : natural := 1000000; -- at 100mhz, this will give us 10ms per digit
        COMMON_ANODE : STD_LOGIC := '1' -- When 1, true otherwise we are in common cathode mode
    );
    Port ( CLOCK : in STD_LOGIC; -- For now we'll run this at FPGA clock speed of 100mhz
           DISPLAY_ON : STD_LOGIC; -- 0 for LEDs off, 1 for display value on input
           VALUE : in STD_LOGIC_VECTOR (15 downto 0); -- 4 digits of 0-F hex. Note if using BCD , caller should limit 0-9, display doesn't truncate BCD illegal bits
           SEGMENT_DRIVERS : out STD_LOGIC_VECTOR (7 downto 0);
           COMMON_DRIVERS : out STD_LOGIC_VECTOR(3 downto 0)
           );
            
end COMPONENT;

signal T_CLOCK : std_logic := '0';
signal T_DISPLAY_ON : STD_LOGIC;
signal T_VALUE : STD_LOGIC_VECTOR(15 downto 0);
signal T_SEGMENT_DRIVERS : STD_LOGIC_VECTOR(7 downto 0);
signal T_COMMON_DRIVERS : STD_LOGIC_VECTOR(3 downto 0);
signal T_SEGMENT_ALL_OFF : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');


constant SEGMENT_CLOCK_PERIOD : time := 10 ns; -- 100 MHZ

begin

-- Clock concurrent process
T_CLOCK <= not T_CLOCK after (SEGMENT_CLOCK_PERIOD / 2);

DUT: PIO_7SEG_X_4 
    generic map (SELECT_ACTIVE => '0')
    port map (
        CLOCK => T_CLOCK,
        DISPLAY_ON => T_DISPLAY_ON,
        VALUE => T_VALUE,
        SEGMENT_DRIVERS => T_SEGMENT_DRIVERS,
        COMMON_DRIVERS => T_COMMON_DRIVERS        
    );

main_test_proc : process
    variable T_EXPECTED_SEGMNETS : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');
begin

    T_DISPLAY_ON <= '0';
    T_VALUE <= x"0001";

    WAIT UNTIL T_COMMON_DRIVERS = not x"0"; -- On Baysis 3, all F is off 
    WAIT for 100ns;
    
    ASSERT T_SEGMENT_DRIVERS = T_SEGMENT_ALL_OFF report "Segments not off!" severity failure;
    
    T_DISPLAY_ON <= '1';
    T_VALUE <= x"0001";
   
    WAIT UNTIL T_COMMON_DRIVERS = not "0001"; -- First digit
    T_EXPECTED_SEGMNETS := not (CB or CC);
    ASSERT T_SEGMENT_DRIVERS = T_EXPECTED_SEGMNETS report "Segments don't match!" severity failure;
    
    T_VALUE <= x"0020";
    WAIT UNTIL T_COMMON_DRIVERS = not "0001"; -- First digit
    T_EXPECTED_SEGMNETS := not (CA or CB or CC or CD or CE or CF); -- 0
    ASSERT T_SEGMENT_DRIVERS = T_EXPECTED_SEGMNETS report "First digit is not off" severity failure;
    
    WAIT UNTIL T_COMMON_DRIVERS = not "0010"; -- Second digit
    T_EXPECTED_SEGMNETS := not (CA or CB or CD or CE or CG); -- 2
    ASSERT T_SEGMENT_DRIVERS = T_EXPECTED_SEGMNETS report "Segments don't match!" severity failure;
    
    -- Force the test to end (not an actual failure), report success
    ASSERT FALSE report "Test completed successfully" severity failure;
    
end process main_test_proc;

end Behavioral;
