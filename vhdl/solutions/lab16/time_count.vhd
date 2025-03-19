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

Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;   

use work.ALARM_TYPES.all;

entity TIME_COUNT is
   port( SET_DATA            : in DISPLAY_4;
         LOAD_T              : in std_logic;
         CLOCK, ONE_MINUTE, 
         RESET               : in std_logic;
         TIME_DATA           : out DISPLAY_4);
end TIME_COUNT;

architecture RTL of TIME_COUNT is
   
   constant ZERO : unsigned(3 downto 0) := "0000";

   -- Declaration of intermediate signal required...
   -- for numeric_std package, use type unsigned
   signal LS_MIN, MS_MIN, LS_HR, MS_HR : unsigned(3 downto 0);   

begin

   TIME_COUNTER:
   process(CLOCK, RESET)
   begin
   
      if (RESET = '0') then
         LS_MIN <= "0000";
         MS_MIN <= "0000";
         LS_HR <= "0000"; 
         MS_HR <= "0000";
      elsif (rising_edge(CLOCK)) then

         if (LOAD_T = '1') then
            -- capture new current time
            LS_MIN <= SET_DATA(0);
            MS_MIN <= SET_DATA(1);
            LS_HR <=  SET_DATA(2); 
            MS_HR <=  SET_DATA(3);

         elsif ONE_MINUTE = '1' then  -- count when enabled
            -- start with exceptional case of 23:59 and ripple from
            -- MS_HOUR to LS_MIN
            -- Not the best method for simulation efficiency (most common condition checked last)
            -- but easiest to design
           if MS_HR = 2 and LS_HR = 3 and MS_MIN = 5 and LS_MIN = 9 then
             MS_HR <= ZERO;
             LS_HR <= ZERO;
             MS_MIN <= ZERO;
             LS_MIN <= ZERO;
           elsif LS_HR = 9 and MS_MIN = 5 and LS_MIN = 9 then
             MS_HR <= MS_HR + 1;
             LS_HR <= ZERO;
             MS_MIN <= ZERO;
             LS_MIN <= ZERO;
           elsif MS_MIN = 5 and LS_MIN = 9 then
             LS_HR <= LS_HR + 1;
             MS_MIN <= ZERO;
             LS_MIN <= ZERO;
           elsif LS_MIN = 9 then
             MS_MIN <= MS_MIN + 1;
             LS_MIN <= ZERO;
           else
             LS_MIN <= LS_MIN + 1;
           end if;
         end if; -- (ONE_MINUTE = '1')
       end if; -- CLK'event

   end process TIME_COUNTER;

   TIME_DATA <= (MS_HR, LS_HR, MS_MIN, LS_MIN);
            
end RTL ;
