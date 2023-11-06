----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2023 10:24:15 PM
-- Design Name: 
-- Module Name: PIO_7SEG_X_4 - Behavioral
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
use work.SEVEN_SEGMENT_CA.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_7SEG_X_4 is
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
            
end PIO_7SEG_X_4;

architecture Behavioral of PIO_7SEG_X_4 is    
begin
    
    -- Drive Digits
    process (CLOCK)
    variable display_idx : natural := 0;
    variable clock_ticks : natural := CLOCK_TICKS_PER_DIGIT;
    constant nibble_width : natural := 4;
    variable nibble_high : natural := (nibble_width * (display_idx + 1)) - 1;
    variable nibble_low : natural := nibble_high - (nibble_width - 1);
    begin
        if (clock_ticks = 0) then
            clock_ticks := CLOCK_TICKS_PER_DIGIT;
            if (display_idx >= 3) then
                display_idx := 0;
            else
                display_idx := display_idx + 1;
            end if;
            nibble_high := (nibble_width * (display_idx + 1)) - 1;
            nibble_low := nibble_high - (nibble_width - 1);
        else
            clock_ticks := clock_ticks - 1;
        end if;
        
        if (DISPLAY_ON = '1') then
            COMMON_DRIVERS <= (others => not SELECT_ACTIVE); -- Turn off all anodes
            COMMON_DRIVERS(display_idx) <= SELECT_ACTIVE; -- Turn on the specified digit
            SEGMENT_DRIVERS <= (others => DISABLE_SEGMENTS_VALUE(COMMON_ANODE));
            SEGMENT_DRIVERS <= VALUE_TO_SEGMENT(VALUE(nibble_high downto nibble_low), COMMON_ANODE);
        else
            COMMON_DRIVERS <= (others => not SELECT_ACTIVE); -- Turn off all anodes
            SEGMENT_DRIVERS <= (others => DISABLE_SEGMENTS_VALUE(COMMON_ANODE));
        end if;
            
    end process;
    
end Behavioral;
