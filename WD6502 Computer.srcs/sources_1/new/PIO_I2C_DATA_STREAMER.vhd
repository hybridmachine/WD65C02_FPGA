----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/09/2024 04:28:30 PM
-- Design Name: 
-- Module Name: PIO_I2C_DATA_STREAMER - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: This programmable I/O subsystem takes in data (one byte at a time), fills up a 1KB buffer then on completion, triggers that data to stream
-- out over the I2C interface.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.I2C_DATA_STREAMER.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PIO_I2C_DATA_STREAMER is
    Port (  clk                 : in STD_LOGIC;
            -- No reset, as per Ultra Fast Desig Guide don't use if it can be avoided, users can reset via the control bus
            status              : out STD_LOGIC_VECTOR (7 downto 0);
            control             : in STD_LOGIC_VECTOR (7 downto 0);
            address             : in STD_LOGIC_VECTOR (15 downto 0);
            data                : in STD_LOGIC_VECTOR (7 downto 0);
            i2c_target_address  : in STD_LOGIC_VECTOR(6 downto 0);
            sda                 : inout STD_LOGIC;
            scl                 : out STD_LOGIC);
end PIO_I2C_DATA_STREAMER;

architecture Behavioral of PIO_I2C_DATA_STREAMER is

COMPONENT RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**11 -- 2KB buffer
    );
    PORT (
	addra: IN std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
	addrb: IN std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_vector((DATA_WIDTH - 1) downto 0);
	dinb: IN std_logic_vector((DATA_WIDTH - 1) downto 0);
	douta: OUT std_logic_vector((DATA_WIDTH - 1) downto 0);
	doutb: OUT std_logic_vector((DATA_WIDTH - 1) downto 0);
	wea: IN std_logic;
	web: IN std_logic;
	ena: IN std_logic;
	enb: IN std_logic
  );
end COMPONENT;

COMPONENT I2C_INTERFACE is
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
end COMPONENT;

constant DATA_WIDTH: natural := 8;
constant ADDRESS_WIDTH: natural := 16;
constant SCL_CLOCK_DIVISOR: natural := 1000; -- At 100MHZ, gives us 100KHZ


-- RAM signals
signal ram_addra: std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
signal ram_addrb: std_logic_vector((ADDRESS_WIDTH - 1) downto 0);
signal ram_clka: std_logic;
signal ram_clkb: std_logic;
signal ram_dina: std_logic_vector((DATA_WIDTH - 1) downto 0);
signal ram_dinb: std_logic_vector((DATA_WIDTH - 1) downto 0);
signal ram_douta: std_logic_vector((DATA_WIDTH - 1) downto 0);
signal ram_doutb: std_logic_vector((DATA_WIDTH - 1) downto 0);
signal ram_wea: std_logic := '0';
signal ram_web: std_logic := '0';
signal ram_ena: std_logic := '1';
signal ram_enb: std_logic := '1';

signal control_reg : std_logic_vector(control'length-1 downto 0);

type STREAMER_STATE_T is ( RESET_START,
                    RESET_INPROGRESS,
                    RESET_COMPLETE,
                    READY,
                    STREAM_DATA_OVER_I2C_READ_FROM_RAM,
                    STREAM_DATA_OVER_I2C_WRITE_TO_I2C,
                    STREAM_DATA_OVER_I2C_WAITFOR_DATA_INFLIGHT,
                    WRITE_DATA_TO_BUFFER_START,
                    WRITE_DATA_TO_BUFFER_COMMIT,
                    WRITE_DATA_TO_BUFFER_COMPLETE);

signal CURRENT_STREAMER_STATE : STREAMER_STATE_T;
signal NEXT_STREAMER_STATE : STREAMER_STATE_T;

type IC2_STATE_T is ( START_WRITE,
    START_READ,
    SEND_BYTE,
    WAIT_ACK,
    RESET,
    STANDBY
);

signal CURRENT_I2C_STATE : IC2_STATE_T := STANDBY;
signal NEXT_I2C_STATE : IC2_STATE_T := STANDBY;

signal i2c_reset : std_logic := '1';
signal i2c_readwrite_mode : std_logic := '0';
signal i2c_data : std_logic_vector(7 downto 0);
signal i2c_ack_error : std_logic := '0';
signal i2c_stream_complete : STD_LOGIC; -- 0 for in progress, 1 for complete
signal i2c_que_for_send : STD_LOGIC; -- 1 for driver to write, 0 for sending
signal status_reg : std_logic_vector(7 downto 0);

begin

RAM_DEVICE: RAM port map (
    addra => ram_addra,
    addrb => ram_addrb,
    dina => ram_dina,
    dinb => ram_dinb,
    douta => ram_douta,
    doutb => ram_doutb,
    wea => ram_wea,
    web => ram_web,
    clka => ram_clka,
    clkb => ram_clkb,
    ena => ram_ena,
    enb => ram_enb
); 

I2C_DEVICE: I2C_INTERFACE port map (
    clk => clk,
    rst => i2c_reset,
    stream_complete => i2c_stream_complete,
    que_for_send => i2c_que_for_send,
    read_write_mode => i2c_readwrite_mode,
    data => i2c_data,
    ack_error => i2c_ack_error,
    i2c_target_address => i2c_target_address,
    sda => sda, 
    scl => scl
);

ram_ena <= '1';
ram_enb <= '1';

ram_clka <= clk;
ram_clkb <= clk;

ram_web <= '0'; -- B is our read only port

process(clk) begin
    if (rising_edge(clk)) then
        status <= status_reg;
        control_reg <= control;
        if (control = CONTROL_RESET) then
            CURRENT_STREAMER_STATE <= RESET_START;
        else
            CURRENT_STREAMER_STATE <= NEXT_STREAMER_STATE;     
        end if;
    end if;
end process;

process(CURRENT_STREAMER_STATE, control_reg) 
variable buffer_end_address : natural range 0 to 2047 := 0;
variable byte_outbound_via_i2c : natural range 0 to 2047 := 0;
variable cycle_delay : natural range 0 to 255 := 0;
begin
    case CURRENT_STREAMER_STATE is
        when RESET_START =>
            status_reg <= STATUS_RESETTING;
            buffer_end_address := 0;
            NEXT_STREAMER_STATE <= RESET_INPROGRESS;
        when RESET_INPROGRESS =>
            status_reg <= STATUS_RESETTING;
            -- In case we need to zero out the buffer, for now we just reset the offset
            NEXT_STREAMER_STATE <= RESET_COMPLETE;
        when RESET_COMPLETE =>
            status_reg <= STATUS_RESETTING;
            NEXT_STREAMER_STATE <= READY;
        when READY =>
            status_reg <= STATUS_READY;
            if (control_reg = CONTROL_WRITE_BUFFER) then
                NEXT_STREAMER_STATE <= WRITE_DATA_TO_BUFFER_START;
            elsif (control_reg = CONTROL_STREAM_BUFFER) then
                cycle_delay := 2;
                NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_READ_FROM_RAM;
            else
                NEXT_STREAMER_STATE <= READY;
            end if;
        when WRITE_DATA_TO_BUFFER_START =>
            status_reg <= STATUS_WRITING_RAM;
            ram_wea <= '0'; -- Make sure not in write mode then setup address and data lines
            ram_addra <= address;
            ram_dina <= data; 
            NEXT_STREAMER_STATE <= WRITE_DATA_TO_BUFFER_COMMIT;
        when WRITE_DATA_TO_BUFFER_COMMIT =>
            status_reg <= STATUS_WRITING_RAM;
            ram_wea <= '1'; -- Address and data should be good, commit the write
            NEXT_STREAMER_STATE <= WRITE_DATA_TO_BUFFER_COMPLETE;
        when WRITE_DATA_TO_BUFFER_COMPLETE =>
            status_reg <= STATUS_WRITING_RAM;
            buffer_end_address := buffer_end_address + 1;
            ram_wea <= '0'; -- Write should be complete, turn off write mode
            NEXT_STREAMER_STATE <= READY;
        when STREAM_DATA_OVER_I2C_READ_FROM_RAM =>
            status_reg <= STATUS_STREAMING_I2C;
            if (byte_outbound_via_i2c <= buffer_end_address) then
                if (cycle_delay = 0) then
                    byte_outbound_via_i2c := byte_outbound_via_i2c + 1;
                    NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_WRITE_TO_I2C;
                else
                    cycle_delay := cycle_delay - 1;
                    NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_READ_FROM_RAM;
                    ram_addrb <= std_logic_vector(to_unsigned(buffer_end_address, ram_addrb'length));
                end if;
            else
                i2c_stream_complete <= '1';
                NEXT_STREAMER_STATE <= READY;
            end if;
        when STREAM_DATA_OVER_I2C_WRITE_TO_I2C =>
            status_reg <= STATUS_STREAMING_I2C;  
            if (i2c_que_for_send = '1') then
                i2c_data <= ram_doutb;
                NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_WAITFOR_DATA_INFLIGHT;
            else
                NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_WRITE_TO_I2C;
            end if;  
        when STREAM_DATA_OVER_I2C_WAITFOR_DATA_INFLIGHT =>  
            status_reg <= STATUS_STREAMING_I2C;
            if (i2c_que_for_send = '0') then
                -- Data is marked in flight, get the buffer ready to send the next byte
                NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_READ_FROM_RAM;
            else
                NEXT_STREAMER_STATE <= STREAM_DATA_OVER_I2C_WAITFOR_DATA_INFLIGHT;
            end if;        
        when OTHERS =>
            NEXT_STREAMER_STATE <= RESET_START;
    end case;
end process;

end Behavioral;
