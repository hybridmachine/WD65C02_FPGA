----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2024 11:22:58 PM
-- Design Name: 
-- Module Name: PKG_I2C_DATA_STREAMER - Behavioral
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

package I2C_DATA_STREAMER is
    constant CONTROL_RESET : std_logic_vector(7 downto 0) := x"00";
    constant CONTROL_WRITE_BUFFER : std_logic_vector(7 downto 0) := x"01";
    constant CONTROL_STREAM_BUFFER : std_logic_vector(7 downto 0) := x"02";
    constant CONTROL_STANDBY : std_logic_vector(7 downto 0) := x"03"; -- Set when caller is loading next byte to send

    constant STATUS_READY : std_logic_vector(7 downto 0) := x"00";
    constant STATUS_WRITING_RAM : std_logic_vector(7 downto 0) := x"01";
    constant STATUS_STREAMING_I2C : std_logic_vector(7 downto 0) := x"02";
    constant STATUS_READING_STREAM_BUFFER : std_logic_vector(7 downto 0) := x"03";
    constant STATUS_RESETTING : std_logic_vector(7 downto 0) := x"04";
    
end package I2C_DATA_STREAMER;
