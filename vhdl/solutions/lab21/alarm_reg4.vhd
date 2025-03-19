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
use IEEE.numeric_std.all; 

use work.ALARM_TYPES.all;

entity ALARM_REG4 is
  port (CLOCK, RESET : in  std_logic;
        SET_DATA     : in  DISPLAY_4;
        LOAD_A       : in  std_logic;
        ALARM_DATA   : out DISPLAY_4);
end ALARM_REG4;

architecture RTL of ALARM_REG4 is

begin

  -- alarm register
  -- in normal mode, alarm data unchanged
  -- in set mode, alarm data from set_data
  ALREG: process (CLOCK, RESET)
  begin
    if RESET = '0' then
      ALARM_DATA <= (others => (others => '0'));
    elsif CLOCK'event and CLOCK='1' then
      if LOAD_A = '1' then
        ALARM_DATA <= SET_DATA;
      end if;
    end if;
  end process ALREG;

end RTL;
