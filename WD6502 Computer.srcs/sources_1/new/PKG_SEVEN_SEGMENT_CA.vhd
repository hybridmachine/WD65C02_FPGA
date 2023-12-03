----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/06/2023 10:06:59 AM
-- Design Name: 
-- Module Name: PKG_SEVEN_SEGMENT_CA - Behavioral
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

package SEVEN_SEGMENT_CA is
    constant CA : std_logic_vector(7 downto 0) := "00000001";
    constant CB : std_logic_vector(7 downto 0) := "00000010";
    constant CC : std_logic_vector(7 downto 0) := "00000100";
    constant CD : std_logic_vector(7 downto 0) := "00001000";
    constant CE : std_logic_vector(7 downto 0) := "00010000";
    constant CF : std_logic_vector(7 downto 0) := "00100000";
    constant CG : std_logic_vector(7 downto 0) := "01000000";
    constant DP : std_logic_vector(7 downto 0) := "10000000";
    
    function VALUE_TO_SEGMENT(
        DIGITVAL : STD_LOGIC_VECTOR(3 downto 0);
        COMMON_ANODE : STD_LOGIC) return STD_LOGIC_VECTOR; 
    
    function DISABLE_SEGMENTS_VALUE(COMMON_ANODE : STD_LOGIC) return STD_LOGIC; 
end package SEVEN_SEGMENT_CA;

package body SEVEN_SEGMENT_CA is

    -- If using common anode, drive cathodes high to turn off otherwise
    -- drive anode low to turn off
    function DISABLE_SEGMENTS_VALUE(COMMON_ANODE : STD_LOGIC) return STD_LOGIC is
    begin
         if (COMMON_ANODE = '1') then
                return '1'; -- if common anode, turn off segments by driving cathodes high
            else
                return '0'; -- if common cathode, turn off segments by driving anodes low
            end if;
    end function;
    
    function VALUE_TO_SEGMENT(DIGITVAL : STD_LOGIC_VECTOR(3 downto 0);
            COMMON_ANODE : STD_LOGIC) return STD_LOGIC_VECTOR is
    variable returnVal : std_logic_vector(7 downto 0) := "00000000";
    
    begin
        case DIGITVAL is
            when "0000" => returnVal := CA or CB or CC or CD or CE or CF;          -- 0
            when "0001" => returnVal := CB or CC;                                  -- 1
            when "0010" => returnVal := CA or CB or CD or CE or CG;                -- 2
            when "0011" => returnVal := CA or CB or CC or CD or CG;                -- 3
            when "0100" => returnVal := CB or CC or CF or CG;                      -- 4
            when "0101" => returnVal := CA or CC or CD or CF or CG;                -- 5
            when "0110" => returnVal := CA or CC or CD or CE or CF or CG;          -- 6
            when "0111" => returnVal := CA or CB or CC;                            -- 7
            when "1000" => returnVal := CA or CB or CC or CD or CE or CF or CG;    -- 8
            when "1001" => returnVal := CA or CB or CC or CD or CF or CG;          -- 9
            -- End BCD compatible digits
            when "1010" => returnVal := CA or CB or CC or CE or CF or CG;          -- A
            when "1011" => returnVal := CC or CD or CE or CF or CG;                -- b
            when "1100" => returnVal := CA or CD or CE or CF;                      -- C
            when "1101" => returnVal := CB or CC or CD or CE or CG;                -- d
            when "1110" => returnVal := CA or CD or CE or CF or CG;                -- E
            when "1111" => returnVal := CA or CE or CF or CG;                      -- F
            when others => returnVal := x"00"; -- Default off
        end case;
        
        -- Internally we set on to '1', but if in common anode mode, we turn a segment on with a low value
        if (COMMON_ANODE = '1') then
            return not returnVal;
        else 
            return returnVal; 
        end if;
        
    end function;
end package body SEVEN_SEGMENT_CA;