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
    signal t_master_to_client_sda : std_logic;
    signal t_client_to_master_sda : std_logic;
    signal t_client_to_master_write : std_logic := '0';
    signal t_client_received_data : std_logic_vector(7 downto 0);
    signal t_stream_complete : std_logic := '0';
    signal t_que_for_send : std_logic;
    signal t_data : std_logic_vector(7 downto 0);
    signal t_data_inflight : std_logic_vector(7 downto 0);
    signal t_i2c_target_address: std_logic_vector(6 downto 0);

    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant READ_WRITE_MODE_WRITE : std_logic := '1';
    constant READ_WRITE_MODE_READ : std_logic := '0';
    constant RESET : std_logic := '1';
    constant RUN : std_logic := '0';
    type i2c_state_type is (idle, starting, addressing, ack, master_reading, master_writing, stop);
    signal present_state, next_state: i2c_state_type := idle;
begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);
t_master_to_client_sda <= t_sda;
t_sda <= t_client_to_master_sda when t_client_to_master_write = '1' else 'Z';

dut: entity work.I2C_INTERFACE
    port map(clk => t_clk, 
             rst => t_rst, 
             stream_complete => t_stream_complete,
             que_for_send => t_que_for_send,
             read_write_mode => t_read_write_mode, 
             ack_error => t_ack_error,
             data => t_data,
             i2c_target_address => t_i2c_target_address,
             sda => t_sda,
             scl => t_scl);

stimuli_generator: process begin
    t_rst <= RESET;
    t_stream_complete <= '0';
    t_data <= x"AB";
    
    
    t_i2c_target_address <= "0101011"; -- 
    t_read_write_mode <= READ_WRITE_MODE_WRITE;
    wait for 10 * CLOCK_PERIOD;
    t_rst <= RUN; 
    wait until t_que_for_send = '0';  
    wait until t_que_for_send = '1';
    t_data_inflight <= x"AB";
    t_data <= x"BC";
    wait until t_que_for_send = '0';
    wait until t_que_for_send = '1';
    t_data_inflight <= x"BC";
    t_data <= x"CD";
    wait until t_que_for_send = '0';
    wait until t_que_for_send = '1';
    t_data_inflight <= x"CD";
    t_data <= x"DE";
    wait until t_que_for_send = '0';  
    wait until t_que_for_send = '1';
    t_data_inflight <= x"DE";
    t_data <= x"EF";
    wait until t_que_for_send = '0';  
    wait until t_que_for_send = '1';
    t_data_inflight <= x"EF";
    t_stream_complete <= '1';   
    wait; -- For now just wait, we'll add continue conditions later
end process stimuli_generator;

i2c_state_propogation: process(t_clk)
begin
    if (rising_edge(t_clk)) then
        present_state <= next_state;
    end if;
end process;

i2c_test_client: process(t_scl, t_sda)
    variable frame_bit_idx : natural range 0 to 8 := 8;
    variable target_address : std_logic_vector(6 downto 0);
    variable read_write_mode : std_logic;
    variable received_data : std_logic_vector(7 downto 0);
begin
    --next_state <= present_state; -- In case no assignment
    t_client_to_master_write <= '0';
    if (falling_edge(t_sda)) then
        case present_state is
            when idle =>  
                if (t_scl = '1') then
                    next_state <= starting;
                end if;
            when others =>
                --next_state <= next_state;
        end case;
    end if;
    
    if (rising_edge(t_sda)) then
        if (t_scl = '1') then
            next_state <= stop;
        end if;
    end if;
    
    if (falling_edge(t_scl)) then
        case present_state is
            when starting =>
                frame_bit_idx := 8;
                next_state <= addressing;
            when ack =>
                frame_bit_idx := 8;
                
                t_client_to_master_sda <= '0'; -- pull low for ack to master
                t_client_to_master_write <= '1';
                
                if (read_write_mode = '0') then
                    next_state <= master_writing;
                else
                    next_state <= master_reading;
                end if;
            when others =>
                --next_state <= next_state;
        end case;
    end if;
    
    if (rising_edge(t_scl)) then
        case present_state is
            when addressing =>
                if (frame_bit_idx > 1) then
                    target_address(frame_bit_idx-2) := t_master_to_client_sda;
                elsif (frame_bit_idx = 1) then
                    assert (target_address = t_i2c_target_address) report "Target address mismatch" severity error;
                    read_write_mode := t_master_to_client_sda;
                else
                    next_state <= ack;
                end if;
                frame_bit_idx := frame_bit_idx - 1;
            when master_writing =>
                t_client_to_master_write <= '0';
                if (frame_bit_idx = 0) then
                    assert (t_data_inflight = received_data) report "Data received mismatch" severity error;
                    if (t_stream_complete = '0') then
                        next_state <= ack;
                        -- The master should send the stop signal and we'll check that in the stop state
                    end if;
                else
                    received_data(frame_bit_idx - 1) := t_master_to_client_sda;
                    t_client_received_data(frame_bit_idx - 1) <= t_master_to_client_sda;
                    frame_bit_idx := frame_bit_idx - 1;
                    next_state <= master_writing;
                end if;
            when stop =>
                next_state <= idle;
            when others =>
                --next_state <= present_state;
        end case;
    end if;
end process i2c_test_client;


end Behavioral;
