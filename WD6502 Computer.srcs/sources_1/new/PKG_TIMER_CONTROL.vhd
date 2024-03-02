----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 01/28/2024 12:16:59 PM
-- Design Name: 
-- Module Name: PKG_TIMER_CONTROL - Behavioral
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

package TIMER_CONTROL is
    constant CTL_BIT_RESET   : natural := 0;    -- Set to high to request reset, low to start timer
    constant CTL_BIT_READREQ : natural := 1;    -- Set to high when read is requested by external CPU
    constant CTL_BIT_RESERV2 : natural := 2;    -- Reserved for future use
    constant CTL_BIT_RESERV3 : natural := 3;    -- Reserved for future use
    constant CTL_BIT_RESERV4 : natural := 4;    -- Reserved for future use
    constant CTL_BIT_RESERV5 : natural := 5;    -- Reserved for future use
    constant CTL_BIT_RESERV6 : natural := 6;    -- Reserved for future use
    constant CTL_BIT_RESERV7 : natural := 7;    -- Reserved for future use

    constant STS_BIT_STATE   : natural := 0;    -- 0 timer off, 1 timer running
    constant STS_BIT_READRDY : natural := 1;    -- Set to high when read is ready for external CPU
    constant STS_BIT_RESERV2 : natural := 2;    -- Reserved for future use
    constant STS_BIT_RESERV3 : natural := 3;    -- Reserved for future use
    constant STS_BIT_RESERV4 : natural := 4;    -- Reserved for future use
    constant STS_BIT_RESERV5 : natural := 5;    -- Reserved for future use
    constant STS_BIT_RESERV6 : natural := 6;    -- Reserved for future use
    constant STS_BIT_RESERV7 : natural := 7;    -- Reserved for future use
    
    -- Values to set the reset flag to for reset and run states
    constant CTL_TIMER_RESET : std_logic := '1';
    constant CTL_TIMER_RUN   : std_logic := '0';
    
    constant STS_TIMER_RUNNING   : std_logic := '1';
    constant STS_TIMER_RESETTING : std_logic := '0';
    
    constant READ_REQUESTED : std_logic := '1';
    constant READ_READY     : std_logic := '1';
    constant READ_CLEAR     : std_logic := '0';
end package TIMER_CONTROL;