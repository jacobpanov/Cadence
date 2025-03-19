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

entity DDRV4 is
  port (TIME_DATA    : in DISPLAY_4;
        ALARM_DATA   : in DISPLAY_4;
        SET_DATA     : in DISPLAY_4;
        SHOW_T       : in std_logic;
        ALARM_ON     : in  std_logic;
        SHOW_A       : in  std_logic;
        SOUND_A      : out std_logic;
        DISP_7SEG    : out DISP7_T);
end DDRV4;

architecture RTL of DDRV4 is

  signal DISPLAY : DISPLAY_4;

begin
 
  TA_MUX: process (TIME_DATA, ALARM_DATA, SET_DATA, 
                   SHOW_T, SHOW_A, ALARM_ON)
  begin
    if SHOW_T = '1' then
      DISPLAY <= TIME_DATA;
    elsif SHOW_A = '1' then
      DISPLAY <= ALARM_DATA;
    else 
      DISPLAY <= SET_DATA;
    end if;

    SOUND_A <= '0';
    if ALARM_ON = '1' then
      if TIME_DATA= ALARM_DATA then
        SOUND_A <= '1';
      end if;
    end if;
  end process TA_MUX;

  BIN27: for I in 0 to 3 generate

    with DISPLAY(I) select
      DISP_7SEG(I) <= ZERO_SEG   when "0000",
                      ONE_SEG    when "0001",
                      TWO_SEG    when "0010",
                      THREE_SEG  when "0011",
                      FOUR_SEG   when "0100",
                      FIVE_SEG   when "0101",
                      SIX_SEG    when "0110",
                      SEVEN_SEG  when "0111",
                      EIGHT_SEG  when "1000",
                      NINE_SEG   when "1001",
                      ERROR_SEG  when others;

   end generate BIN27;
                  
end RTL;
