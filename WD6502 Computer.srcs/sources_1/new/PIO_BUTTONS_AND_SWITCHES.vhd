----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 05/31/2025 10:57:07 PM
-- Design Name: 
-- Module Name: PIO_SWITCHES - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Takes in individual switch lines, when an event occurs, stores event in a queue 
-- and fires IRQ. Note the event ID and tranition boolean (1 for on, 0 for off) is put in the queue.
-- When IRQ is fired, status is made available which is STATUS_OK, STATUS_LOST_EVENT | STATE_ON, STATE_OFF
-- STATUS_LOST_EVENT is for notifying the inerrupt service routine that the buffer was full and  
-- event(s) were lost. Note events can continue to be queued while waiting for IRQ ack
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_SWITCHES is
    Port ( I_CLK : in STD_LOGIC;
           I_RST : in STD_LOGIC;
           I_SWITCHES : in STD_LOGIC_VECTOR (31 downto 0);
           O_SWITCH_ID : out STD_LOGIC_VECTOR (7 downto 0);
           O_STATUS : out STD_LOGIC_VECTOR (7 downto 0);
           O_IRQ : out STD_LOGIC
           );
end PIO_SWITCHES;

architecture Behavioral of PIO_SWITCHES is

begin


end Behavioral;
