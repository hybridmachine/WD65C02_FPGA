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

package MEMORY_MANAGER is
    type MEMORY_REGION is (BOOT_VECTOR_REGION, ROM_REGION, RAM_REGION, MEMORY_MAPPED_IO_REGION, OUT_OF_RANGE);
    type READ_WRITE_MODE is (READ_FROM_MEMORY, WRITE_TO_MEMORY);

    function MemoryRegion(signal address : ADDRESS_65C02_T) return MEMORY_REGION;
    
    procedure ReadBootVector(signal data_out : out DATA_65C02_T; 
                             signal address : in ADDRESS_65C02_T);
    procedure ReadROM(signal memory_data_out : out DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal rom_address : out ADDRESS_65C02_T;
                      signal rom_data : in DATA_65C02_T);
                      
    procedure ReadRAM(signal memory_data_out : out DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal ram_address : out ADDRESS_65C02_T;
                      signal ram_data : in DATA_65C02_T);
    
    procedure WriteRAM(signal memory_data_in : in DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal ram_address : out ADDRESS_65C02_T;
                      signal ram_data : out DATA_65C02_T);
    
    procedure WritePIO(signal memory_data_in : in DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal ram_address : out ADDRESS_65C02_T;
                      signal ram_data : out DATA_65C02_T);
end package MEMORY_MANAGER;

package body MEMORY_MANAGER is

    function MemoryRegion(signal address : ADDRESS_65C02_T) return MEMORY_REGION is
    variable MEMORY_ADDRESS : unsigned(15 downto 0);
    begin
        MEMORY_ADDRESS := unsigned(address);
        if (unsigned(BOOT_VEC_ADDRESS_LOW) = MEMORY_ADDRESS or unsigned(BOOT_VEC_ADDRESS_HIGH) = MEMORY_ADDRESS) then
            return BOOT_VECTOR_REGION;
        end if;
        
        if (unsigned(RAM_BASE) <= MEMORY_ADDRESS and unsigned(RAM_END) >= MEMORY_ADDRESS) then
            if (unsigned(MEM_MAPPED_IO_BASE) <= MEMORY_ADDRESS and unsigned(MEM_MAPPED_IO_END) >= MEMORY_ADDRESS) then
                return MEMORY_MAPPED_IO_REGION;
            end if;
            return RAM_REGION;
        end if;
        
        if (unsigned(ROM_BASE) <= MEMORY_ADDRESS and unsigned(ROM_END) >= MEMORY_ADDRESS) then
            return ROM_REGION;
        end if;
        
        return OUT_OF_RANGE;
    end function;
    
    procedure ReadBootVector(signal data_out : out DATA_65C02_T; 
                             signal address : in ADDRESS_65C02_T) is
    begin
        if (BOOT_VEC_ADDRESS_LOW = address) then
                data_out <= BOOT_VEC(7 downto 0);
            elsif (BOOT_VEC_ADDRESS_HIGH = address) then
                data_out <= BOOT_VEC(15 downto 8);
        end if;
    end procedure;
    
    procedure ReadROM(signal memory_data_out : out DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal rom_address : out ADDRESS_65C02_T;
                      signal rom_data : in DATA_65C02_T) is
    variable shifted_address : ADDRESS_65C02_T;
    begin
        shifted_address := ADDRESS_65C02_T(unsigned(memory_address) - unsigned(ROM_BASE));
        rom_address <= shifted_address;
        
        -- Won't be valid until next clock cycle. For now we run the memory faster than the CPU to make sure data is ready ahead of processor read
        memory_data_out <= rom_data; 
    end procedure;
    
    procedure ReadRAM(signal memory_data_out : out DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal ram_address : out ADDRESS_65C02_T;
                      signal ram_data : in DATA_65C02_T) is
    variable shifted_address : ADDRESS_65C02_T;
    begin
        shifted_address := ADDRESS_65C02_T(unsigned(memory_address) - unsigned(RAM_BASE));
        ram_address <= shifted_address;
        
        -- Won't be valid until next clock cycle. For now we run the memory faster than the CPU to make sure data is ready ahead of processor read
        memory_data_out <= ram_data; 
    end procedure;

    procedure WriteRAM(signal memory_data_in : in DATA_65C02_T; 
                      signal memory_address : in ADDRESS_65C02_T;
                      signal ram_address : out ADDRESS_65C02_T;
                      signal ram_data : out DATA_65C02_T) is
    variable shifted_address : ADDRESS_65C02_T;
    begin
        shifted_address := ADDRESS_65C02_T(unsigned(memory_address) - unsigned(RAM_BASE));
        ram_address <= shifted_address;
        
        ram_data <= memory_data_in; 
    end procedure;
    
    procedure WritePIO(signal memory_data_in : in DATA_65C02_T; 
                  signal memory_address : in ADDRESS_65C02_T;
                  signal ram_address : out ADDRESS_65C02_T;
                  signal ram_data : out DATA_65C02_T) is
    begin
        --TBD
    end procedure;
end package body MEMORY_MANAGER;
