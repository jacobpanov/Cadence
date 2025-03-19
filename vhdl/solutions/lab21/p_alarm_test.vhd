-----------------------------------------------------------------------
-- 
-- Original Code Copyright (c) 1999 by Esperan. All rights reserved.
-- www.esperan.com
-- 
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains this copyright notice. 
--
-- P_altst.vhd
-- Package defining procedures used in the testbench for the
-- Alarm Clock Controller block (T_a_fsm.vhd)
--
----------------------------------------------------

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
  
  procedure DO_ALTOG (signal ALRMON: out std_logic);
     
  procedure DO_AL_MN (SETTING: in string(1 to 2);
                      signal MS_MIN, LS_MIN : in std_logic_vector(3 downto 0);
                      signal SHARLM : out std_logic;
                      signal MINS: out std_logic);
   
  procedure DO_AL_HR (SETTING: in string(1 to 2);
                      signal MS_HOUR, LS_HOUR : in std_logic_vector(3 downto 0);
                      signal SHARLM : out std_logic;
                      signal HOURS: out std_logic);      
   
  procedure DO_TI_MN (SETTING: in string(1 to 2);
                      signal MS_MIN, LS_MIN : in std_logic_vector(3 downto 0);
                      signal MINS: out std_logic);
   
  procedure DO_TI_HR (SETTING: in string(1 to 2);
                      signal MS_HOUR, LS_HOUR : in std_logic_vector(3 downto 0);
                      signal HOURS: out std_logic);
   
  procedure DO_TIME (SETTING: in string(1 to 4);
                      signal MS_HOUR, LS_HOUR, MS_MIN, LS_MIN : in std_logic_vector(3 downto 0));
  
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
    when others =>  VEC := "0000";
      assert false
        report "Error in setting: " & CHAR
        severity ERROR;
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
  
  procedure DO_ALTOG (signal ALRMON: out std_logic) is
  begin
     ALRMON <= '0';
     wait for HALF_SEC_PERIOD;
     ALRMON <= '1';
  end DO_ALTOG;
   
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
  procedure DO_AL_HR (SETTING: in string(1 to 2);
                      signal MS_HOUR, LS_HOUR : in std_logic_vector(3 downto 0);
                      signal SHARLM : out std_logic;
                      signal HOURS: out std_logic) is
     variable MS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(1));
     variable lS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(2));
  begin
     SHARLM <= '0';
     HOURS <= '0';
     wait until ((MS_HOUR = MS_SET) and (LS_HOUR = LS_SET)) for MAX_HOUR_SET;
     assert ((MS_HOUR = MS_SET) and (LS_HOUR = LS_SET))
       report "timeout on alarm hour set to " & SETTING
       severity ERROR;
     SHARLM <= '1';
     HOURS <= '1';
  end DO_AL_HR;
   
   ------------------------------------------------------------------------
   -- TI_MN Set Time Minutes command
   ------------------------------------------------------------------------
  procedure DO_TI_MN (SETTING: in string(1 to 2);
                      signal MS_MIN, LS_MIN : in std_logic_vector(3 downto 0);
                      signal MINS: out std_logic) is
     variable MS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(1));
     variable lS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(2));
  begin
     MINS <= '0';
     wait until ((MS_MIN = MS_SET) and (LS_MIN = LS_SET)) for MAX_MIN_SET;
     assert  ((MS_MIN = MS_SET) and (LS_MIN = LS_SET))
       report "timeout on time minute set to " & SETTING
       severity ERROR;
     MINS <= '1';
  end DO_TI_MN;
   
   ------------------------------------------------------------------------
   -- TI_HR Set Time Hour command
   ------------------------------------------------------------------------
  procedure DO_TI_HR (SETTING: in string(1 to 2);
                      signal MS_HOUR, LS_HOUR : in std_logic_vector(3 downto 0);
                      signal HOURS: out std_logic) is
     variable MS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(1));
     variable lS_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(2));
  begin
     HOURS <= '0';
     wait until ((MS_HOUR = MS_SET) and (LS_HOUR = LS_SET)) for MAX_HOUR_SET;
     assert ((MS_HOUR = MS_SET) and (LS_HOUR = LS_SET))
       report "timeout on time hour set to " & SETTING
       severity ERROR;
     HOURS <= '1';
  end DO_TI_HR;
   
   ------------------------------------------------------------------------
   -- DO_TIME command
   ------------------------------------------------------------------------
  procedure DO_TIME (SETTING: in string(1 to 4);
                     signal MS_HOUR, LS_HOUR, MS_MIN, LS_MIN : in std_logic_vector(3 downto 0)) is
     variable MS_HR_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(1));
     variable LS_HR_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(2));
     variable MS_MN_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(3));
     variable LS_MN_SET :  std_logic_vector(3 downto 0) := CHAR2VEC(SETTING(4));
  begin
     wait until ((MS_HOUR = MS_HR_SET) and (LS_HOUR = LS_HR_SET) 
         and (MS_MIN = MS_MN_SET) and (LS_MIN = LS_MN_SET)) for MAX_TIME_SET;
     assert ((MS_HOUR = MS_HR_SET) and (LS_HOUR = LS_HR_SET) 
         and (MS_MIN = MS_MN_SET) and (LS_MIN = LS_MN_SET))
       report "timeout on doing time to " & SETTING
       severity ERROR;
  end DO_TIME;
   
end ALARM_TEST;
