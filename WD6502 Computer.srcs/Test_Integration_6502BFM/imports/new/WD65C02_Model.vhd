----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 09/09/2023 10:34:41 AM
-- Design Name: 
-- Module Name: WD65C02_Model - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: WD65C02 bus functional model with timing delays based on timing diagram in 
-- http://www.westerndesigncenter.com/wdc/documentation/w65c02s.pdf
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
use STD.textio.all;
use ieee.std_logic_textio.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity WD65C02_Model is
    Port ( ADDRESS : out STD_LOGIC_VECTOR (15 downto 0);    -- Address bus
           BE : in STD_LOGIC;                               -- Bus Enable
           DATA : inout STD_LOGIC_VECTOR (7 downto 0);      -- Data bus
           IRQB : out STD_LOGIC;                            -- Interrupt Request
           MLB : inout STD_LOGIC;                           -- Memory Lock
           NMIB : out STD_LOGIC;                            -- Non-Maskable Interrupt
           PHI1O : out STD_LOGIC;                           -- Phase 1 out clock
           PHI2 : in STD_LOGIC;                             -- Phase 2 in clock (main clock)
           PHI2O : out STD_LOGIC;                           -- Phase 2 out clock
           RDY : in STD_LOGIC;                              -- Ready
           RESB : in STD_LOGIC;                             -- Reset
           RWB : out STD_LOGIC;                             -- Read/Write
           SOB : out STD_LOGIC;                             -- Set Overflow
           SYNC : out STD_LOGIC;                            -- Synchronize
           VPB : out STD_LOGIC);                            -- Vector Pull
end WD65C02_Model;

architecture Behavioral of WD65C02_Model is
constant CLOCK_CYCLES_RESET : natural := 7; -- Number of clock cycles to wait after reset before processor is ready

type PROCESSOR_STATE_T is ( RESET_START,   -- RESB has gone low
                            RESET_PENDING, -- We need two clock cycles with RESB held low 
                            RESET_COMPLETE, -- RESB is high after a low transition for 2 clock cycles and 7 clocks have passed since then
                            READ_BOOT_LOW,
                            READ_BOOT_HIGH,
                            EXECUTING,
                            EXECUTING_DELAY,
                            READY,
                            OPCODE_FETCH,
                            READ_DATA,
                            WRITE_DATA,
                            STANDBY);
 
type PROCESSOR_PINS_T is record
    BE      : std_logic;
    IRQB    : std_logic;
    MLB     : std_logic;
    NMIB    : std_logic;
    RDY     : std_logic;
    RWB     : std_logic;
    SOB     : std_logic;
    SYNC    : std_logic;
    VPB     : std_logic;
    ADDRESS : std_logic_vector(15 downto 0);
    DATA    : std_logic_vector(7 downto 0);
end record PROCESSOR_PINS_T;

signal processor_pins : PROCESSOR_PINS_T;

signal PROCESSOR_STATE : PROCESSOR_STATE_T;

file file_wd65c02_states : text;

begin

-- Concurrent process to push pin signals out to CPU signals
IRQB    <= processor_pins.IRQB;
MLB     <= processor_pins.MLB;
NMIB    <= processor_pins.NMIB;
PHI1O   <= not PHI2;
PHI2O   <= PHI2;
RWB     <= processor_pins.RWB;
SOB     <= processor_pins.SOB;
SYNC    <= processor_pins.SYNC;
VPB     <= processor_pins.VPB;
ADDRESS <= processor_pins.ADDRESS;
DATA    <= processor_pins.DATA when (processor_pins.RWB = '1') else (others => 'Z');

wd65c02_state_machine : process (RESB,PHI2)
variable clock_delay_count : natural := 0;
variable clock_delay_count_str : string (1 to 2) := "00";

variable open_status :FILE_OPEN_STATUS := status_error; -- File not yet open
variable line_state     : line;
variable TABSPACE : character;
variable processor_pins_var : PROCESSOR_PINS_T;
variable reset_in_process : std_logic := '0';
begin
   if (PHI2'event and PHI2 = '1') then
        if (RESB = '0' and reset_in_process /= '1') then
            PROCESSOR_STATE <= RESET_START;
            reset_in_process := '1';
        else
            case PROCESSOR_STATE is
                when RESET_START =>
                    clock_delay_count := 1; -- When we get to this part of the FSM , one clock has already passed
                    PROCESSOR_STATE <= RESET_PENDING;
                when RESET_PENDING =>
                    if (RESB = '1') then
                        clock_delay_count := 0;
                        reset_in_process := '0';
                        PROCESSOR_STATE <= EXECUTING; -- Reset wasn't held for 2 clocks, go back to executing
                    else
                        -- We'll set clock_delay_count to 0 on the complete state
                        PROCESSOR_STATE <= RESET_COMPLETE;
                    end if;
                when RESET_COMPLETE =>
                    clock_delay_count := 0;
                    reset_in_process := '0';
                    -- Close and re-open processor states (causes file to start back from the top)
                    if (open_status = open_ok) then
                        file_close(file_wd65c02_states);
                    end if;
                    file_open(open_status, file_wd65c02_states, "wd65c02_states.txt", READ_MODE);
                    PROCESSOR_STATE <= EXECUTING;
                when EXECUTING =>
                    -- File format is
                    -- CLK_DLY  STATUSFLAGS ADDRESS DATA
                    -- STATUSFLAGS maps to the record process status
                    -- CLK_DLY is how many clock cycles to delay until the step is processed
                    
                    if (open_status = open_ok) then
                        readline(file_wd65c02_states, line_state);
                        read(line_state, clock_delay_count_str);
                        
                        if (clock_delay_count_str /= "EN") then
                            read(line_state, TABSPACE);
                
                            read(line_state, processor_pins_var.BE);
                            read(line_state, processor_pins_var.IRQB);
                            read(line_state, processor_pins_var.MLB);
                            read(line_state, processor_pins_var.NMIB);
                            read(line_state, processor_pins_var.RDY);
                            read(line_state, processor_pins_var.RWB);
                            read(line_state, processor_pins_var.SOB);
                            read(line_state, processor_pins_var.SYNC);
                            read(line_state, processor_pins_var.VPB);
                            
                            read(line_state, TABSPACE);
                    
                            hread(line_state, processor_pins_var.ADDRESS);
                            
                            read(line_state, TABSPACE);
                            
                            hread(line_state, processor_pins_var.DATA);    
                            
                            clock_delay_count := natural'value(clock_delay_count_str);
                            if (clock_delay_count = 0) then
                                processor_pins <= processor_pins_var; -- Push to the signal which will propogate out to the interface    
                                PROCESSOR_STATE <= EXECUTING;      
                            else
                                PROCESSOR_STATE <= EXECUTING_DELAY;
                            end if;  
                            else -- End has reached, restart
                                if (open_status = open_ok) then
                                    file_close(file_wd65c02_states);
                                    open_status := status_error; -- TO mark it closed
                                end if;
                                PROCESSOR_STATE <= RESET_START;
                            end if;
                        end if;
                    when EXECUTING_DELAY =>                       -- This state emulates waiting a number of clock cycles before processing step (such as after RESET)
                    if (clock_delay_count = 0) then
                        processor_pins <= processor_pins_var; -- Push to the signal which will propogate out to the interface   
                        PROCESSOR_STATE <= EXECUTING;
                    else
                        clock_delay_count := clock_delay_count - 1;
                        PROCESSOR_STATE <= EXECUTING_DELAY;
                    end if;
                when others => 
                    PROCESSOR_STATE <= RESET_COMPLETE; -- Jump straight to complete and re-read state file
            end case;
        end if;
    end if; -- RESB
end process wd65c02_state_machine;
end Behavioral;
