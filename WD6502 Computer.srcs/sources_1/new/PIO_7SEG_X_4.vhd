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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_7SEG_X_4 is
    GENERIC(
    -- On some boards, namely baysis3, the digit selector is actually low instead of high
    -- most boards are high so 1 is default, set to 0 for boards like baysis 3
    SELECT_ACTIVE : STD_LOGIC := '1';
    -- Default to decimal mode Show 0-9 on each digit
    -- When set to 0 we show HEX mode (0 - F on each digit, lower case for b and d)
    DECIMAL_MODE : STD_LOGIC := '1';
    -- How many clock ticks to drive a signle digit before switching
    CLOCK_TICKS_PER_DIGIT : natural := 1000000
    );
    Port ( CLOCK : in STD_LOGIC;
           VALUE : in STD_LOGIC_VECTOR (7 downto 0);
           SEGMENT_DRIVERS : out STD_LOGIC_VECTOR (7 downto 0);
           COMMON_DRIVERS : out STD_LOGIC_VECTOR(3 downto 0)
           );
            
end PIO_7SEG_X_4;

architecture Behavioral of PIO_7SEG_X_4 is

type t_digit is array (3 downto 0) of integer;

begin
    
    -- Drive Digits
    process (CLOCK)
    variable digit_index : integer := 0;
    variable digits : t_digit;
    variable digit : integer;
    begin
       if (DECIMAL_MODE = '1') then
        digits(0) := to_integer(unsigned(VALUE)) mod 10;
        digit := to_integer(unsigned(VALUE)) / 10;
        digits(1) := digit mod 10;
        digit := digit / 10;
        digits(2) := digit mod 10;
        digit := digit / 10;
        digits(3) := digit mod 10;
        -- TODO show segments on out lines
       else
       end if;
    end process;
    
end Behavioral;
