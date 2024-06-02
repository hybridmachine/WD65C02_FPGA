----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/02/2024 09:15:46 AM
-- Design Name: 
-- Module Name: PKG_MEMORY_MAP - 
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
-- Function to identify what region of memory an address is in.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.W65C02_DEFINITIONS.ALL;

package MEMORY_MAP is
    type MEMORY_REGION is (BOOT_VECTOR, ROM, RAM, MEMORY_MAPPED_IO, OUT_OF_RANGE);
    
    function MemoryRegion(signal address : ADDRESS_65C02_T) return MEMORY_REGION;
end package;

package body MEMORY_MAP is

    function MemoryRegion(signal address : ADDRESS_65C02_T) return MEMORY_REGION is
    variable MEMORY_ADDRESS : unsigned;
    begin
        MEMORY_ADDRESS := unsigned(address);
        if (unsigned(BOOT_VEC_ADDRESS_LOW) = MEMORY_ADDRESS or unsigned(BOOT_VEC_ADDRESS_HIGH) = MEMORY_ADDRESS) then
            return BOOT_VECTOR;
        end if;
        
        if (unsigned(RAM_BASE) <= MEMORY_ADDRESS and unsigned(RAM_END) >= MEMORY_ADDRESS) then
            if (unsigned(MEM_MAPPED_IO_BASE) <= MEMORY_ADDRESS and unsigned(MEM_MAPPED_IO_END) >= MEMORY_ADDRESS) then
                return MEMORY_MAPPED_IO;
            end if;
            return RAM;
        end if;
        
        if (unsigned(ROM_BASE) <= MEMORY_ADDRESS and unsigned(ROM_END) >= MEMORY_ADDRESS) then
            return ROM;
        end if;
        
        return OUT_OF_RANGE;
    end function;
end package body MEMORY_MAP;
