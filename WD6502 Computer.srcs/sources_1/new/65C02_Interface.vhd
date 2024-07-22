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
use work.W65C02_DEFINITIONS.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

--! \author Brian Tabone
--! @brief Top level module which interfaces directly with the 65C02 CPU. 
--! @details All input/output signals route through here. This is connected via block diagram to external pins
--! See Baysis.xdc for physical pin mapping
--!
entity WDC65C02_Interface is
    Port ( CLOCK        : in STD_LOGIC; --! Assume 100mhz clock
           RESET        : in STD_LOGIC; --! User input reset button
           SINGLESTEP   : in STD_LOGIC; --! When high, connect SYNC to RDY for single step operation
           -- 6502 Connected Pins
           ADDRESS      : in std_logic_vector(15 downto 0);                     --! Address bus
           --BE           : out std_logic;                         -- Bus Enable
           DATA         : inout std_logic_vector(7 downto 0);                     --! Data bus
           DATA_TO_CPU_TAP : out std_logic_vector(7 downto 0);                    --! Signal tap to see what's going out to CPU
           DATA_FROM_CPU_TAP : out std_logic_vector(7 downto 0);                  --! Signal tap to see what's coming in from CPU
           --signal BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           --signal BUS_WRITE_DATA : in STD_LOGIC_VECTOR (7 downto 0);
           IRQB         : out std_logic;                        --! Interrupt Request
           --MLB          : inout std_logic;                      -- Memory Lock
           NMIB         : out std_logic;                        --! Non-Maskable Interrupt
           --PHI1O        : in std_logic;                       -- Phase 1 out clock
           PHI2         : out std_logic;                       --! Phase 2 in clock (main clock)
           --PHI2O        : in std_logic;                       -- Phase 2 out clock
           RDY          : out std_logic;                        --! Ready
           RESB         : out std_logic;                       --! Reset
           RWB          : in std_logic;                         --! Read/Write
           --SOB          : out std_logic;                         -- Set Overflow
           SYNC         : in std_logic;                        --! Synchronize
           --VPB          : in std_logic;                         -- Vector Pull
           -- IO pins
           PIO_LED_OUT  : out STD_LOGIC_VECTOR(7 downto 0); --! PIO Led pins    
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0); --! 7 Segment common drivers
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0)); --! 7 Segment segment drivers                    
end WDC65C02_Interface;

architecture Behavioral of WDC65C02_Interface is

COMPONENT MemoryManager is
    Port ( BUS_READ_DATA : out STD_LOGIC_VECTOR (7 downto 0);
           BUS_WRITE_DATA: in STD_LOGIC_VECTOR (7 downto 0);
           BUS_ADDRESS : in STD_LOGIC_VECTOR (15 downto 0);
           MEMORY_CLOCK : in STD_LOGIC; -- Run at 2x CPU, since reads take two cycles
           WRITE_FLAG : in STD_LOGIC; -- When 1, data to address, read address and store on data line otherwise
           PIO_LED_OUT : out STD_LOGIC_VECTOR (7 downto 0);
           PIO_7SEG_COMMON : out STD_LOGIC_VECTOR(3 downto 0);
           PIO_7SEG_SEGMENTS : out STD_LOGIC_VECTOR(7 downto 0);
           RESET : in STD_LOGIC
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

signal wdc65c02_CLOCK : std_logic;

signal DATA_FROM_6502 :  STD_LOGIC_VECTOR (7 downto 0);
signal DATA_TO_6502:  STD_LOGIC_VECTOR (7 downto 0);
signal BUS_ADDRESS :  STD_LOGIC_VECTOR (15 downto 0);
signal MEMORY_CLOCK :  STD_LOGIC; -- Run at 2x CPU, since reads take two cycles
signal WRITE_FLAG :  STD_LOGIC := '0';

constant FPGA_CLOCK_PERIOD_NS : natural := 10;
constant WRITE_RAM_DELAY_PERIOD : natural := tMDS-FPGA_CLOCK_PERIOD_NS;
begin -- Begin architecture definition

--SOB <= '1'; -- Not really used, spec says to keep it high
IRQB <= '1'; -- Not using interrupts just yet, will connect this later
--BE <= '1'; -- For now bus is always on
NMIB <= '1'; -- Not currently using, keep high for now.

MemoryManagement : MemoryManager port map (
    BUS_READ_DATA => DATA_FROM_6502,
    BUS_WRITE_DATA => DATA_TO_6502,
    BUS_ADDRESS => BUS_ADDRESS,
    MEMORY_CLOCK => MEMORY_CLOCK,
    WRITE_FLAG => WRITE_FLAG,
    PIO_LED_OUT => PIO_LED_OUT,
    PIO_7SEG_COMMON => PIO_7SEG_COMMON,
    PIO_7SEG_SEGMENTS => PIO_7SEG_SEGMENTS,
    RESET => RESET
);

GEN1: for i in 0 to 7 generate     
     IOBx : IOBUF
         generic map(
             DRIVE => 12,
             IOSTANDARD => "DEFAULT",
             SLEW => "SLOW")
             port map (
             O => DATA_TO_6502(i),       	-- Buffer output going out to 65C02 (RAM/ROM reads)
             IO => DATA(i),     	-- Data inout port (connect directly to top-level port)
             I => DATA_FROM_6502(i),     	-- Buffer input from 65C02 (writes to our FPGA hosted RAM)
             T => WRITE_FLAG          	-- 3-state enable input, high=input, low=output
         );  


end generate GEN1;

-- End of IOBUF_inst instantiation

---- Concurrent signal propogation
--WRITE_FLAG <= not RWB;
--MEMORY_CLOCK <= CLOCK; -- If we needed to pace memory differently from the raw clock we can 
--                       -- For now just pulse FPGA clock straight to memory clock

--DATA <= BUS_READ_DATA when RWB = PROCESSOR_READING_FROM_MEMORY;
--BUS_WRITE_DATA <= DATA when RWB = PROCESSOR_WRITING_TO_MEMORY;
--BUS_ADDRESS <= ADDRESS;
                       
---- When SINGLESTEP is high, we are in single step mode, stop processor after opcode fetch
---- Otherwise RDY is always high.
RDY <= SYNC WHEN SINGLESTEP = '1' else '1';
---- Push the internal signal out to the CPU clock PIN
PHI2 <= wdc65c02_CLOCK;
MEMORY_CLOCK <= CLOCK; -- If we needed to pace memory differently from the raw clock we can 
                       -- For now just pulse FPGA clock straight to memory clock

DATA_TO_CPU_TAP <= DATA_TO_6502;
DATA_FROM_CPU_TAP <= DATA_FROM_6502;

wdc65c02_clockmachine : process (CLOCK)
variable FPGA_CLOCK_COUNTER_FOR_CPU : integer range 0 to FPGA_CLOCK_MHZ;
variable RESET_IN_PROGRESS : std_logic := '0';
variable WRITE_RAM_DELAY : natural range 0 to 1000 := tMDS-FPGA_CLOCK_PERIOD_NS; -- When this is counted down to 0, we set the write signal for hold period.

begin 
    if (rising_edge(CLOCK)) then
        if (RESET = CPU_RESET and RESET_IN_PROGRESS = '0') then -- Reset active low
            FPGA_CLOCK_COUNTER_FOR_CPU := 1;
            wdc65c02_CLOCK <= '0';
            RESET_IN_PROGRESS := '1';      
        else
            WRITE_FLAG <= '0';
            
            if (PROCESSOR_STATE = WRITE_DATA) then
                if (WRITE_RAM_DELAY > 0) then
                    WRITE_RAM_DELAY := WRITE_RAM_DELAY - FPGA_CLOCK_PERIOD_NS; -- 
                else
                    WRITE_FLAG <= '1'; -- Address should already be setup, set this as write to send the data to ram
                end if;
            end if;
            
            if (wdc65c02_CLOCK = '0') then
                -- Reset for next write phase
                WRITE_RAM_DELAY := WRITE_RAM_DELAY_PERIOD;
            end if;
            
            BUS_ADDRESS <= ADDRESS;
            if (RESET = CPU_RUNNING and RESET_IN_PROGRESS = '1') then
                RESET_IN_PROGRESS := '0';
            end if;
            
            if (FPGA_CLOCK_COUNTER_FOR_CPU = FPGA_CLOCK_MHZ / CPU_CLOCK_DIVIDER) then
                FPGA_CLOCK_COUNTER_FOR_CPU := 1;
                wdc65c02_CLOCK <= not wdc65c02_CLOCK;
            else
                FPGA_CLOCK_COUNTER_FOR_CPU := FPGA_CLOCK_COUNTER_FOR_CPU + 1;
                wdc65c02_CLOCK <= wdc65c02_CLOCK; -- Is this needed?
            end if;
        end if;
    end if;
end process wdc65c02_clockmachine;

wdc65c02_statemachine : process (wdc65c02_CLOCK)
variable reset_clock_count : natural := 0;
variable reset_in_progress : std_logic := '0';
begin
    if (rising_edge(wdc65c02_CLOCK)) then                           
        -- When SINGLESTEP is high, we are in single step mode, stop processor after opcode fetch
        -- Otherwise RDY is always high.
        -- Lets do this concurrently instead, TODO remove once confirmed
--        if (SINGLESTEP = '1') then
--            RDY <= SYNC;
--        else
--            RDY <= '1';
--        end if;
        -- Push the internal signal out to the CPU clock PIN

        if (RESET = CPU_RESET and reset_in_progress = '0') then
            PROCESSOR_STATE <= RESET_START;
            reset_clock_count := RESET_MIN_CLOCKS;
            RESB <= CPU_RESET;
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
                    RESB <= CPU_RUNNING;
                    PROCESSOR_STATE <= READY;
                    reset_in_progress := '0';
                when READY =>
                    -- RDY pin is managed by concurrent process 
                    -- and is '1' unless single step is enabled
                    if (SYNC = SYNC_READING_OPCODE) then
                        PROCESSOR_STATE <= OPCODE_FETCH;
                    elsif (RWB = '0') then
                        PROCESSOR_STATE <= WRITE_DATA;
                    else
                        PROCESSOR_STATE <= READY;
                    end if;
                    
                when READ_DATA =>
                when WRITE_DATA =>
                when OPCODE_FETCH =>
                
                    IF (SYNC = SYNC_READING_OPCODE) then
                        PROCESSOR_STATE <= OPCODE_FETCH;
                    ELSE
                        PROCESSOR_STATE <= READY;
                    END IF;
                when others =>
                    PROCESSOR_STATE <= RESET_START;
            end case;
        end if;
    end if;
end process wdc65c02_statemachine;

end Behavioral;
