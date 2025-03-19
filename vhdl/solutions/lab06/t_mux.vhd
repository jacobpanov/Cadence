-----------------------------------------------------------------------
-- 
-- Original Code Copyright (c)2003 by Esperan (www.esperan.com)
--  World-wide leaders in independent, 
--  methodology-based training for electronic design
--
-- All rights reserved.
-- 
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains this copyright notice. 
--
-----------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity TB_MUX is
end TB_MUX;

architecture BENCH of TB_MUX is

  -- component declaration for MUX
  component MUX
    port (TIME_DATA    : in std_logic_vector(3 downto 0);
          ALARM_DATA   : in std_logic_vector(3 downto 0);
          SHOW_A       : in  std_logic;
          DISPLAY      : out std_logic_vector(3 downto 0));
  end component;

  -- local signal declarations
  signal TIME_DATA, ALARM_DATA, DISPLAY : std_logic_vector(3 downto 0);
  signal SHOW_A : std_logic;  

begin

  -- component instantiation of MUX
  DUT : MUX port map (TIME_DATA, ALARM_DATA, SHOW_A, DISPLAY);
 
  -- stimulus process
   STIMULUS: process
   begin
      TIME_DATA  <= "0000"; 
      ALARM_DATA <= "1111";
      SHOW_A     <= '0';
      wait for 10 ns;

      SHOW_A     <= '1';
      wait for 10 ns;

      TIME_DATA  <= "0011"; 
      ALARM_DATA <= "1100";
      SHOW_A     <= '0';
      wait for 10 ns;

      wait;  -- suspend process
   end process STIMULUS;

end BENCH;
