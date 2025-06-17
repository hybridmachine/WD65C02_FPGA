----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2025 09:50:32 PM
-- Design Name: 
-- Module Name: T_PIO_SWITCH_DRIVER - Behavioral
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
use work.PIO_SWITCHES;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_PIO_SWITCH_DRIVER is
--  Port ( );
end T_PIO_SWITCH_DRIVER;

architecture Behavioral of T_PIO_SWITCH_DRIVER is
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock  
    type test_state is (initialize, start, bounce_switch, steady_switch, wait_for_irq, reset);
    
    signal T_CLK : std_logic := '0';
    signal T_IRQ : std_logic;
    signal T_RST : std_logic;
    signal T_IRQ_ACK : std_logic;
    signal T_SWITCHES : STD_LOGIC_VECTOR (15 downto 0);
    signal T_UPDATED_SWITCH_VEC : STD_LOGIC_VECTOR (15 downto 0);
    signal T_PREVIOUS_SWITCH_STATE_VEC : STD_LOGIC_VECTOR(15 downto 0);
    signal test_present_state, test_next_state: test_state := initialize;
begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);

dut: entity work.PIO_SWITCHES
Generic map (
    MAX_SWITCH_IDX => 16,
    DEBOUNCE_CLOCK_CYCLES => 5000
)
Port map (
    I_CLK => T_CLK,
    I_RST => T_RST,
    I_SWITCHES => T_SWITCHES,
    I_IRQ_ACK => T_IRQ_ACK,
    O_UPDATED_SWITCH_VEC => T_UPDATED_SWITCH_VEC,
    O_PREVIOUS_SWITCH_STATE_VEC => T_PREVIOUS_SWITCH_STATE_VEC,
    O_IRQ => T_IRQ
);

test_fsm: process(T_CLK)
    variable initialize_cycles : natural := 1000;
    variable bounce_cycles : natural := 1000;
    variable steady_cycles : natural := 5000;
    variable switch_state : std_logic := '0';
begin
    case test_present_state is
        when initialize =>
            T_RST <= '0';
            if (initialize_cycles > 0) then
                initialize_cycles := initialize_cycles - 1;
                test_next_state <= initialize;
            else
                T_RST <= '1';
                test_next_state <= start;
            end if;
        when start =>
            T_IRQ_ACK <= '0';
            T_SWITCHES <= x"0000";
            test_next_state <= bounce_switch;
            switch_state := '0';
        when bounce_switch =>
            T_RST <= '1';
            T_SWITCHES(0) <= switch_state;
            if (bounce_cycles > 0) then
                test_next_state <= bounce_switch; 
                bounce_cycles := bounce_cycles - 1;            
                if (0 = (bounce_cycles mod 300)) then
                    -- Simulate a bouncing switch
                    switch_state := not switch_state;
                end if;
            else
                steady_cycles := 3000;
                T_SWITCHES(0) <= '1';
                test_next_state <= steady_switch;            
            end if;
        when steady_switch =>
            if (steady_cycles > 0) then
                steady_cycles := steady_cycles - 1;
                test_next_state <= steady_switch;
            else
                test_next_state <= wait_for_irq;
            end if;
        when wait_for_irq =>
            if (T_IRQ = '1') then
                assert (T_UPDATED_SWITCH_VEC = x"0001") report "Updated switch state incorrect" severity error;
                assert (T_PREVIOUS_SWITCH_STATE_VEC = x"0000") report "Previous switch state incorrect" severity error;
                assert ((T_UPDATED_SWITCH_VEC xor T_PREVIOUS_SWITCH_STATE_VEC) = x"0001") report "Switch state masking incorrect" severity error;
                T_IRQ_ACK <= '1';
                test_next_state <= reset;
            else
                test_next_state <= wait_for_irq;
            end if;
        when reset =>
            test_next_state <= start;
        when others =>
            test_next_state <= reset;
    end case;
    
    test_present_state <= test_next_state;
end process test_fsm;

end Behavioral;
