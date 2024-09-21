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
    signal t_scl                 : STD_LOGIC;
    
    constant CLOCK_PERIOD : time := 10ns; -- 100 mhz clock
    constant DEFAULT_WAIT_PERIOD : time := 20 * CLOCK_PERIOD;
    
    constant READ_WRITE_MODE_WRITE : std_logic := '1';
    constant READ_WRITE_MODE_READ : std_logic := '0';
    constant RESET : std_logic := '1';
    constant RUN : std_logic := '0';

begin

t_clk <= not t_clk after (CLOCK_PERIOD / 2);

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
    t_i2c_target_address <= "0000111";
    t_control <= CONTROL_RESET;
    
    t_address <= std_logic_vector(to_unsigned(write_address, 16));
    t_data <= x"CE";
    write_address := write_address + 1;
    
    wait for DEFAULT_WAIT_PERIOD;
    
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
    
    wait;
end process stimuli_generator;


i2c_stream_verifier: process(t_control, t_sda, t_scl)
variable data_frame : std_logic_vector(8 downto 0) := "000000000";
variable data_frame_idx : natural range 0 to 8 := 8;
begin
    if (rising_edge(t_scl)) then
        if (t_status = STATUS_STREAMING_I2C) then
            data_frame(data_frame_idx) := t_sda;
            if (data_frame_idx <= 0) then
                data_frame_idx := 8;
                -- For now set a breakpoint here and manually check the data, see if it looks right
                data_frame := "000000000";
            else
                data_frame_idx := data_frame_idx - 1;
            end if;
        end if;
     end if;
end process i2c_stream_verifier;

end Behavioral;
