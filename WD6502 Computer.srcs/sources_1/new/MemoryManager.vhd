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
use work.MEMORY_MANAGER.ALL;

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
signal PIO_7SEG_ACTIVE: std_logic;

signal PIO_ELAPSED_TIMER_CONTROL_REG_SIG : STD_LOGIC_VECTOR (7 downto 0);
signal PIO_ELAPSED_TIMER_STATUS_REG_SIG : STD_LOGIC_VECTOR (7 downto 0);
signal PIO_ELAPSED_TIMER_TICKS_MS_SIG : STD_LOGIC_VECTOR (31 downto 0);
signal DATA_DIRECTION : READ_WRITE_MODE_TYPE;

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
    DISPLAY_ON => PIO_7SEG_ACTIVE,
    VALUE => PIO_7SEG_DISPLAY_VAL,
    SEGMENT_DRIVERS => PIO_7SEG_SEGMENTS,
    COMMON_DRIVERS => PIO_7SEG_COMMON
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

-- Propogate registers and update DATA_DIRECTION 
process(MEMORY_CLOCK)
BEGIN
    if (rising_edge(MEMORY_CLOCK)) then
        
        if (WRITE_FLAG = '1') then
            DATA_DIRECTION <= WRITE_TO_MEMORY;
        else
            DATA_DIRECTION <= READ_FROM_MEMORY;
        end if;
    end if;
END PROCESS;

process(MEMORY_CLOCK)
variable MEMORY_ADDRESS : unsigned(15 downto 0);
variable SHIFTED_ADDRESS : unsigned(15 downto 0);
begin    
    if (rising_edge(MEMORY_CLOCK)) then
        MEMORY_ADDRESS := unsigned(BUS_ADDRESS);
        
        if (MemoryRegion(BUS_ADDRESS) = BOOT_VECTOR_REGION) then
            ReadBootVector(BUS_READ_DATA, BUS_ADDRESS);
        elsif((MemoryRegion(BUS_ADDRESS) = ROM_REGION) and (DATA_DIRECTION = READ_FROM_MEMORY)) then
            ReadROM(BUS_READ_DATA, BUS_ADDRESS, rom_addra, rom_douta);
        elsif((MemoryRegion(BUS_ADDRESS) = RAM_REGION) and (DATA_DIRECTION = READ_FROM_MEMORY)) then
            ReadRAM(BUS_READ_DATA, BUS_ADDRESS, ram_addrb, ram_doutb);
        elsif((MemoryRegion(BUS_ADDRESS) = RAM_REGION) and (DATA_DIRECTION = WRITE_TO_MEMORY)) then
            WriteRAM(BUS_WRITE_DATA, BUS_ADDRESS, ram_addra, ram_dina);
        elsif((MemoryRegion(BUS_ADDRESS) = MEMORY_MAPPED_IO_REGION)) then
            if (DATA_DIRECTION = WRITE_TO_MEMORY) then
                if (PIO_LED_ADDR = BUS_ADDRESS) then
                    pio_led_data <= BUS_WRITE_DATA;
                elsif (PIO_7SEG_CONTROL = BUS_ADDRESS) then
                    if (BUS_WRITE_DATA /= x"00") then -- Any non zero value will activate the displays
                        PIO_7SEG_ACTIVE <= '1';
                    else
                        PIO_7SEG_ACTIVE <= '0';
                    end if;
                elsif (BUS_ADDRESS = PIO_7SEG_VAL_LOW) then
                    PIO_7SEG_DISPLAY_VAL(7 downto 0) <= BUS_WRITE_DATA;
                elsif (BUS_ADDRESS = PIO_7SEG_VAL_HIGH) then
                    PIO_7SEG_DISPLAY_VAL(15 downto 8) <= BUS_WRITE_DATA;
                -- Timer control and status
                elsif (BUS_ADDRESS = PIO_TIMER_CTL) then
                    -- Set the timer control flags
                    PIO_ELAPSED_TIMER_CONTROL_REG_SIG <= BUS_WRITE_DATA;
                end if;
            else
                -- Read from memory
                if (BUS_ADDRESS = PIO_TIMER_STATUS) then
                     BUS_READ_DATA <= PIO_ELAPSED_TIMER_STATUS_REG_SIG;
                elsif (BUS_ADDRESS = PIO_TIMER_VAL_MS_1) then
                    BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(7 downto 0);
                elsif (BUS_ADDRESS = PIO_TIMER_VAL_MS_2) then
                    BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(15 downto 8);
                elsif (BUS_ADDRESS = PIO_TIMER_VAL_MS_3) then
                    BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(23 downto 16);
                elsif (BUS_ADDRESS = PIO_TIMER_VAL_MS_4) then
                    BUS_READ_DATA <= PIO_ELAPSED_TIMER_TICKS_MS_SIG(31 downto 24);
                end if;
            end if;
        else
            -- Set error bit, somehow address out of range of all address blocks
        end if;
    end if;
end process;

end Behavioral;
