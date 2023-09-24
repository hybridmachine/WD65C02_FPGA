----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/08/2023 04:00:45 PM
-- Design Name: 
-- Module Name: 6502_Interface - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WD6502_Interface is
    Port ( CLOCK        : in STD_LOGIC; -- Assume 100mhz clock
           RESET        : in STD_LOGIC; -- User input reset button
           SINGLESTEP   : in STD_LOGIC; -- When high, connect SYNC to RDY for single step operation
           -- 6502 Connected Pins
           ADDRESS      : in STD_LOGIC_VECTOR (15 downto 0);    -- Address bus
           BE           : out STD_LOGIC;                        -- Bus Enable
           DATA         : inout STD_LOGIC_VECTOR (7 downto 0);  -- Data bus
           IRQB         : in STD_LOGIC;                         -- Interrupt Request
           MLB          : inout STD_LOGIC;                      -- Memory Lock
           NMIB         : in STD_LOGIC;                         -- Non-Maskable Interrupt
           PHI1O        : in STD_LOGIC;                         -- Phase 1 out clock
           PHI2         : out STD_LOGIC;                        -- Phase 2 in clock (main clock)
           PHI2O        : in STD_LOGIC;                         -- Phase 2 out clock
           RDY          : out STD_LOGIC;                        -- Ready
           RESB         : out STD_LOGIC;                        -- Reset
           RWB          : in STD_LOGIC;                         -- Read/Write
           SOB          : in STD_LOGIC;                         -- Set Overflow
           SYNC         : in STD_LOGIC;                         -- Synchronize
           VPB          : in STD_LOGIC);                        -- Vector Pull
end WD6502_Interface;

architecture Behavioral of WD6502_Interface is

COMPONENT MemoryManager is
    Port ( BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           BUS_WRITE_DATA: in STD_LOGIC_VECTOR (7 downto 0);
           BUS_ADDRESS : in STD_LOGIC_VECTOR (15 downto 0);
           MEMORY_CLOCK : in STD_LOGIC; -- Run at 2x CPU, since reads take two cycles
           WRITE_FLAG : in STD_LOGIC -- When 1, data to address, read address and store on data line otherwise
           );
end COMPONENT;

constant FPGA_CLOCK_MHZ : integer := 100;

-- Assuming a 100mhz FPGA clock, we'll divide our counter by this amount.
-- Remember that we want 50% duty cycle so if we want a 1mhz clock, we divide by 50mhz to get half of our duty cycle
constant CPU_CLOCK_DIVIDER : integer := 2;   

-- From the WD65C02 spec 
-- When a positive edge (on RESB) is detected, there will be a reset sequence lasting seven clock cycles.
constant CPU_RESET_HOLDOFF_CLOCKTICKS : integer := 7; 

type PROCESSOR_STATE_T is ( RESET_START,
                    RESET_COMPLETE,
                    READY,
                    OPCODE_FETCH,
                    READ_DATA,
                    WRITE_DATA,
                    STANDBY);

signal PROCESSOR_STATE : PROCESSOR_STATE_T;

signal WD6502_CLOCK : std_logic;
begin

-- When SINGLESTEP is high, we are in single step mode, stop processor after opcode fetch
-- Otherwise RDY is always high.
RDY <= SYNC WHEN SINGLESTEP = '1' else '1';
-- Push the internal signal out to the CPU clock PIN
PHI2 <= WD6502_CLOCK;

wd6502_clockmachine : process (CLOCK, RESET)
variable FPGA_CLOCK_COUNTER_FOR_CPU : integer range 0 to FPGA_CLOCK_MHZ;
variable RESET_IN_PROGRESS : std_logic := '0';
begin
    
    if (RESET = '0' and RESET_IN_PROGRESS = '0') then -- Reset active low
        FPGA_CLOCK_COUNTER_FOR_CPU := 1;
        WD6502_CLOCK <= '0';
        RESET_IN_PROGRESS := '1';
    elsif (CLOCK'event and CLOCK = '1') then
        if (RESET = '1' and RESET_IN_PROGRESS = '1') then
            RESET_IN_PROGRESS := '0';
        end if;
        
        if (FPGA_CLOCK_COUNTER_FOR_CPU = FPGA_CLOCK_MHZ / CPU_CLOCK_DIVIDER) then
            FPGA_CLOCK_COUNTER_FOR_CPU := 1;
            WD6502_CLOCK <= not WD6502_CLOCK;
        else
            FPGA_CLOCK_COUNTER_FOR_CPU := FPGA_CLOCK_COUNTER_FOR_CPU + 1;
            WD6502_CLOCK <= WD6502_CLOCK; -- Is this needed?
        end if;
    end if;
end process wd6502_clockmachine;

wd6502_statemachine : process (WD6502_CLOCK, RESET)
variable reset_clock_count : natural := 0;
variable reset_in_progress : std_logic := '0';
begin
    if (WD6502_CLOCK'event and WD6502_CLOCK='1') then
        if (RESET = '0' and reset_in_progress = '0') then
            PROCESSOR_STATE <= RESET_START;
            reset_clock_count := 2;
            RESB <= '0';
            reset_in_progress := '1';
        else
            case PROCESSOR_STATE is
                when RESET_START =>
                    if (reset_clock_count = 0) then
                        PROCESSOR_STATE <= RESET_COMPLETE;
                    else
                        reset_clock_count := reset_clock_count - 1;
                    end if;
                when RESET_COMPLETE =>
                    RESB <= '1';
                    PROCESSOR_STATE <= READY;
                    reset_in_progress := '0';
                when READY =>
                    -- When SYNC goes high, CPU is reading an opcode
                
                when READ_DATA =>
                when WRITE_DATA =>
                when OPCODE_FETCH =>
                
                when STANDBY =>
                when others =>
            end case;
        end if;
    end if;
end process wd6502_statemachine;

end Behavioral;
