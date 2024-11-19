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
use work.I2C_DATA_STREAMER.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
    signal t_master_to_client_sda : std_logic;
    signal t_client_to_master_sda : std_logic;
    signal t_scl                 : STD_LOGIC;
    signal t_ack                 : STD_LOGIC;
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant DEFAULT_WAIT_PERIOD : time := 20 * CLOCK_PERIOD;
    
    constant READ_WRITE_MODE_WRITE : std_logic := '1';
    constant READ_WRITE_MODE_READ : std_logic := '0';
    constant RESET : std_logic := '1';
    constant RUN : std_logic := '0';

    type i2c_data_direction is (master_to_client, client_to_master);
    type i2c_state_type is (idle, start, address, address_ack, data_ack, master_reading, master_writing, stop);
    signal i2c_present_state, i2c_next_state: i2c_state_type := idle;

    function I2CDataDirection(present_i2c_state : i2c_state_type) return i2c_data_direction is
    begin
        case present_i2c_state is
            when data_ack =>
                return client_to_master;
            when address_ack =>
                return client_to_master;
            when others =>
                return master_to_client;
        end case; 
    end function;
    
begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);
t_master_to_client_sda <= t_sda when (I2CDataDirection(i2c_present_state) = master_to_client)  else 'Z';
 
-- When in ack, send low signal back to master otherwise set to high impedence so master can write
t_client_to_master_sda <= '0' when (I2CDataDirection(i2c_present_state) = client_to_master) else 'Z';
t_sda <= t_client_to_master_sda when (I2CDataDirection(i2c_present_state) = client_to_master) else 'Z';

t_ack <= t_client_to_master_sda;

dut: entity work.PIO_I2C_DATA_STREAMER 
Port map (  clk => t_clk,
            status => t_status,              
            control => t_control,             
            address => t_address,             
            data => t_data,                
            i2c_target_address => t_i2c_target_address,  
            sda => t_sda,                 
            scl => t_scl);                 

stimuli_generator: process 
variable write_address : natural := 0;
begin
    t_i2c_target_address <= "1010110";
    t_control <= CONTROL_RESET;
    
    t_address <= std_logic_vector(to_unsigned(write_address, 16));
    t_data <= x"CE";
    write_address := write_address + 1;
    
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    t_control <= CONTROL_WRITE_BUFFER;
    wait until t_status = STATUS_WRITING_RAM;
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    
    t_address <= std_logic_vector(to_unsigned(write_address, 16));
    t_data <= x"FA";
    write_address := write_address + 1;    
    t_control <= CONTROL_WRITE_BUFFER;
    wait until t_status = STATUS_WRITING_RAM;
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    
    t_address <= std_logic_vector(to_unsigned(write_address, 16));
    t_data <= x"ED";
    write_address := write_address + 1;
    
    t_control <= CONTROL_WRITE_BUFFER;
    wait until t_status = STATUS_WRITING_RAM;
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    
    t_address <= std_logic_vector(to_unsigned(write_address, 16));
    t_data <= x"FE";
    write_address := write_address + 1;
    
    t_control <= CONTROL_WRITE_BUFFER;
    wait until t_status = STATUS_WRITING_RAM;
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    t_control <= CONTROL_STREAM_BUFFER;
    
    wait until t_status = STATUS_STREAMING_I2C_COMPLETE;
    t_control <= CONTROL_RESET;
    wait until t_status = STATUS_RESETTING;
    t_control <= CONTROL_STANDBY;
    wait until t_status = STATUS_READY;
    wait;
end process stimuli_generator;

-- Distribute the i2c next state
process(t_clk)
begin
    if (rising_edge(t_clk)) then
        i2c_present_state <= i2c_next_state;
    end if;
end process;

i2c_stream_verifier: process(t_sda, t_scl)
variable data_frame : std_logic_vector(7 downto 0) := "00000000";
variable address_frame : std_logic_vector(7 downto 0) := "00000000";
variable frame_idx : natural range 0 to 7 := 7;
variable ack_track : std_logic := '0';
variable ack_delay : natural range 0 to 7 := 1;
begin
    
    -- Detect start condition
    if (falling_edge(t_sda)) then
        if (t_scl = '1') then
            -- Starting
            i2c_next_state <= start;
        end if;
    end if;
    
    -- Detect stop condition
    if (rising_edge(t_sda)) then
        if (t_scl = '1') then
            i2c_next_state <= stop;
        end if;
    end if;
    
    if (falling_edge(t_scl)) then
        if (i2c_present_state = start) then
            i2c_next_state <= address;
        end if;
    end if;
    
    if (rising_edge(t_scl)) then
        ack_track := t_ack;
        if (i2c_present_state = address) then
            address_frame(frame_idx) := t_master_to_client_sda;
            if (frame_idx <= 0) then
                i2c_next_state <= address_ack;
                ack_delay := 1;
                frame_idx := 7;
            else
                frame_idx := frame_idx - 1;
            end if;
        elsif (i2c_present_state = master_writing) then
            data_frame(frame_idx) := t_master_to_client_sda;
            if (frame_idx <= 0) then
                i2c_next_state <= data_ack;
                ack_delay := 1;
                frame_idx := 7;
                -- For now set a breakpoint here and manually check the data, see if it looks right
                data_frame := "00000000";
            else
                frame_idx := frame_idx - 1;
            end if;
        elsif (i2c_present_state = address_ack or i2c_present_state = data_ack) then
            if (ack_delay <= 0) then
                i2c_next_state <= master_writing;
            else
                ack_delay := ack_delay - 1;
            end if;
        end if;
     end if;
end process i2c_stream_verifier;

end Behavioral;
