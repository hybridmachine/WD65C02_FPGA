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
        BUFFER_DEPTH : natural := 8;
        MAX_SWITCH_IDX : natural : 32
    );
    Port ( I_CLK : in STD_LOGIC;
           I_RST : in STD_LOGIC;
           I_SWITCHES : in STD_LOGIC_VECTOR ((MAX_SWITCH_IDX-1) downto 0);
           O_SWITCH_ID : out STD_LOGIC_VECTOR (7 downto 0);
           O_STATUS : out STD_LOGIC_VECTOR (7 downto 0);
           O_IRQ : out STD_LOGIC
           );
end PIO_SWITCHES;

architecture Behavioral of PIO_SWITCHES is
    type buffer_contents_type is array (natural range<>) of std_logic_vector(7 downto 0);
begin

switch_fsm : process(I_CLK,I_RST)
    variable buffer_contents: buffer_contents_type (0 to (BUFFER_DEPTH - 1));
    variable buffer_idx : natural := 0;
    variable status : STD_LOGIC_VECTOR (7 downto 0) := (others => 0);
    signal switch_vector : STD_LOGIC_VECTOR ((MAX_SWITCH_IDX - 1) downto 0);
    variable changed_switches_vector : STD_LOGIC_VECTOR((MAX_SWITCH_IDX - 1) downto 0) := (others => 0);
begin
    if (I_RST = '0')
        buffer_idx := 0;
        status := (others => 0);
        switch_vector <= (others => 0);
    elsif(rising_edge(I_CLK))
        -- Any transition will cause the corresponding bit to become 1 after the XOR
        -- Unchanged switches will return 0 during an xor regardless of state.
        changed_switches_vector := switch_vector xor I_SWITCHES;
        
    end if;
end process;

end Behavioral;
