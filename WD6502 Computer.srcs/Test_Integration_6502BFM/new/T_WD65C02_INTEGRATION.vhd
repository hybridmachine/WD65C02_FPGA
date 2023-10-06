----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 09/23/2023 11:03:23 AM
-- Design Name: 
-- Module Name: T_WD65C02_INTEGRATION - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Top level test module that brings together the WD65C02 bus functional model and the 
-- WD6502_interface which underneath it has the memory manager which then maps to the RAM, ROM, and 
-- peripheral IO. This is the full up system integration test.
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity T_WD65C02_INTEGRATION is
--  Port ( );
end T_WD65C02_INTEGRATION;

architecture Behavioral of T_WD65C02_INTEGRATION is

COMPONENT WD6502_Interface is
    Port ( CLOCK        : in STD_LOGIC; -- Assume 100mhz clock
           RESET        : in STD_LOGIC; -- User input reset button
           SINGLESTEP   : in STD_LOGIC; -- When high, connect SYNC to RDY for single step operation
           -- 6502 Connected Pins
           ADDRESS      : in ADDRESS_T;    -- Address bus
           BE           : out BE_T;                        -- Bus Enable
           DATA         : inout DATA_T;  -- Data bus
           IRQB         : in IRQB_T;                         -- Interrupt Request
           MLB          : inout MLB_T;                      -- Memory Lock
           NMIB         : in NMIB_T;                         -- Non-Maskable Interrupt
           PHI1O        : in PHI1O_T;                         -- Phase 1 out clock
           PHI2         : out PHI2_T;                        -- Phase 2 in clock (main clock)
           PHI2O        : in PHI2O_T;                         -- Phase 2 out clock
           RDY          : out RDY_T;                        -- Ready
           RESB         : out RESB_T;                        -- Reset
           RWB          : in RWB_T;                         -- Read/Write
           SOB          : in SOB_T;                         -- Set Overflow
           SYNC         : in SYNC_T;                         -- Synchronize
           VPB          : in VPB_T);                        -- Vector Pull
end COMPONENT;   

COMPONENT WD65C02_Model is
    Port ( ADDRESS : out ADDRESS_T;    -- Address bus
           BE : in BE_T;                               -- Bus Enable
           DATA : inout DATA_T;      -- Data bus
           IRQB : out IRQB_T;                            -- Interrupt Request
           MLB : inout MLB_T;                           -- Memory Lock
           NMIB : out NMIB_T;                            -- Non-Maskable Interrupt
           PHI1O : out PHI1O_T;                           -- Phase 1 out clock
           PHI2 : in PHI2_T;                             -- Phase 2 in clock (main clock)
           PHI2O : out PHI2O_T;                           -- Phase 2 out clock
           RDY : in RDY_T;                              -- Ready
           RESB : in RESB_T;                             -- Reset
           RWB : out RWB_T;                             -- Read/Write
           SOB : out SOB_T;                             -- Set Overflow
           SYNC : out SYNC_T;                            -- Synchronize
           VPB : out VPB_T);                            -- Vector Pull
end COMPONENT;

signal T_CLOCK        :STD_LOGIC := '0'; -- Assume 100mhz clock
signal T_RESET        :STD_LOGIC; -- User input reset button
signal T_SINGLESTEP   :STD_LOGIC; -- When high, connect SYNC to RDY for single step operation

signal T_ADDRESS                :ADDRESS_T;    -- Address bus
signal T_BE                     :BE_T;                        -- Bus Enable
signal T_DATA_MODEL             :DATA_T := (others => 'Z');  -- Data bus
signal T_DATA_INTERFACE         :DATA_T := (others => 'Z');  -- Data bus
signal T_IRQB                   :IRQB_T;                         -- Interrupt Request
signal T_MLB                    :MLB_T;                      -- Memory Lock
signal T_NMIB                   :NMIB_T;                         -- Non-Maskable Interrupt
signal T_PHI1O                  :PHI1O_T;                         -- Phase 1clock
signal T_PHI2                   :PHI2_T;                        -- Phase 2clock (main clock)
signal T_PHI2O                  :PHI2O_T;                         -- Phase 2clock
signal T_RDY                    :RDY_T;                        -- Ready
signal T_RESB                   :RESB_T;                        -- Reset
signal T_RWB                    :RWB_T;                         -- Read/Write
signal T_SOB                    :SOB_T;                         -- Set Overflow
signal T_SYNC                   :SYNC_T;                         -- Synchronize
signal T_VPB                    :VPB_T;                         -- Vector Pull

constant CLOCK_PERIOD : time := 100ns; -- 100mhz FPGA clock

begin

-- Clock concurrent process
T_CLOCK <= not T_CLOCK after (CLOCK_PERIOD / 2);

BFM : WD65C02_Model port map (
    ADDRESS => T_ADDRESS,
    BE => T_BE,
    DATA => T_DATA_MODEL,
    IRQB => T_IRQB,
    MLB => T_MLB,
    NMIB => T_NMIB,
    PHI1O => T_PHI1O,
    PHI2 => T_PHI2,
    PHI2O => T_PHI2O,
    RDY => T_RDY,
    RESB => T_RESB,
    RWB => T_RWB,
    SOB => T_SOB,
    SYNC => T_SYNC,
    VPB => T_VPB
);

DUT : WD6502_Interface port map (
    CLOCK => T_CLOCK,
    RESET => T_RESET,
    SINGLESTEP => T_SINGLESTEP,
    ADDRESS => T_ADDRESS,
    BE => T_BE,
    DATA => T_DATA_INTERFACE,
    IRQB => T_IRQB,
    MLB => T_MLB,
    NMIB => T_NMIB,
    PHI1O => T_PHI1O,
    PHI2 => T_PHI2,
    PHI2O => T_PHI2O,
    RDY => T_RDY,
    RESB => T_RESB,
    RWB => T_RWB,
    SOB => T_SOB,
    SYNC => T_SYNC,
    VPB => T_VPB
);
process
begin
    T_RESET <= '0';
    wait until T_PHI2 = '1';
    wait until T_PHI2 = '1';
    wait until T_PHI2 = '1';
    T_RESET <= '1';
    wait until T_ADDRESS = x"FFFC";
    wait for 290ns; 
    assert (T_DATA_INTERFACE = T_DATA_MODEL) report "ROM data does not match expectd in model file" severity failure;
    wait until T_ADDRESS = x"FFFD";
    wait for 290ns; 
    assert (T_DATA_INTERFACE = T_DATA_MODEL) report "ROM data does not match expectd in model file" severity failure;
    
    assert (false) report "Test completed successfully" severity failure;
end process;
end Behavioral;
