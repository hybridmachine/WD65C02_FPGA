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
end COMPONENT;   

COMPONENT WD65C02_Model is
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
end COMPONENT;

signal T_CLOCK        :STD_LOGIC := '0'; -- Assume 100mhz clock
signal T_RESET        :STD_LOGIC; -- User input reset button
signal T_SINGLESTEP   :STD_LOGIC; -- When high, connect SYNC to RDY for single step operation

signal T_ADDRESS      :STD_LOGIC_VECTOR (15 downto 0);    -- Address bus
signal T_BE           :STD_LOGIC;                        -- Bus Enable
signal T_DATA_MODEL         :STD_LOGIC_VECTOR (7 downto 0) := (others => 'Z');  -- Data bus
signal T_DATA_INTERFACE         :STD_LOGIC_VECTOR (7 downto 0) := (others => 'Z');  -- Data bus
signal T_IRQB         :STD_LOGIC;                         -- Interrupt Request
signal T_MLB          :STD_LOGIC;                      -- Memory Lock
signal T_NMIB         :STD_LOGIC;                         -- Non-Maskable Interrupt
signal T_PHI1O        :STD_LOGIC;                         -- Phase 1clock
signal T_PHI2         :STD_LOGIC;                        -- Phase 2clock (main clock)
signal T_PHI2O        :STD_LOGIC;                         -- Phase 2clock
signal T_RDY          :STD_LOGIC;                        -- Ready
signal T_RESB         :STD_LOGIC;                        -- Reset
signal T_RWB          :STD_LOGIC;                         -- Read/Write
signal T_SOB          :STD_LOGIC;                         -- Set Overflow
signal T_SYNC         :STD_LOGIC;                         -- Synchronize
signal T_VPB          :STD_LOGIC;                         -- Vector Pull

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
    assert (T_DATA_MODEL = x"FE") report "Boot data byte 1 not FE" severity failure;
    wait until T_PHI2 = '1';
    wait until T_PHI2 = '1';
    assert (T_ADDRESS = x"FFFD") report "Boot vector address 2 not FFFD" severity failure;
    assert (T_DATA_MODEL = x"ED") report "Boot data byte 2 not ED" severity failure;
    
    assert (false) report "Test completed successfully" severity failure;
end process;
end Behavioral;
