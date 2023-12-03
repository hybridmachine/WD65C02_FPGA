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
           DISPLAY_ON : in STD_LOGIC; -- 0 for LEDs off, 1 for display value on input
           VALUE : in STD_LOGIC_VECTOR (15 downto 0); -- 4 digits of 0-F hex. Note if using BCD , caller should limit 0-9, display doesn't truncate BCD illegal bits
           SEGMENT_DRIVERS : out STD_LOGIC_VECTOR (7 downto 0);
           COMMON_DRIVERS : out STD_LOGIC_VECTOR(3 downto 0)
           );
            
end PIO_7SEG_X_4;

architecture Behavioral of PIO_7SEG_X_4 is  
signal display_idx : natural := 0;  
signal clock_ticks : natural := CLOCK_TICKS_PER_DIGIT;
signal COMMON_DRIVERS_REG : STD_LOGIC_VECTOR(3 downto 0);
signal SEGMENT_DRIVERS_REG : STD_LOGIC_VECTOR (7 downto 0);
begin
    
    -- Register propogation
    process (CLOCK, SEGMENT_DRIVERS_REG, COMMON_DRIVERS_REG)
    BEGIN
        SEGMENT_DRIVERS <= SEGMENT_DRIVERS_REG;
        COMMON_DRIVERS <= COMMON_DRIVERS_REG;
    END PROCESS;
    
    process (CLOCK)
    variable clock_ticks_var : natural := CLOCK_TICKS_PER_DIGIT;    
    BEGIN
        clock_ticks_var := clock_ticks_var - 1;
        if (clock_ticks_var <= 0) then
            clock_ticks_var := CLOCK_TICKS_PER_DIGIT;    
        end if;    
        clock_ticks <= clock_ticks_var;
    END PROCESS;
    
    process (clock_ticks)
    variable display_idx_var : natural := 0;
    BEGIN
        if (clock_ticks = 0) then
            if (display_idx_var < 3) then
                display_idx_var := display_idx_var + 1; 
            else
                display_idx_var := 0;
            end if;                   
        end if;
        display_idx <= display_idx_var;
    END PROCESS;
    
    process (display_idx)
    begin
        if (display_idx < 4) then  
            if (display_idx = 0) then
                COMMON_DRIVERS_REG <= (0 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
            elsif (display_idx = 1) then
                COMMON_DRIVERS_REG <= (1 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
            elsif (display_idx = 2) then
                COMMON_DRIVERS_REG <= (2 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
            else
                COMMON_DRIVERS_REG <= (3 => SELECT_ACTIVE, others => not SELECT_ACTIVE);
            end if;
        else
            COMMON_DRIVERS_REG <= (others => not SELECT_ACTIVE);
        end if;
    end process;
    
    -- Drive Digits
    process (display_idx,VALUE)
    begin  
        SEGMENT_DRIVERS_REG <= (others => DISABLE_SEGMENTS_VALUE(COMMON_ANODE));      
        if (display_idx = 0) then
            SEGMENT_DRIVERS_REG <= VALUE_TO_SEGMENT(VALUE(3 downto 0), COMMON_ANODE);
        elsif (display_idx = 1) then
            SEGMENT_DRIVERS_REG <= VALUE_TO_SEGMENT(VALUE(7 downto 4), COMMON_ANODE);
        elsif (display_idx = 2) then
            SEGMENT_DRIVERS_REG <= VALUE_TO_SEGMENT(VALUE(11 downto 8), COMMON_ANODE);
        else
            SEGMENT_DRIVERS_REG <= VALUE_TO_SEGMENT(VALUE(15 downto 12), COMMON_ANODE);
        end if;
    end process;
    
end Behavioral;
