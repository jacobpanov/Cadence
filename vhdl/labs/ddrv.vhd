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

use work.ALARM_TYPES.all;

entity DDRV is
  port (TIME_DATA    : in std_logic_vector(3 downto 0);
        ALARM_DATA   : in std_logic_vector(3 downto 0);
        SET_DATA     : in std_logic_vector(3 downto 0);
        SHOW_A       : in  std_logic;
        SHOW_T       : in  std_logic;
        ALARM_ON     : in  std_logic;
        SOUND_A      : out std_logic;
        DISP_7SEG    : out std_logic_vector(6 downto 0));
end DDRV;

architecture RTL of DDRV is
  signal DISPLAY : std_logic_vector(3 downto 0);

begin
 
  DISP_MUX3: process (TIME_DATA, ALARM_DATA, SET_DATA, SHOW_A, SHOW_T, ALARM_ON)
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
    
  end process DISP_MUX3;
  
  ENC: process (DISPLAY)
  begin
    case DISPLAY is
      when "0000" => 
        DISP_7SEG <= ZERO_SEG;
      when "0001" => 
        DISP_7SEG <= ONE_SEG;
      when "0010" => 
        DISP_7SEG <= TWO_SEG;        
      when "0011" => 
        DISP_7SEG <= THREE_SEG;
      when "0100" => 
        DISP_7SEG <= FOUR_SEG;
      when "0101" => 
        DISP_7SEG <= FIVE_SEG;
      when "0110" => 
        DISP_7SEG <= SIX_SEG;
      when "0111" => 
        DISP_7SEG <= SEVEN_SEG;
      when "1000" => 
        DISP_7SEG <= EIGHT_SEG;
      when "1001" => 
        DISP_7SEG <= NINE_SEG;
      when others => 
        DISP_7SEG <= E_SEG;
    end case;
   end process ENC;


end RTL;
