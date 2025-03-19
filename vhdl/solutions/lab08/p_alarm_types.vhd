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
use IEEE.numeric_std.all;

package ALARM_TYPES is

  -- 7 segment encoding constants for digits 0 to 9
  constant ZERO_SEG  : std_logic_vector(6 downto 0):= "0111111";  -- 3F
  constant ONE_SEG   : std_logic_vector(6 downto 0):= "0000110";  -- 06
  constant TWO_SEG   : std_logic_vector(6 downto 0):= "1011011";  -- 56
  constant THREE_SEG : std_logic_vector(6 downto 0):= "1001111";  -- 4F
  constant FOUR_SEG  : std_logic_vector(6 downto 0):= "1100110";  -- 66
  constant FIVE_SEG  : std_logic_vector(6 downto 0):= "1101101";  -- 6D
  constant SIX_SEG   : std_logic_vector(6 downto 0):= "1111101";  -- 7D
  constant SEVEN_SEG : std_logic_vector(6 downto 0):= "0000111";  -- 07
  constant EIGHT_SEG : std_logic_vector(6 downto 0):= "1111111";  -- FF
  constant NINE_SEG  : std_logic_vector(6 downto 0):= "1101111";  -- 6F
  constant ERROR_SEG : std_logic_vector(6 downto 0):= "1111100";  -- 7C

  -- 2 and 4 digit BCD data types for labs 10 and 12 onwards
  type DISPLAY_T is array (natural range <>) of unsigned(3 downto 0);
  subtype DISPLAY_2 is DISPLAY_T(1 downto 0);
  subtype DISPLAY_4 is DISPLAY_T(3 downto 0);

  -- 4 digit seven-segment data type for lab 13
  type DISP7_T is array (3 downto 0) of std_logic_vector(6 downto 0);



  -- system driver constants
  -- DO NOT EDIT
  -- constant for debounce FSM lab 11
  constant NUM_DEBOUNCE_CYCLES : natural := 8;
  constant CLK_DIV_RATIO : positive := 4;

  -- constants to time LED pulses
  constant NUM_LED_ON_CYCLES : natural := 4;
  constant NUM_SECS_BETWEEN_PULSES : natural := 4;
  constant COUNT_LED_OFF : natural := 2*NUM_SECS_BETWEEN_PULSES;

end ALARM_TYPES;
