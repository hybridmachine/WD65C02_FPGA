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

-- This modules manages the memory map of the computer. In this revision we have a very simple
-- map. 
--      $FFFF downto $EFFF is ROM, 1KB of ROM
--      $EFFE downto $0400 is RAM, 60KB of RAM (60,414)
--      $03FF downto $0200 is Memory mapped I/O, 511 bytes of I/O space
--      $01FF downto $0100 is processor reserved stack, 256 bytes of processor reserved stack space
--      $00FF downot $0001 is system reserved, unused for now.
--      $0000 is memory manager exception flags
--          $80 -> Write to illegal address exception. Attempt to write to ROM or status register or reserved memory area
--          $40 -> Read from illegal address exception (set only by the memmory mapped I/O subsystem)
-- This is a simple, nonconfigurable at runtime map. Longer term we'll probably want to mimic the Commodore 64 map with config bytes at $0000 and $0001
entity MemoryManager is
    Port ( BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0); -- We could do this with inout but harder to test bench so splitting
           BUS_WRITE_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           BUS_ADDRESS : in STD_LOGIC_VECTOR (15 downto 0);
           MEMORY_CLOCK : in STD_LOGIC; -- Run at 2x CPU, since reads take two cycles
           WRITE_FLAG : in STD_LOGIC; -- When 1, data to address, read address and store on data line otherwise
           PIO_LED_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0);
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0);
           RESET : in STD_LOGIC
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
signal PIO_7SEG_SEGMENTS_SIG:std_logic_vector(7 downto 0);
signal PIO_7SEG_COMMON_SIG:std_logic_vector(3 downto 0);

COMPONENT RAM is
    GENERIC(
    ADDRESS_WIDTH: natural := 16;
    DATA_WIDTH: natural := 8;
    RAM_DEPTH: natural := 2**15
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

COMPONENT Peripheral_IO_LED is
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

begin

MAIN_RAM: RAM port map (
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

MAIN_ROM: ROM port map (
    addra => rom_addra,
    douta => rom_douta,
    clka => rom_clka
);

PIO_LED: peripheral_io_led port map (
    data => pio_led_data,
    clock => MEMORY_CLOCK,
    led_ctl => PIO_LED_OUT,
    reset => RESET
);

PIO_7SEGMENT: PIO_7SEG_X_4 generic map (
    SELECT_ACTIVE => '0',
    CLOCK_TICKS_PER_DIGIT => 200000
)
port map (
    CLOCK => MEMORY_CLOCK,
    DISPLAY_ON => PIO_7SEG_ACTIVE,
    VALUE => PIO_7SEG_DISPLAY_VAL,
    SEGMENT_DRIVERS => PIO_7SEG_SEGMENTS_SIG,
    COMMON_DRIVERS => PIO_7SEG_COMMON_SIG
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
    if (MEMORY_CLOCK'event and MEMORY_CLOCK = '1') then
        PIO_7SEG_SEGMENTS <= PIO_7SEG_SEGMENTS_SIG;
        PIO_7SEG_COMMON <= PIO_7SEG_COMMON_SIG;
    end if;
END PROCESS;

process(MEMORY_CLOCK)
variable MEMORY_ADDRESS : unsigned(15 downto 0);
variable SHIFTED_ADDRESS : unsigned(15 downto 0);

begin    
    if (MEMORY_CLOCK'event and MEMORY_CLOCK = '1') then
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
                if (unsigned(PERIPHERAL_IO_LED_ADDR) = MEMORY_ADDRESS) then
                    -- Send data value to Peripheral_IO_LED
                    if (WRITE_FLAG = '1') then
                        pio_led_data <= BUS_WRITE_DATA;
                    end if;
                elsif (unsigned(PERIPHERAL_IO_7SEG_ACTIVE) = MEMORY_ADDRESS AND WRITE_FLAG = '1') then
                    if (BUS_WRITE_DATA /= x"00") then -- Any non zero value will activate the displays
                        PIO_7SEG_ACTIVE <= '1';
                    else
                        PIO_7SEG_ACTIVE <= '0';
                    end if;
                elsif (MEMORY_ADDRESS = unsigned(PERIPHERAL_IO_7SEG_VAL) AND WRITE_FLAG = '1') then
                    PIO_7SEG_DISPLAY_VAL(7 downto 0) <= BUS_WRITE_DATA;
                elsif (MEMORY_ADDRESS = (unsigned(PERIPHERAL_IO_7SEG_VAL) + 1) AND WRITE_FLAG = '1') then
                    PIO_7SEG_DISPLAY_VAL(15 downto 8) <= BUS_WRITE_DATA;
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
end process;

end Behavioral;
