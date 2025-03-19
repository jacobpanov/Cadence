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

entity T_TIMECOUNT is
end T_TIMECOUNT ;

architecture TEST of T_TIMECOUNT is
   component TIME_COUNT
     port(
          -- add port list
          );
   end component;

  signal SET_DATA   : -- array of array type from package
  signal LOAD_T     : std_logic:= '0';
  signal CLOCK      : std_logic:= '0';
  signal RESET      : std_logic:= '1';
  signal ONE_MINUTE : std_logic:= '0';
  signal TIME_DATA  : -- array of array type from package

  
  constant PERIOD : time := 10 ns;
  constant SECOND : time := PERIOD * 2;

begin

   ---------------------------------------------
   -- instantiate UUT
   ---------------------------------------------

   uut : TIME_COUNT port map( -- add port map );

   ---------------------------------------------
   -- infinite clock generator 
   ---------------------------------------------

   CLOCK <= not CLOCK after PERIOD/2;

   ---------------------------------------------
   -- one_minute generator - make equal to twice CLK to
   -- make testing quicker
   ---------------------------------------------

   ONE_MINUTE <= not ONE_MINUTE after PERIOD;

   --------------------------------------------------
   -- Stimulus: we want to
   --   1. pulse reset
   --   2. load 00:08 and watch rollover
   --   3. Load 00:58 and watch rollover
   --   4. Load 09:58 and watch rollover
   --   5. Load 11:58 and watch rollover
   --   6. Load 23:58 and watch rollover
   --   7. Just let it count
   -------------------------------------------------
   STIMULUS : process
   begin

      -- add stimulus

   end process STIMULUS;


end TEST;

      
      


