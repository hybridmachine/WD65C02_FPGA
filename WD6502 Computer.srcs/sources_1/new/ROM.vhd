----------------------------------------------------------------------------------
-- Engineer: Brian Tabone
-- 
-- Create Date: 08/08/2023 04:00:45 PM
-- Design Name: 
-- Module Name: rom - inferred_rom
-- Project Name: WD6502 Computer
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM is
    PORT (
	addra: IN std_logic_VECTOR(15 downto 0);
	clka: IN std_logic;
	douta: OUT std_logic_VECTOR(7 downto 0)
  );
end ROM;

-- Adapted from example on Page 516 of "Effective Coding with VHDL"
architecture inferred_rom_arch of ROM is
    subtype BYTE is STD_LOGIC_VECTOR(7 downto 0);
    type ROM_BYTES is array(natural range 0 to 1023) of BYTE;

    constant ROM_DATA : ROM_BYTES := 
        (
            -- Address: 0x0000
            x"FE", x"ED", x"FA", x"CE",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0080
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0100
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0180
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0200
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0280
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0300
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            -- Address: 0x0380
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            x"00", x"00", x"00", x"00",
            --FFFC, FFFD, FFFE, FFFF -- Jump to beginning of ROM
            ROM_BASE(7 downto 0), ROM_BASE(15 downto 8), x"00", x"00"         
        );
begin

    -- Since port A and B read and write to the same signal (memory) they
    -- must live inside the same process
    process(clka)
    variable read_address : natural := 0;
    begin
        -- Note no protection, if caller writes via A and B , no 
        -- locking of address occurs, synchronizing ports is the caller's
        -- responsibility
        if (clka'event and clka = '1') then
            read_address := to_integer(unsigned(addra));
            douta <= ROM_DATA(read_address);
        end if;        
    end process;
end inferred_rom_arch;