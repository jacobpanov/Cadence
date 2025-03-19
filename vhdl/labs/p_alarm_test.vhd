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
use IEEE.Std_Logic_1164.all; 
use std.textio.all;

------------------------------------------------------------------------
-- Package Declaration
------------------------------------------------------------------------

   package ALARM_TEST is
   
   -- Constant for the clock period we will use  
  constant PERIOD : time := 10 ns;
  constant HALFPERIOD : time := PERIOD/2;
  constant HALF_SEC_PERIOD : time := 64 * PERIOD;    --  assuming 128Hz clock
  constant FIVE_SEC_PERIOD : time := 10 * HALF_SEC_PERIOD;
  constant ONE_MIN_PERIOD : time := 7680 * PERIOD;   --  
  
  -- timeout constants
  constant MAX_MIN_SET : time := 120 * HALF_SEC_PERIOD;    
  constant MAX_HOUR_SET : time := 48 *  HALF_SEC_PERIOD;
  constant MAX_TIME_SET : time := 60 * 24 * ONE_MIN_PERIOD;
   
   ------------------------------------------------------------------------
   -- The following procedures perform the actions required of the commands
   -- SHALM, SETAL, SETTI, COUNT and KTOUT
   ------------------------------------------------------------------------
   
  procedure DO_SHALM (signal SHARLM: out std_logic);
  
  --procedure DO_ALTOG ();     -- fill in procedure declaration
     
  procedure DO_AL_MN (SETTING: in string(1 to 2);
                      signal MS_MIN, LS_MIN : in std_logic_vector(3 downto 0);
                      signal SHARLM : out std_logic;
                      signal MINS: out std_logic);
   
  --procedure DO_AL_HR ();    -- fill in procedure declaration   
   
  --procedure DO_TI_MN ();    -- fill in procedure declaration
   
  --procedure DO_TI_HR ();    -- fill in procedure declaration
   
  --procedure DO_TIME ();     -- fill in procedure declaration
  
  function CHAR2VEC (CHAR : character) return std_logic_vector;
    
end ALARM_TEST;


------------------------------------------------------------------------
-- Package Body Declaration
------------------------------------------------------------------------
package body ALARM_TEST is
   
  function CHAR2VEC (CHAR : character) return std_logic_vector is
     variable VEC : std_logic_vector(3 downto 0);
  begin
     case CHAR is
    when '0' => VEC := "0000";
    when '1' => VEC := "0001";
    when '2' => VEC := "0010";
    when '3' => VEC := "0011";
    when '4' => VEC := "0100";
    when '5' => VEC := "0101";
    when '6' => VEC := "0110";
    when '7' => VEC := "0111";
    when '8' => VEC := "1000";
    when '9' => VEC := "1001";
    when others => 
     end case;
     return VEC;
  end CHAR2VEC;
   
   
   ------------------------------------------------------------------------
   -- SHALM Show Alarm command
   ------------------------------------------------------------------------
  procedure DO_SHALM (signal SHARLM: out std_logic) is
  begin
     SHARLM <= '0';
     wait for FIVE_SEC_PERIOD;
     SHARLM <= '1';
  end DO_SHALM;
 
 
    ------------------------------------------------------------------------
   -- ALTOG Toggle Alarm State command
   ------------------------------------------------------------------------
  
  --procedure DO_ALTOG ( -- fill in the procedure declaration
  --                    ) is
  --begin
     -- Write a procedure to simulate pressing down the ALRMON button,
     -- holding it for HALF_SEC_PERIOD, then releasing it
  --end DO_ALTOG;
   
   ------------------------------------------------------------------------
   -- AL_MN Set Alarm Minutes command
   ------------------------------------------------------------------------
  procedure DO_AL_MN (SETTING: in string(1 to 2);
                      signal MS_MIN, LS_MIN : in std_logic_vector(3 downto 0);
                      signal SHARLM : out std_logic;
                      signal MINS: out std_logic) is
     variable MS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(1));
     variable LS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(2));
  begin
     SHARLM <= '0';
     MINS <= '0';
     wait until ((MS_MIN = MS_SET) and (LS_MIN = LS_SET)) for MAX_MIN_SET;
     assert  ((MS_MIN = MS_SET) and (LS_MIN = LS_SET))
       report "timeout on alarm minute set to " & SETTING
       severity ERROR;
     SHARLM <= '1';
     MINS <= '1';
  end DO_AL_MN;
   
   ------------------------------------------------------------------------
   -- AL_HR Set Alarm Minutes command
   ------------------------------------------------------------------------
  --procedure DO_AL_HR ( -- fill in the procedure declaration
  --                   ) is
      -- local variables
  --begin
      -- Write a procedure to set the alarm hour to the required value
      -- press the SHARLM and HOURS buttons
      -- wait until the display digits match the required values, for the
      -- timeout MAX_HOUR_SET
      -- check if the Display Digits are correct
      -- release the SHARLM and HOURS buttons
  --end DO_AL_HR;
   
   ------------------------------------------------------------------------
   -- TI_MN Set Time Minutes command
   ------------------------------------------------------------------------
  --procedure DO_TI_MN ( -- fill in the procedure declaration
  --                   ) is
      -- local variables
  --begin
      -- Write a procedure to set the time minutes to the required value
      -- press the MINS button
      -- wait until the display digits match the required values, for the
      -- timeout MAX_MIN_SET
      -- check if the Display Digits are correct
      -- release the MINS button
  --end DO_TI_MN;
   
   ------------------------------------------------------------------------
   -- TI_HR Set Time Hour command
   ------------------------------------------------------------------------
  --procedure DO_TI_HR ( -- fill in the procedure declaration
  --                   ) is
      -- local variables
  --begin
      -- Write a procedure to set the time hour to the required value
      -- press the HOURS button
      -- wait until the display digits match the required values, for the
      -- timeout MAX_HOUR_SET
      -- check if the Display Digits are correct
      -- release the HOURS button
  --end DO_TI_HR;
   
   ------------------------------------------------------------------------
   -- DO_TIME command
   ------------------------------------------------------------------------
  --procedure DO_TIME ( -- fill in the procedure declaration
  --                   ) is
      -- local variables
  --begin
      -- Write a procedure to count time to the required value
      -- wait until the display digits match the required values, for the
      -- timeout MAX_TIME_SET
      -- check if the Display Digits are correct
  --end DO_TIME;
   
end ALARM_TEST;
