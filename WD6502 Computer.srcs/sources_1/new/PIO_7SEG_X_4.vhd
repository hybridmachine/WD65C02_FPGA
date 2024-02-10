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

--! @author Brian Tabone
--! @brief Seven segment x 4 LED display driver
--! @details Supports both common anode and common cathode types, also allows
--! specifying the active level (high or low)
--! 
entity PIO_7SEG_X_4 is
    GENERIC(
        -- On some boards, namely baysis3, the digit selector is actually low instead of high
        -- most boards are high so 1 is default, set to 0 for boards like baysis 3
        SELECT_ACTIVE : STD_LOGIC := '1'; --! Set active high or active low
        CLOCK_TICKS_PER_DIGIT : natural := 100000000; --! Number of display clock ticks per digit (controls flicker) 
        COMMON_ANODE : STD_LOGIC := '1' --! When 1, true otherwise we are in common cathode mode
    );
    Port ( CLOCK : in STD_LOGIC; --! FPGA Clock (100mhz)
           DISPLAY_ON : in STD_LOGIC; --! 0 for LEDs off, 1 for display value on input
           VALUE : in STD_LOGIC_VECTOR (15 downto 0); --! 4 digits of 0-F hex. Note if using BCD , caller should limit 0-9, display doesn't truncate BCD illegal bits
           SEGMENT_DRIVERS : out STD_LOGIC_VECTOR (7 downto 0); --! Segment driver values (set to whatever select active is when on)
           COMMON_DRIVERS : out STD_LOGIC_VECTOR(3 downto 0) --! Which seven segment display is active out of the four available
           );
            
end PIO_7SEG_X_4;

architecture Behavioral of PIO_7SEG_X_4 is  

signal segments_digit_1 : std_logic_vector (7 downto 0);
signal segments_digit_2 : std_logic_vector (7 downto 0);
signal segments_digit_3 : std_logic_vector (7 downto 0);
signal segments_digit_4 : std_logic_vector (7 downto 0);

type DIGIT_DRIVE_T is ( DIGIT1,
                        DIGIT2,
                        DIGIT3,
                        DIGIT4,
                        ALLOFF);

signal DIGIT_DRIVE : DIGIT_DRIVE_T := ALLOFF;

begin

    segments_digit_1 <= VALUE_TO_SEGMENT(VALUE(3 downto 0), COMMON_ANODE); 
    segments_digit_2 <= VALUE_TO_SEGMENT(VALUE(7 downto 4), COMMON_ANODE); 
    segments_digit_3 <= VALUE_TO_SEGMENT(VALUE(11 downto 8), COMMON_ANODE); 
    segments_digit_4 <= VALUE_TO_SEGMENT(VALUE(15 downto 12), COMMON_ANODE); 

seven_segment_statemachine: process(CLOCK)
variable clock_ticks_var : natural := CLOCK_TICKS_PER_DIGIT;
BEGIN
    if (rising_edge(CLOCK)) then
        if (clock_ticks_var > 0) then
            clock_ticks_var := clock_ticks_var - 1;
        end if;
            
        case DIGIT_DRIVE is
            when ALLOFF =>
                if (DISPLAY_ON = '1') then
                    DIGIT_DRIVE <= DIGIT1;
                else
                    SEGMENT_DRIVERS <= (others => DISABLE_SEGMENTS_VALUE(COMMON_ANODE));
                    COMMON_DRIVERS <= (others => not SELECT_ACTIVE); -- All common anodes off
                    DIGIT_DRIVE <= ALLOFF;
                end if;
            when DIGIT1 =>
                COMMON_DRIVERS <= (0 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
                SEGMENT_DRIVERS <= segments_digit_1;
                if (DISPLAY_ON = '1') then
                    DIGIT_DRIVE <= DIGIT1;
                    if (clock_ticks_var = 0) then
                        clock_ticks_var := CLOCK_TICKS_PER_DIGIT;
                        DIGIT_DRIVE <= DIGIT2;
                    end if;
                else
                    DIGIT_DRIVE <= ALLOFF;
                end if;
            when DIGIT2 =>
                COMMON_DRIVERS <= (1 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
                SEGMENT_DRIVERS <= segments_digit_2;
                if (DISPLAY_ON = '1') then
                    DIGIT_DRIVE <= DIGIT2;
                    if (clock_ticks_var = 0) then
                        clock_ticks_var := CLOCK_TICKS_PER_DIGIT;
                        DIGIT_DRIVE <= DIGIT3;
                    end if;
                else
                    DIGIT_DRIVE <= ALLOFF;
                end if;
            when DIGIT3 =>
                COMMON_DRIVERS <= (2 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
                SEGMENT_DRIVERS <= segments_digit_3;
                if (DISPLAY_ON = '1') then
                    DIGIT_DRIVE <= DIGIT3;
                    if (clock_ticks_var = 0) then
                        clock_ticks_var := CLOCK_TICKS_PER_DIGIT;
                        DIGIT_DRIVE <= DIGIT4;
                    end if;
                else
                    DIGIT_DRIVE <= ALLOFF;
                end if;
            when DIGIT4 =>
                COMMON_DRIVERS <= (3 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
                SEGMENT_DRIVERS <= segments_digit_4;
                if (DISPLAY_ON = '1') then
                    DIGIT_DRIVE <= DIGIT4;
                    if (clock_ticks_var = 0) then
                        clock_ticks_var := CLOCK_TICKS_PER_DIGIT;
                        DIGIT_DRIVE <= DIGIT1; -- Start from the top
                    end if;
                else
                    DIGIT_DRIVE <= ALLOFF;
                end if;
            when others =>
                DIGIT_DRIVE <= ALLOFF;
        end case;
    end if;
END PROCESS seven_segment_statemachine; 
    
end Behavioral;
