-- Adapted from chapter 06 Linear Feedback Shift Register LFSR.vhd
-- Merrick, Russell. Getting Started with FPGAs: Digital Circuit Design, Verilog, and VHDL for 
-- Beginners (p. 101). (Function). Kindle Edition. 
-- https://github.com/nandland/getting-started-with-fpgas/blob/main/chapter06/lfsr/VHDL/source/LFSR.vhd
--
-- Generics:
-- NUM_BITS - Set to the integer number of bits wide to create your PSRND.

library ieee;
use ieee.std_logic_1164.all;

entity PIO_PSRND is
  generic (
    NUM_BITS : integer := 5);
  port (
    i_Clk    : in std_logic;
    i_Enable : in std_logic;

    -- Optional Seed Value
    i_Seed_DV   : in std_logic;
    i_Seed_Data : in std_logic_vector(NUM_BITS-1 downto 0);
    
    o_PSRND_Data : out std_logic_vector(NUM_BITS-1 downto 0);
    o_PSRND_Done : out std_logic);
end entity PSRND;

architecture RTL of PSRND is

  signal r_PSRND : std_logic_vector(NUM_BITS downto 1) := (others => '0');
  signal w_XNOR : std_logic;
  
begin

  -- Purpose: Load up PSRND with Seed if Data Valid (DV) pulse is detected.
  -- Othewise just run PSRND when enabled.
  process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if i_Enable = '1' then
        if i_Seed_DV = '1' then
          r_PSRND <= i_Seed_Data;
        else
          r_PSRND <= r_PSRND(r_PSRND'left-1 downto 1) & w_XNOR;
        end if;
      end if;
    end if;
  end process; 

  -- Create Feedback Polynomials.  Based on Application Note XAPP052.PDF
  g_PSRND_3 : if NUM_BITS = 3 generate
    w_XNOR <= r_PSRND(3) xnor r_PSRND(2);
  end generate g_PSRND_3;

  g_PSRND_4 : if NUM_BITS = 4 generate
    w_XNOR <= r_PSRND(4) xnor r_PSRND(3);
  end generate g_PSRND_4;

  g_PSRND_5 : if NUM_BITS = 5 generate
    w_XNOR <= r_PSRND(5) xnor r_PSRND(3);
  end generate g_PSRND_5;

  g_PSRND_6 : if NUM_BITS = 6 generate
    w_XNOR <= r_PSRND(6) xnor r_PSRND(5);
  end generate g_PSRND_6;

  g_PSRND_7 : if NUM_BITS = 7 generate
    w_XNOR <= r_PSRND(7) xnor r_PSRND(6);
  end generate g_PSRND_7;

  g_PSRND_8 : if NUM_BITS = 8 generate
    w_XNOR <= r_PSRND(8) xnor r_PSRND(6) xnor r_PSRND(5) xnor r_PSRND(4);
  end generate g_PSRND_8;

  g_PSRND_9 : if NUM_BITS = 9 generate
    w_XNOR <= r_PSRND(9) xnor r_PSRND(5);
  end generate g_PSRND_9;

  g_PSRND_10 : if NUM_BITS = 10 generate
    w_XNOR <= r_PSRND(10) xnor r_PSRND(7);
  end generate g_PSRND_10;

  g_PSRND_11 : if NUM_BITS = 11 generate
    w_XNOR <= r_PSRND(11) xnor r_PSRND(9);
  end generate g_PSRND_11;

  g_PSRND_12 : if NUM_BITS = 12 generate
    w_XNOR <= r_PSRND(12) xnor r_PSRND(6) xnor r_PSRND(4) xnor r_PSRND(1);
  end generate g_PSRND_12;

  g_PSRND_13 : if NUM_BITS = 13 generate
    w_XNOR <= r_PSRND(13) xnor r_PSRND(4) xnor r_PSRND(3) xnor r_PSRND(1);
  end generate g_PSRND_13;

  g_PSRND_14 : if NUM_BITS = 14 generate
    w_XNOR <= r_PSRND(14) xnor r_PSRND(5) xnor r_PSRND(3) xnor r_PSRND(1);
  end generate g_PSRND_14;

  g_PSRND_15 : if NUM_BITS = 15 generate
    w_XNOR <= r_PSRND(15) xnor r_PSRND(14);
  end generate g_PSRND_15;

  g_PSRND_16 : if NUM_BITS = 16 generate
    w_XNOR <= r_PSRND(16) xnor r_PSRND(15) xnor r_PSRND(13) xnor r_PSRND(4);
  end generate g_PSRND_16;

  g_PSRND_17 : if NUM_BITS = 17 generate
    w_XNOR <= r_PSRND(17) xnor r_PSRND(14);
  end generate g_PSRND_17;

  g_PSRND_18 : if NUM_BITS = 18 generate
    w_XNOR <= r_PSRND(18) xnor r_PSRND(11);
  end generate g_PSRND_18;

  g_PSRND_19 : if NUM_BITS = 19 generate
    w_XNOR <= r_PSRND(19) xnor r_PSRND(6) xnor r_PSRND(2) xnor r_PSRND(1);
  end generate g_PSRND_19;

  g_PSRND_20 : if NUM_BITS = 20 generate
    w_XNOR <= r_PSRND(20) xnor r_PSRND(17);
  end generate g_PSRND_20;

  g_PSRND_21 : if NUM_BITS = 21 generate
    w_XNOR <= r_PSRND(21) xnor r_PSRND(19);
  end generate g_PSRND_21;

  g_PSRND_22 : if NUM_BITS = 22 generate
    w_XNOR <= r_PSRND(22) xnor r_PSRND(21);
  end generate g_PSRND_22;

  g_PSRND_23 : if NUM_BITS = 23 generate
    w_XNOR <= r_PSRND(23) xnor r_PSRND(18);
  end generate g_PSRND_23;

  g_PSRND_24 : if NUM_BITS = 24 generate
    w_XNOR <= r_PSRND(24) xnor r_PSRND(23) xnor r_PSRND(22) xnor r_PSRND(17);
  end generate g_PSRND_24;

  g_PSRND_25 : if NUM_BITS = 25 generate
    w_XNOR <= r_PSRND(25) xnor r_PSRND(22);
  end generate g_PSRND_25;

  g_PSRND_26 : if NUM_BITS = 26 generate
    w_XNOR <= r_PSRND(26) xnor r_PSRND(6) xnor r_PSRND(2) xnor r_PSRND(1);
  end generate g_PSRND_26;

  g_PSRND_27 : if NUM_BITS = 27 generate
    w_XNOR <= r_PSRND(27) xnor r_PSRND(5) xnor r_PSRND(2) xnor r_PSRND(1);
  end generate g_PSRND_27;

  g_PSRND_28 : if NUM_BITS = 28 generate
    w_XNOR <= r_PSRND(28) xnor r_PSRND(25);
  end generate g_PSRND_28;

  g_PSRND_29 : if NUM_BITS = 29 generate
    w_XNOR <= r_PSRND(29) xnor r_PSRND(27);
  end generate g_PSRND_29;

  g_PSRND_30 : if NUM_BITS = 30 generate
    w_XNOR <= r_PSRND(30) xnor r_PSRND(6) xnor r_PSRND(4) xnor r_PSRND(1);
  end generate g_PSRND_30;

  g_PSRND_31 : if NUM_BITS = 31 generate
    w_XNOR <= r_PSRND(31) xnor r_PSRND(28);
  end generate g_PSRND_31;

  g_PSRND_32 : if NUM_BITS = 32 generate
    w_XNOR <= r_PSRND(32) xnor r_PSRND(22) xnor r_PSRND(2) xnor r_PSRND(1);
  end generate g_PSRND_32;
  
  
  o_PSRND_Data <= r_PSRND(r_PSRND'left downto 1);
  o_PSRND_Done <= '1' when r_PSRND(r_PSRND'left downto 1) = i_Seed_Data else '0';
  
end architecture RTL;
