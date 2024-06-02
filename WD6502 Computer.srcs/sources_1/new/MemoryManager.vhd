----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/08/2023 04:00:45 PM
-- Design Name: 
-- Module Name: MemoryManager - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.W65C02_DEFINITIONS.ALL;
use work.MEMORY_MAP.ALL;

--! \author Brian Tabone
--! @brief Manages the memory map of the computer. 
--! @details Implements the memory map as specified in PKG_65C02. Also manages the boot vector
--! Note boot vector and start address in ROM assembly must match
entity MemoryManager is
    Port ( BUS_READ_DATA : out DATA_65C02_T; --! Read data
           BUS_WRITE_DATA : in DATA_65C02_T; --! Data to be written
           BUS_ADDRESS : in ADDRESS_65C02_T; --! Read/Write address
           MEMORY_CLOCK : in STD_LOGIC; --! Memory clock, typically full FPGA clock speed
           WRITE_FLAG : in STD_LOGIC; --! When 1, write data to address, otherwise read address and output on data line
           PIO_LED_OUT : out STD_LOGIC_VECTOR (7 downto 0); --! 8 bit LED out, mapped to physical LEDs at interface
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0); --! Common drivers for seven segment displays
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0); --! Segment drivers for selected seven segment display
           RESET : in STD_LOGIC --! Reset 
           );
end MemoryManager;

architecture Behavioral of MemoryManager is

constant DATA_WIDTH: natural := 8;
constant ADDRESS_WIDTH: natural := 16;


-- RAM signals
signal ram_addra: std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
signal ram_addrb: std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
signal ram_clka: std_logic;
signal ram_clkb: std_logic;
signal ram_dina: std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
signal ram_dinb: std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
signal ram_douta: std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
signal ram_doutb: std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
signal ram_wea: std_logic;
signal ram_web: std_logic;
signal ram_ena: std_logic;
signal ram_enb: std_logic;

signal rom_addra: std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
signal rom_douta: std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
signal rom_clka: std_logic;
	
signal pio_led_data: std_logic_vector(7 downto 0);

signal PIO_7SEG_DISPLAY_VAL :std_logic_vector(15 downto 0);
signal PIO_7SEG_ACTIVE_SIG: std_logic;
signal PIO_7SEG_SEGMENTS_SIG:std_logic_vector(7 downto 0);
signal PIO_7SEG_COMMON_SIG:std_logic_vector(3 downto 0);

signal PIO_ELAPSED_TIMER_CONTROL_REG_SIG : STD_LOGIC_VECTOR (7 downto 0);
signal PIO_ELAPSED_TIMER_STATUS_REG_SIG : STD_LOGIC_VECTOR (7 downto 0);
signal PIO_ELAPSED_TIMER_TICKS_MS_SIG : STD_LOGIC_VECTOR (31 downto 0);

signal DATA_TRANSFER_READY : boolean := false;

constant WRITE_MODE : std_logic := '1';
constant READ_MODE : std_logic := '0';
constant DELAY_WRITE_BY_CLOCK_CYCLES : natural := 20;

COMPONENT RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**16
  );
    PORT (
	addra: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	addrb: IN std_logic_VECTOR((ADDRESS_WIDTH - 1) downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dina: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	dinb: IN std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	douta: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	doutb: OUT std_logic_VECTOR((DATA_WIDTH - 1) downto 0);
	wea: IN std_logic;
	web: IN std_logic;
	ena: IN std_logic;
	enb: IN std_logic
  );
end COMPONENT;

COMPONENT ROM is
    PORT (
	addra: IN std_logic_VECTOR(15 downto 0);
	clka: IN std_logic;
	douta: OUT std_logic_VECTOR(7 downto 0)
  );
end COMPONENT;

COMPONENT PIO_LED is
    Port ( DATA : in STD_LOGIC_VECTOR (7 downto 0);
           LED_CTL : out STD_LOGIC_VECTOR (7 downto 0);
           CLOCK : in STD_LOGIC;
           RESET : in STD_LOGIC);
end COMPONENT;

COMPONENT PIO_7SEG_X_4 is
    GENERIC(
        -- On some boards, namely baysis3, the digit selector is actually low instead of high
        -- most boards are high so 1 is default, set to 0 for boards like baysis 3
        SELECT_ACTIVE : STD_LOGIC := '1';
        CLOCK_TICKS_PER_DIGIT : natural := 1000000; -- at 100mhz, this will give us 10ms per digit
        COMMON_ANODE : STD_LOGIC := '1' -- When 1, true otherwise we are in common cathode mode
    );
    Port ( CLOCK : in STD_LOGIC; -- For now we'll run this at FPGA clock speed of 100mhz
           DISPLAY_ON : STD_LOGIC; -- 0 for LEDs off, 1 for display value on input
           VALUE : in STD_LOGIC_VECTOR (15 downto 0); -- 4 digits of 0-F hex. Note if using BCD , caller should limit 0-9, display doesn't truncate BCD illegal bits
           SEGMENT_DRIVERS : out STD_LOGIC_VECTOR (7 downto 0);
           COMMON_DRIVERS : out STD_LOGIC_VECTOR(3 downto 0)
           );
            
end COMPONENT;

COMPONENT PIO_ELAPSED_TIMER is
    Port ( CLOCK : in STD_LOGIC;
           CONTROL_REG : in STD_LOGIC_VECTOR (7 downto 0);
           STATUS_REG : out STD_LOGIC_VECTOR (7 downto 0);
           TICKS_MS : out STD_LOGIC_VECTOR (31 downto 0));
end COMPONENT;

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

ROM_DEVICE: ROM port map (
    addra => rom_addra,
    douta => rom_douta,
    clka => rom_clka
);

PIO_LED_DEVICE: PIO_LED port map (
    data => pio_led_data,
    clock => MEMORY_CLOCK,
    led_ctl => PIO_LED_OUT,
    reset => RESET
);

PIO_7SEG_X_4_DEVICE: PIO_7SEG_X_4 generic map (
    SELECT_ACTIVE => '0',
    CLOCK_TICKS_PER_DIGIT => 200000
)
port map (
    CLOCK => MEMORY_CLOCK,
    DISPLAY_ON => PIO_7SEG_ACTIVE_SIG,
    VALUE => PIO_7SEG_DISPLAY_VAL,
    SEGMENT_DRIVERS => PIO_7SEG_SEGMENTS_SIG,
    COMMON_DRIVERS => PIO_7SEG_COMMON_SIG
    );

PIO_ELAPSED_TIMER_DEVICE: PIO_ELAPSED_TIMER port map (
    CLOCK => MEMORY_CLOCK,
    CONTROL_REG => PIO_ELAPSED_TIMER_CONTROL_REG_SIG,
    STATUS_REG => PIO_ELAPSED_TIMER_STATUS_REG_SIG,
    TICKS_MS => PIO_ELAPSED_TIMER_TICKS_MS_SIG
);
 
-- Concurrent processes to distribute clock signals to RAM and ROM
rom_clka <= MEMORY_CLOCK;
ram_clka <= MEMORY_CLOCK;
ram_clkb <= MEMORY_CLOCK;

-- Always write A , read B
ram_wea <= '1'; 
ram_web <= '0';

ram_ena <= '1';
ram_enb <= '1';

-- Propogate the 7 SEGMENT signals 
process(MEMORY_CLOCK)
BEGIN
    if (rising_edge(MEMORY_CLOCK)) then
        PIO_7SEG_SEGMENTS <= PIO_7SEG_SEGMENTS_SIG;
        PIO_7SEG_COMMON <= PIO_7SEG_COMMON_SIG;
    end if;
END PROCESS;

-- Delay writes to memory by 10 clocks to give the processor data and address bus
-- time to stabilize
process(MEMORY_CLOCK,WRITE_FLAG)
variable TICKS_SINCE_CHANGE : natural;
variable PREVIOUS_WRITE_FLAG_STATE : STD_LOGIC := READ_MODE;
begin   
    if (rising_edge(MEMORY_CLOCK)) then
        if (WRITE_FLAG /= PREVIOUS_WRITE_FLAG_STATE) then
            PREVIOUS_WRITE_FLAG_STATE := WRITE_FLAG;
            if (WRITE_FLAG = WRITE_MODE) then
                TICKS_SINCE_CHANGE := 0;
                DATA_TRANSFER_READY <= false;
            else
                DATA_TRANSFER_READY <= true;
            end if;
        end if;
        
        if (TICKS_SINCE_CHANGE <= DELAY_WRITE_BY_CLOCK_CYCLES)
        then
            TICKS_SINCE_CHANGE := TICKS_SINCE_CHANGE + 1;
        else
            DATA_TRANSFER_READY <= true;
        end if;
    end if;
end process;

process(MEMORY_CLOCK,BUS_ADDRESS,BUS_WRITE_DATA,DATA_TRANSFER_READY,WRITE_FLAG)
variable MEMORY_ADDRESS : unsigned(15 downto 0);
variable SHIFTED_ADDRESS : unsigned(15 downto 0);

begin
    if (rising_edge(MEMORY_CLOCK)) then
        if (DATA_TRANSFER_READY = true) then
            MEMORY_ADDRESS := unsigned(BUS_ADDRESS);
            
            if (unsigned(BOOT_VEC_ADDRESS_LOW) = MEMORY_ADDRESS) then
                BUS_READ_DATA <= BOOT_VEC(7 downto 0);
            elsif (unsigned(BOOT_VEC_ADDRESS_HIGH) = MEMORY_ADDRESS) then
                BUS_READ_DATA <= BOOT_VEC(15 downto 8);
            -- Read from ROM
            elsif (unsigned(ROM_BASE) <= MEMORY_ADDRESS and MEMORY_ADDRESS <= unsigned(ROM_END)) then
                if (WRITE_FLAG = '0') then
                    SHIFTED_ADDRESS := MEMORY_ADDRESS - unsigned(ROM_BASE);
                    rom_addra <= std_logic_vector(SHIFTED_ADDRESS);
                    
                    -- Won't be valid until next clock cycle. For now we run the memory faster than the CPU to make sure data is ready ahead of processor read
                    BUS_READ_DATA <= rom_douta; 
                else
                    -- Set the error flag and BUS_DATA to 0
                    BUS_READ_DATA <= "00000000";
                end if;
            -- Read/Write from/to RAM
            elsif(unsigned(RAM_BASE) <= MEMORY_ADDRESS and MEMORY_ADDRESS <= unsigned(RAM_END)) then
                if(unsigned(MEM_MAPPED_IO_BASE) <= MEMORY_ADDRESS and MEMORY_ADDRESS <= unsigned(MEM_MAPPED_IO_END)) then
                    if (unsigned(PIO_LED_ADDR) = MEMORY_ADDRESS) then
                        -- Send data value to PIO_LED
                        if (WRITE_FLAG = '1') then
                            pio_led_data <= BUS_WRITE_DATA;
                        end if;
                    elsif (unsigned(PIO_7SEG_ACTIVE) = MEMORY_ADDRESS AND WRITE_FLAG = '1') then
                        if (BUS_WRITE_DATA /= x"00") then -- Any non zero value will activate the displays
                            PIO_7SEG_ACTIVE_SIG <= '1';
                        else
                            PIO_7SEG_ACTIVE_SIG <= '0';
                        end if;
                    elsif (MEMORY_ADDRESS = unsigned(PIO_7SEG_VAL) AND WRITE_FLAG = '1') then
                        PIO_7SEG_DISPLAY_VAL(7 downto 0) <= BUS_WRITE_DATA;
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_7SEG_VAL) + 1) AND WRITE_FLAG = '1') then
                        PIO_7SEG_DISPLAY_VAL(15 downto 8) <= BUS_WRITE_DATA;
                    -- Timer control and status
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_CTL)) AND WRITE_FLAG = '1') then
                        -- Set the timer control flags
                        PIO_ELAPSED_TIMER_CONTROL_REG_SIG <= BUS_WRITE_DATA;
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_STATUS)) AND WRITE_FLAG = '0') then
                        -- Read the timer status
                        BUS_READ_DATA <= PIO_ELAPSED_TIMER_STATUS_REG_SIG;
                    -- Read blocks for timer value
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_VAL_MS)) AND WRITE_FLAG = '0') then
                        -- Read the timer status
                        BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(7 downto 0);
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_VAL_MS)+1) AND WRITE_FLAG = '0') then
                        -- Read the timer status
                        BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(15 downto 8);
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_VAL_MS)+2) AND WRITE_FLAG = '0') then
                        -- Read the timer status
                        BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(23 downto 16);
                    elsif (MEMORY_ADDRESS = (unsigned(PIO_TIMER_VAL_MS)+3) AND WRITE_FLAG = '0') then
                        -- Read the timer status
                        BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(31 downto 24);
                    end if;
                else
                    SHIFTED_ADDRESS := MEMORY_ADDRESS - unsigned(RAM_BASE);
                    -- Write on port A, read on port B
                    if (WRITE_FLAG = '1') then
                        ram_addra <= std_logic_vector(SHIFTED_ADDRESS);
                        ram_dina <= BUS_WRITE_DATA; 
                    else
                        -- Won't be valid until next clock cycle. For now we run the memory faster than the CPU to make sure data is ready ahead of processor read
                        ram_addrb <= std_logic_vector(SHIFTED_ADDRESS);
                        BUS_READ_DATA <= ram_doutb;
                    end if;
                end if;
            else
                -- Set error bit, somehow address out of range of all address blocks
            end if;
        end if;
    end if;
end process;

end Behavioral;
