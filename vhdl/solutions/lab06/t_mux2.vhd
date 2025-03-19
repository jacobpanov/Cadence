-----------------------------------------------------------------------
-- 
-- Original Code Copyright (c)2003 by Esperan (www.esperan.com)
--           World-wide leaders in independent, 
--     methodology-based training for electronic design
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

entity TB_MUX2 is
end TB_MUX2;

architecture BENCH of TB_MUX2 is

  -- component declaration for MUX
  component MUX2
    port (TIME_DATA    : in std_logic_vector(3 downto 0);
          ALARM_DATA   : in std_logic_vector(3 downto 0);
          SET_DATA     : in std_logic_vector(3 downto 0);
          SHOW_A       : in  std_logic;
          SHOW_T       : in  std_logic;
          DISPLAY      : out std_logic_vector(3 downto 0));
  end component;

  -- local signal declarations
  signal TIME_DATA, ALARM_DATA, SET_DATA, DISPLAY : std_logic_vector(3 downto 0);
  signal SHOW_A, SHOW_T : std_logic;  

begin

  -- component instantiation of MUX
  DUT : MUX2 port map (TIME_DATA, ALARM_DATA, SET_DATA, SHOW_A, SHOW_T, DISPLAY);
 
  -- stimulus process
   STIMULUS: process
   begin
      TIME_DATA  <= "0000"; 
      ALARM_DATA <= "1111";
      SET_DATA   <= "0101";
      SHOW_A     <= '0';
      SHOW_T     <= '0';
      wait for 10 ns;           -- both selectors off - display = set_data

      SET_DATA   <= "1010";
      wait for 10 ns;           -- toggle set_data

      SHOW_T     <= '1';
      wait for 10 ns;           -- display time_data

      TIME_DATA   <= "1100";
      wait for 10 ns;           -- change time_data 
      
      SHOW_A     <= '1';
      SHOW_T     <= '0';
      wait for 10 ns;           -- display alarm_data
      
      ALARM_DATA   <= "0011";
      wait for 10 ns;           -- change alarm_data 
      
      SHOW_T     <= '1';
      wait for 10 ns;           -- both selectors on - display = time_data
      
      SET_DATA   <= "0101";
      TIME_DATA  <= "0011"; 
      ALARM_DATA <= "1100";
      wait for 10 ns;

      wait;  -- suspend process
   end process STIMULUS;

end BENCH;
