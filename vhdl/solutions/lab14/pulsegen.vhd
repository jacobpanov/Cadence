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
use IEEE.numeric_std.all;              -- arithmetic package reference

--use work.ALARM_TYPES.all;

entity PULSEGEN is
  port (CLOCK, RESET : in  std_logic;    -- control
        HALF_SECOND  : out std_logic;    -- 1/2 sec timed pulse
        ONE_MINUTE   : out std_logic);   -- 1 minute timed pulse    
end PULSEGEN;

architecture RTL of PULSEGEN is

  signal COUNT : unsigned(13 downto 0);

  -- count 0 to 7679 = 7680 cycles
  constant MAX : integer := 7679;

begin

  PULSES: process (CLOCK, RESET)
    -- generate ONE_MINUTE from within registered process
    -- this synthesizes an extra register but allows us to share the 
    -- comparison to MAX
  begin
    if RESET = '0' then
      COUNT <= (others => '0');
      ONE_MINUTE <= '0';
    elsif rising_edge(CLOCK) then
      ONE_MINUTE <= '0';
      if COUNT =  MAX then
        COUNT <= (others => '0');
        -- one minute sync'ed to all zero count
        ONE_MINUTE <= '1';
      else
        COUNT <= COUNT + 1;
      end if;
    end if;
  end process PULSES;

  -- concurrent statement used to create SEC pulse to
  -- ensure synchronized to one minute pulse
  HALF_SECOND <= '1' when COUNT(5 downto 0) = 0 else '0';
              
end RTL;
