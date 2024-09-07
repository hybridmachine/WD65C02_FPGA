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
--library UNISIM;
--use UNISIM.VComponents.all;

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
            sda                 : inout STD_LOGIC;
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
TYPE state_type IS (idle, start_wr, start_rd, dev_addr_wr, dev_addr_rd, wr_addr, wr_data, rd_data, stop, no_ack, send_read_write_mode, ack1, ack2, ack3, ack4);
signal present_state, next_state: state_type;

begin

    ack_error <= ack(0) OR ack(1) OR ack(2); 
    que_for_send <= que_for_send_sig;
    
    ------ Auxiliary clock -----------------------------
    -- Frequency = 4 * data_rate

    process(clk)
        VARIABLE count: INTEGER RANGE 0 to scl_divider := 0;
    begin
        if (rising_edge(clk)) then
            count := count + 1;
            -- We've drained the queue, pull in the data then we'll signal the caller to send the next byte
            if (present_state = wr_data) then
                que_for_send_sig <= '1'; -- Tell the caller to queue the next byte
            end if;
            
            -- Notify the caller that we are about to launch data
            if (que_for_send_sig = '1' and present_state /= idle) then
                que_for_send_sig <= '0'; -- Let the caller know this data is pulled in, when we lift the line on the wr_data transition, they can feed in the next byte
            end if;
            
            -- The caller has been notified, data should be safe to copy to internal register
            if (que_for_send_sig = '0' and present_state /= wr_data) then
                data_out <= data;
            end if;
            
            if (count = scl_divider) then
                auxiliary_clock <= NOT auxiliary_clock;
                count := 0;
            end if;
        end if;
    end process;

    ------ Bus & Data clocks -----------------------------
    -- Frequency = 100khz for default params

    process(auxiliary_clock)
        variable count: INTEGER RANGE 0 to 3 := 0;
    begin
        if (rising_edge(auxiliary_clock)) then
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
    end process;

    ------ Lower section of FSM: -----------------------------
    process(data_clock)
    begin
        if (rising_edge(data_clock)) then
            if (rst = '1') then
                present_state <= idle;
                idx := 0;
            else
                if (idx = timer-1) then
                    present_state <= next_state;
                    idx := 0;
                else
                    idx := idx + 1;
                end if;
            end if;
        end if;
        if (falling_edge(data_clock)) then
            if (present_state = idle) then
                wr_flag <= read_write_mode;
                rd_flag <= not read_write_mode;
            end if;
            -- Store ACK signals during writing:
            if (present_state = ack1) then
                ack(0) <= sda;
            elsif(present_state = ack2) then
                ack(1) <= sda;
            elsif(present_state = ack3) then
                ack(2) <= sda;
            end if;

            -- Store data read from memory:
            if (present_state = rd_data) then
                data_in(7-idx) <= sda;
            end if;
        end if;   
    end process;

    ----Upper section of FSM:---------------------
    process(present_state, bus_clock, data_clock, wr_flag, rd_flag, data_out, sda)
    begin
        case present_state is
            when idle =>
                scl <= '1';
                sda <= '1';
                timer <= delay;
                if (wr_flag = '1' or rd_flag = '1') then
                    next_state <= start_wr;
                else
                    next_state <= idle;
                end if;
            when start_wr =>
                scl <= '1';
                sda <= data_clock;
                timer <= 1;
                next_state <= dev_addr_wr;
            when dev_addr_wr => 
                scl <= bus_clock;
                sda <= i2c_target_address(6-idx);
                timer <= 7;
                next_state <= send_read_write_mode;
            when send_read_write_mode =>
                scl <= bus_clock;
                sda <= not wr_flag; -- 0 means we write back to client
                timer <= 1;
                next_state <= ack1;
            when ack1 =>
                scl <= bus_clock;
                sda <= 'Z';
                timer <= 1;
                next_state <= wr_data;
            when wr_data =>
                scl <= bus_clock;
                sda <= data_out(7-idx);
                timer <= 8;
                next_state <= ack3;
            when ack3 =>
                scl <= bus_clock;
                sda <= 'Z';
                timer <= 1;
                if (stream_complete = '0') then
                    next_state <= wr_data;
                else
                    next_state <= stop;
                end;
            when stop =>
                scl <= '1';
                sda <= NOT data_clock;
                timer <= 1;
                next_state <= idle;
            when others =>
                next_state <= idle;  
        end case;
    end process;
    
end finite_state_machine;