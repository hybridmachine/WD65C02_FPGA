----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2023 10:16:31 AM
-- Design Name: 
-- Module Name: Peripheral_IO_LED - Behavioral
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
use work.W65C02_DEFINITIONS.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Peripheral_IO_LED is
    Port ( DATA : in STD_LOGIC_VECTOR (7 downto 0);
           LED_CTL : out STD_LOGIC_VECTOR (7 downto 0);
           CLOCK : in STD_LOGIC;
           RESET : in STD_LOGIC);
end Peripheral_IO_LED;

architecture Behavioral of Peripheral_IO_LED is

begin

process (CLOCK,RESET)
begin
    if (RESET = CPU_RESET) then
        LED_CTL <= x"00";
    else
        if (CLOCK'event and CLOCK='1') then
            LED_CTL <= DATA; -- Just pass through for now, simplest memory mapped IO for now
        end if;
    end if;
end process;

end Behavioral;
