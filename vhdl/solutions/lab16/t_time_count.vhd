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
     port(SET_DATA            : in DISPLAY_4;
          LOAD_T              : in std_logic;
          CLOCK, ONE_MINUTE, 
          RESET               : in std_logic;
          TIME_DATA           : out DISPLAY_4);
   end component;

  signal SET_DATA   : DISPLAY_4;
  signal LOAD_T     : std_logic:= '0';
  signal CLOCK      : std_logic:= '0';
  signal RESET      : std_logic:= '1';
  signal ONE_MINUTE : std_logic:= '0';
  signal TIME_DATA  : DISPLAY_4;
  
  constant PERIOD : time := 10 ns;
  constant SECOND : time := PERIOD * 2;

begin

   ---------------------------------------------
   -- instantiate UUT
   ---------------------------------------------

   uut : TIME_COUNT port map(SET_DATA, LOAD_T, CLOCK, ONE_MINUTE, RESET, TIME_DATA);

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
      -- pulse reset
      wait for PERIOD;
      RESET <= '0';
      wait for PERIOD;
      RESET <= '1';
      wait for period/2;

      -- load 00:08 and count up
      LOAD_T <= '1';
      SET_DATA <= ("0000", "0000", "0000", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;
     
      -- load 00:58 and watch rollover
      LOAD_T <= '1';
      SET_DATA <= ("0000", "0000", "0101", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;
 
      -- load 09:58 and watch rollover
      LOAD_T <= '1';
      SET_DATA <= ("0000", "1001", "0101", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;
      
      -- load 10:58 and watch rollover
      LOAD_T <= '1';
      SET_DATA <= ("0001", "0000", "0101", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;
 
      -- load 11:58 and watch rollover
      LOAD_T <= '1';
      SET_DATA <= ("0001", "0001", "0101", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;

      -- load 23:58 and watch rollover
      LOAD_T <= '1';
      SET_DATA <= ("0010", "0011", "0101", "1000");
      wait for SECOND;
      LOAD_T <= '0';
      wait for 5 * SECOND;
      report "Simulation Over" severity Error;
      wait;

   end process STIMULUS;


end TEST;

      
      


