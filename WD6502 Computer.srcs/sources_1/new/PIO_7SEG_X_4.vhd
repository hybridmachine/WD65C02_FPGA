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
    
    function DISABLE_SEGMENTS_VALUE return STD_LOGIC is
    begin
         if (COMMON_ANODE = '1') then
                return '1'; -- if common anode, turn off segments by driving cathodes high
            else
                return '0'; -- if common cathode, turn off segments by driving anodes low
            end if;
    end function;
    
    function VALUE_TO_SEGMENT(DIGITVAL : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    constant CA : std_logic_vector(7 downto 0) := "00000001";
    constant CB : std_logic_vector(7 downto 0) := "00000010";
    constant CC : std_logic_vector(7 downto 0) := "00000100";
    constant CD : std_logic_vector(7 downto 0) := "00001000";
    constant CE : std_logic_vector(7 downto 0) := "00010000";
    constant CF : std_logic_vector(7 downto 0) := "00100000";
    constant CG : std_logic_vector(7 downto 0) := "01000000";
    constant DP : std_logic_vector(7 downto 0) := "10000000";
    variable returnVal : std_logic_vector(7 downto 0) := "00000000";
    
    begin
        case DIGITVAL is
            when "0000" => returnVal := CA & CB & CC & CD & CE & CF;          -- 0
            when "0001" => returnVal := CB & CC;                              -- 1
            when "0010" => returnVal := CA & CB & CD & CE & CG;               -- 2
            when "0011" => returnVal := CA & CB & CC & CD & CG;               -- 3
            when "0100" => returnVal := CB & CC & CF & CG;                    -- 4
            when "0101" => returnVal := CA & CC & CD & CF & CG;               -- 5
            when "0110" => returnVal := CA & CC & CD & CE & CF & CG;          -- 6
            when "0111" => returnVal := CA & CB & CC;                         -- 7
            when "1000" => returnVal := CA & CB & CC & CD & CE & CF & CG;     -- 8
            when "1001" => returnVal := CA & CB & CC & CD & CF & CG;          -- 9
            -- End BCD compatible digits
            when "1010" => returnVal := CA & CB & CC & CE & CF & CG;          -- A
            when "1011" => returnVal := CC & CD & CE & CF & CG;               -- b
            when "1100" => returnVal := CA & CD & CE & CF;                    -- C
            when "1101" => returnVal := CB & CC & CD & CE & CG;               -- d
            when "1110" => returnVal := CA & CD & CE & CF & CG;               -- E
            when "1111" => returnVal := CA & CE & CF & CG;                    -- F
            when others => returnVal := x"00"; -- Default off
        end case;
        
        -- Internally we set on to '1', but if in common anode mode, we turn a segment on with a low value
        if (COMMON_ANODE = '1') then
            return not returnVal;
        else 
            return returnVal; 
        end if;
        
    end function;
begin
    
    -- Drive Digits
    process (CLOCK)
    variable display_idx : natural := 0;
    variable clock_ticks : natural := CLOCK_TICKS_PER_DIGIT;
    
    begin
        if (clock_ticks = 0) then
            clock_ticks := CLOCK_TICKS_PER_DIGIT;
            if (display_idx >= 3) then
                display_idx := 0;
            else
                display_idx := display_idx + 1;
            end if;
        else
            clock_ticks := clock_ticks - 1;
        end if;
        
        if (DISPLAY_ON = '1') then
            COMMON_DRIVERS <= (others => not SELECT_ACTIVE); -- Turn off all anodes
            COMMON_DRIVERS(display_idx) <= '1'; -- Turn on the specified digit
            SEGMENT_DRIVERS <= (others => DISABLE_SEGMENTS_VALUE);
            SEGMENT_DRIVERS <= VALUE_TO_SEGMENT(VALUE);
        else
            COMMON_DRIVERS <= (others => not SELECT_ACTIVE); -- Turn off all anodes
            SEGMENT_DRIVERS <= (others => DISABLE_SEGMENTS_VALUE);
        end if;
            
    end process;
    
end Behavioral;
