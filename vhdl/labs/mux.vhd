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

entity MUX is
  port (TIME_DATA    : in std_logic_vector(3 downto 0);
        ALARM_DATA   : in std_logic_vector(3 downto 0);
	SET_DATA     : in std_logic_vector(3 downto 0);
        SHOW_A       : in std_logic;
	SHOW_T       : in std_logic;
	ALARM_ON     : in std_logic;
        SOUND_A      : out std_logic;
        DISPLAY      : out std_logic_vector(3 downto 0));
end MUX;

architecture RTL of MUX is

begin
 
  DISP_MUX: process (TIME_DATA, ALARM_DATA, SET_DATA, ALARM_ON, SHOW_A, SHOW_T)
  begin
    if SHOW_T = '1' then
      DISPLAY <= TIME_DATA;
    elsif SHOW_A = '1' then
      DISPLAY <= ALARM_DATA;
    else 
      DISPLAY <= SET_DATA;
    end if;

    if ALARM_ON = '1' and TIME_DATA = ALARM_DATA then
      SOUND_A <= '1';
    else
      SOUND_A <= '0';
    end if;

  end process DISP_MUX;
               
end RTL;
