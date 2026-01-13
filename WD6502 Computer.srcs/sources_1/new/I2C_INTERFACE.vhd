----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/17/2024 04:28:30 PM
-- Design Name: 
-- Module Name: I2C Interface - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Adapted from EEPROM I2C example in "Circuit Design and Simulation with VHDL 2nd Edition"
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity I2C_INTERFACE is
    GENERIC (
        fclk : POSITIVE := 100_000; -- Frequency in Kilohertz, of system clock
        data_rate: POSITIVE := 100; -- Data rate for the I2C bus   
        write_time: POSITIVE := 5 -- Max write time in MS
    );
    Port (  clk                 : in STD_LOGIC;
            rst                 : in STD_LOGIC;
            stream_complete     : in STD_LOGIC; -- 0 for in progress, 1 for complete
            que_for_send        : out STD_LOGIC; -- 1 for driver to write, 0 for sending
            read_write_mode     : in STD_LOGIC; -- 1 write, 0 read
            data                : in STD_LOGIC_VECTOR (7 downto 0);
            ack_error           : out STD_LOGIC;
            i2c_target_address  : in STD_LOGIC_VECTOR(6 downto 0);
            i_sda               : in STD_LOGIC;
            o_sda               : out STD_LOGIC;
            scl                 : out STD_LOGIC);
end I2C_INTERFACE;

architecture finite_state_machine of I2C_INTERFACE is

constant scl_divider: INTEGER := (fclk/8)/data_rate;
constant delay: INTEGER := write_time * data_rate;

signal auxiliary_clock, bus_clock, data_clock: STD_LOGIC := '0';
signal data_in, data_out: STD_LOGIC_VECTOR(7 downto 0);
signal wr_flag, rd_flag: STD_LOGIC;
signal ack: STD_LOGIC_VECTOR(2 downto 0);
signal timer: NATURAL RANGE 0 to delay;
signal que_for_send_sig : STD_LOGIC := '1';

shared variable idx: NATURAL RANGE 0 to delay;
-- State machine signals
TYPE state_type IS (idle, send_start, start_wr, start_rd, dev_addr_wr, dev_addr_rd, wr_addr, wr_data, rd_data, stop, no_ack, send_read_write_mode, ack1, ack2, ack3, ack4);
signal present_state, next_state: state_type;
signal sda_in : std_logic;
signal sda_out : std_logic;
signal IOBUF_MODE : std_logic;
         
begin 
    ack_error <= ack(0) OR ack(1) OR ack(2); 
    que_for_send <= que_for_send_sig;
    
    sda_in <= i_sda;
    o_sda <= sda_out;
    
    ------ Auxiliary clock -----------------------------
    -- Frequency = 4 * data_rate

    process(clk)
        VARIABLE count: INTEGER RANGE 0 to scl_divider := 0;
    begin
        if (rising_edge(clk)) then
            count := count + 1;                        
            if (count >= scl_divider) then
                auxiliary_clock <= NOT auxiliary_clock;
                count := 0;
            end if;
        end if;
    end process;

    ------ Bus & Data clocks -----------------------------
    -- Frequency = 100khz for default params

    process(clk)
        variable count: INTEGER RANGE 0 to 3 := 0;
        variable auxclock_last_state : std_logic := '0';
    begin
        if (rising_edge(clk)) then
            if (auxclock_last_state /= auxiliary_clock) then
                auxclock_last_state := auxiliary_clock;
                if (auxiliary_clock = '1') then
                    count := count + 1;
                    -- Simulator wasn't honoring limit so forcing it
                    if (count > 3) then
                        count := 0;
                    end if;
                    if (count = 0) then
                        bus_clock <= '0';
                    elsif(count = 1) then
                        data_clock <= '1';
                    elsif(count = 2) then
                        bus_clock <= '1';
                    else
                        data_clock <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    ------ FSM: -----------------------------
    process(clk)
        variable data_clock_last_state : std_logic := '0';
    begin
        if (rising_edge(clk)) then
            if (data_clock_last_state /= data_clock) then
                data_clock_last_state := data_clock;
                if (data_clock = '1') then
                    if (rst = '1') then
                        present_state <= idle;
                        next_state <= idle;
                        idx := 0;
                    else
                        if (idx < timer) then
                            idx := idx + 1;
                        else
                            if (next_state /= present_state) then
                                    present_state <= next_state;
                                    idx := 0;
                            end if;
                        end if;
                    end if;
                end if;
                if (data_clock = '0') then
                    if (present_state = idle) then
                        wr_flag <= read_write_mode;
                        rd_flag <= not read_write_mode;
                    end if;
                    -- Store ACK signals during writing:
                    if (present_state = ack1) then
                        ack(0) <= sda_in;
                    elsif(present_state = ack2) then
                        ack(1) <= sda_in;
                    elsif(present_state = ack3) then
                        ack(2) <= sda_in;
                    end if;
        
                    -- Store data read from memory:
                    if (present_state = rd_data) then
                        data_in(7-idx) <= sda_in;
                    end if;
                end if; 
            end if;  
        
            case present_state is
                when idle =>
                    -- Assumption is scl and sda have pullup resisters, don't drive the bus in idle
                    scl <= 'Z';
                    sda_out <= 'Z';
                    timer <= delay;
                    que_for_send_sig <= '1'; -- Tell the caller to queue the next byte
                    if (wr_flag = '1') then
                        next_state <= start_wr;
                    elsif(rd_flag = '1') then
                        next_state <= start_rd;
                    else
                        next_state <= idle;
                    end if;
                when start_wr =>
                    sda_out <= '1';
                    scl <= '1';
                    timer <= 1;
                    que_for_send_sig <= '0'; -- About to read the data line
                    next_state <= send_start;
                when send_start =>
                    sda_out <= '0';
                    scl <= '1';
                    timer <= 1;
                    data_out <= data;
                    next_state <= dev_addr_wr;
                when dev_addr_wr => 
                    scl <= bus_clock;
                    sda_out <= i2c_target_address(6-idx);
                    timer <= 6;
                    next_state <= send_read_write_mode;
                when send_read_write_mode =>
                    scl <= bus_clock;
                    sda_out <= not wr_flag; -- 0 means we write back to client
                    timer <= 1;
                    next_state <= ack1;
                when ack1 =>
                    scl <= '0';
                    sda_out <= 'Z';
                    timer <= 1;
                    que_for_send_sig <= '1'; -- Data is read
                    next_state <= wr_data;
                when wr_data =>
                    scl <= bus_clock;
                    que_for_send_sig <= '1'; 
                    sda_out <= data_out(7-idx);
                    timer <= 7;
                    if (idx < 7) then
                        next_state <= wr_data;
                    else
                        next_state <= ack3;
                    end if;
                when ack3 =>
                    -- Todo after write is complete. run the clock 
                    -- for once cycle waiting for ack 
                    -- Then hold clock low for one cycle then 
                    -- start clock back up
                    scl <= bus_clock;
                    sda_out <= 'Z';
                    timer <= 0;
                    if (stream_complete = '0') then
                        next_state <= ack4;
                    else
                        next_state <= stop;
                    end if;
                when ack4 =>
                    scl <= '0';
                    timer <= 1;
                    que_for_send_sig <= '0'; -- Let the caller know this data is pulled in, when we lift the line on the wr_data transition, they can feed in the next byte
                    data_out <= data;
                    next_state <= wr_data;
                when stop =>
                    scl <= '1';
                    sda_out <= NOT data_clock;
                    timer <= 1;
                    next_state <= idle;
                when others =>
                    scl <= '1';
                    sda_out <= '1';
                    timer <= delay;
                    next_state <= idle;  
            end case;
        end if;
    end process;
    
end finite_state_machine;