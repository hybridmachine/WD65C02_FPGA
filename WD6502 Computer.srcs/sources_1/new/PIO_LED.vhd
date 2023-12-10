----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2023 10:16:31 AM
-- Design Name: 
-- Module Name: PIO_LED - Behavioral
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

--! \author Brian Tabone
--! @brief Peripheral IO LED driver which simply shows 8 bit binary values on 8 LEDs
--! \param DATA    The 8 bit value to display
--! \param LED_CTL   The outbound signals to drive the LEDS
--! \param CLOCK   The FPGA 100mhz clock signal
--! \param RESET   The reset signal, causes a reset pattern to be displayed
--!
entity PIO_LED is
    Port ( DATA : in STD_LOGIC_VECTOR (7 downto 0);
           LED_CTL : out STD_LOGIC_VECTOR (7 downto 0);
           CLOCK : in STD_LOGIC;
           RESET : in STD_LOGIC);
end PIO_LED;

architecture Behavioral of PIO_LED is

begin

process (CLOCK,RESET)
begin
    if (RESET = CPU_RESET) then
        LED_CTL <= "01010101";
    else
        if (CLOCK'event and CLOCK='1') then
            LED_CTL <= DATA; -- Just pass through
        end if;
    end if;
end process;

end Behavioral;
