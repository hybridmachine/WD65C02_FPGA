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
    generic (
        MAX_SWITCH_IDX : natural := 32;
        DEBOUNCE_CLOCK_CYCLES : natural := 1000000 -- 10 ms at 100mhz
    );
    Port ( I_CLK : in STD_LOGIC;
           I_RST : in STD_LOGIC;
           I_SWITCHES : in STD_LOGIC_VECTOR ((MAX_SWITCH_IDX-1) downto 0);
           O_UPDATED_SWITCH_VEC : out STD_LOGIC_VECTOR ((MAX_SWITCH_IDX-1) downto 0);
           O_PREVIOUS_SWITCH_STATE_VEC : out STD_LOGIC_VECTOR((MAX_SWITCH_IDX-1) downto 0);
           O_IRQ : out STD_LOGIC
    );
end PIO_SWITCHES;

architecture Behavioral of PIO_SWITCHES is
    signal r_current_switch_state_vector : STD_LOGIC_VECTOR ((MAX_SWITCH_IDX - 1) downto 0);
    signal r_updated_switch_state_vector : STD_LOGIC_VECTOR ((MAX_SWITCH_IDX - 1) downto 0);
    signal r_irq : STD_LOGIC;
begin

switch_fsm : process(I_CLK,I_RST)
    variable all_unchanged : STD_LOGIC_VECTOR((MAX_SWITCH_IDX-1) downto 0) := (others => '0'); -- Ref value for all switches unchanged
    variable debounce_counter : natural := DEBOUNCE_CLOCK_CYCLES;
begin
    if (I_RST = '0') then
        r_current_switch_state_vector <= (others => '0');
        O_IRQ <= '0';
        r_irq <= '0';
        O_UPDATED_SWITCH_VEC <= (others => '0');
        r_current_switch_state_vector <= (others => '0');
        debounce_counter := DEBOUNCE_CLOCK_CYCLES;
    elsif(rising_edge(I_CLK)) then
        O_IRQ <= r_irq;
        r_updated_switch_state_vector <= r_updated_switch_state_vector and (r_current_switch_state_vector xor I_SWITCHES);
        -- We may update this to a state machine and keep raising interrupts until no more switch changes detected
        -- For now if a switch goes high during IRQ servicing, and doesn't persist that processing period of time, we'll lose that change event
        if (r_irq = '0') then
            -- Any transition will cause the corresponding bit to become 1 after the XOR
            -- Unchanged switches will return 0 during an xor regardless of state.
            O_UPDATED_SWITCH_VEC <=  r_updated_switch_state_vector; -- See what's changed
            O_PREVIOUS_SWITCH_STATE_VEC <= r_current_switch_state_vector; -- Output our current state
            r_current_switch_state_vector <= I_SWITCHES; -- Update this on the next clock cycle
                
            -- If a change is detected, and we haven't started the counter, start the counter
            -- otherwise if the counter is running, keep running the counter
            -- at the end, once the counter is at 0, if a change is still detected, fire the IRQ and reset the counter
            if ((r_current_switch_state_vector /= all_unchanged) and (debounce_counter = DEBOUNCE_CLOCK_CYCLES)) then
                debounce_counter := debounce_counter - 1;
            elsif ((debounce_counter > 0) and (debounce_counter /= DEBOUNCE_CLOCK_CYCLES)) then
                debounce_counter := debounce_counter - 1;
            elsif ((r_current_switch_state_vector /= all_unchanged) and (debounce_counter = 0)) then
                r_irq <= '1';
                debounce_counter := DEBOUNCE_CLOCK_CYCLES;   
            end if;
        end if;
    end if;
end process;

end Behavioral;
