----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 09/15/2024 04:58:24 PM
-- Design Name: 
-- Module Name: T_I2C_DATA_STREAMER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Test the streamer interface, which takes data, buffers it, then streams it out over I2C on request.
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

entity T_I2C_DATA_STREAMER is
--  Port ( );
end T_I2C_DATA_STREAMER;

architecture Behavioral of T_I2C_DATA_STREAMER is

signal t_clk : STD_LOGIC := '0';
signal t_status : STD_LOGIC_VECTOR (7 downto 0);
signal t_control : STD_LOGIC_VECTOR (7 downto 0);
signal t_address             : STD_LOGIC_VECTOR (15 downto 0);
signal t_data                :  STD_LOGIC_VECTOR (7 downto 0);
signal t_i2c_target_address  : STD_LOGIC_VECTOR(6 downto 0);
signal t_sda                 : STD_LOGIC;
signal t_scl                 : STD_LOGIC;

begin

dut: entity work.PIO_I2C_DATA_STREAMER 
Port map (  clk => t_clk,
            status => t_status,              
            control => t_control,             
            address => t_address,             
            data => t_data,                
            i2c_target_address => t_i2c_target_address,  
            sda => t_sda,                 
            scl => t_scl);                 

end Behavioral;
