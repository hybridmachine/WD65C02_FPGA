----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2024 03:04:47 PM
-- Design Name: 
-- Module Name: T_I2C_INTERFACE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Test bench for I2C component
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

entity T_I2C_INTERFACE is
--  Port ( );
end T_I2C_INTERFACE;

architecture Behavioral of T_I2C_INTERFACE is

    signal t_clk, t_rst, t_read_write_mode : std_logic := '0';
    signal t_ack_error, t_scl, t_sda : std_logic;
    signal t_data : std_logic_vector(7 downto 0);
    signal t_i2c_target_address: std_logic_vector(6 downto 0);

    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant READ_WRITE_MODE_WRITE : std_logic := '1';
    constant READ_WRITE_MODE_READ : std_logic := '0';
    constant RESET : std_logic := '1';
    constant RUN : std_logic := '0';

begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);

dut: entity work.I2C_INTERFACE
    port map(clk => t_clk, 
             rst => t_rst, 
             read_write_mode => t_read_write_mode, 
             ack_error => t_ack_error,
             data => t_data,
             i2c_target_address => t_i2c_target_address,
             sda => t_sda,
             scl => t_scl);

stimuli_generator: process begin
    t_rst <= RESET;
    t_data <= x"AB";
    t_i2c_target_address <= "0001111"; -- 0x0F
    t_read_write_mode <= READ_WRITE_MODE_WRITE;
    wait for 10 * CLOCK_PERIOD;
    t_rst <= RUN; 
    wait; -- For now just wait, we'll add continue conditions later
end process stimuli_generator;

response_checker: process(t_rst, t_scl, t_sda) 
    variable idx : natural range 0 to 7 := 0;
    variable received_data : std_logic_vector(7 downto 0);
begin
    if (rising_edge(t_scl)) then
        if (t_rst = RUN) then
            if (idx < 7) then
                received_data(idx) := t_sda;
                idx := idx + 1;
            else
                assert(received_data = t_data) report "Data sent and received do not match!" severity failure;
                --wait; -- Success so break here
            end if;
        end if;
    end if;
end process response_checker;

end Behavioral;
