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

entity CONTROL is
  port (CLOCK, RESET : in  std_logic;
        AL           : in  std_logic;
        MN           : in  std_logic;
        HR           : in  std_logic;
        SHOW_A       : out std_logic;
        LOAD_A       : out std_logic;
        SHOW_T       : out std_logic;
        LOAD_T       : out std_logic;
        INC_HOUR     : out std_logic;
        INC_MIN      : out std_logic);
end CONTROL;

architecture RTL of CONTROL is

  type STATE_T is (SHOW_TIME, SHOW_ALARM,
                   INC_AL_MIN, INC_AL_HR,
                   INC_TI_MIN, INC_TI_HR,
                   TIME_SET, ALARM_SET);
  signal STATE : STATE_T;

begin

  FSM : process (CLOCK, RESET)
  begin
    if RESET = '0' then
      STATE <= SHOW_TIME;
    elsif CLOCK'event and CLOCK='1' then
      case STATE is
        when SHOW_TIME =>
          if AL = '1' then
            STATE <= SHOW_ALARM;
          elsif HR = '1' then      -- ~AL.HR
            STATE <= INC_TI_HR;
          elsif MN = '1' then      -- ~AL.MN
            STATE <= INC_TI_MIN;
          end if;
        when SHOW_ALARM =>
          if AL = '0' then         -- ~AL
            STATE <= SHOW_TIME;
          elsif HR = '1' then      -- AL.HR
            STATE <= INC_AL_HR;
          elsif MN = '1' then      -- AL.MN
            STATE <= INC_AL_MIN;
          end if;
        when INC_TI_HR =>
          if HR = '0' then         -- ~HR
            STATE <= TIME_SET;
          end if;
        when INC_TI_MIN =>  
          if MN = '0' then         -- ~MN
            STATE <= TIME_SET;
          end if;
        when TIME_SET =>
          STATE <= SHOW_TIME;
        when INC_AL_HR =>
          if HR = '0' then         -- ~HR
            STATE <= ALARM_SET;  
          end if;
        when INC_AL_MIN =>         -- ~MN
          if MN = '0' then
            STATE <= ALARM_SET;  
          end if;
        when ALARM_SET =>
          STATE <= SHOW_ALARM;
      end case;
    end if;
  end process FSM;

  SHOW_A   <= '1' when STATE = SHOW_ALARM else '0';
  LOAD_A   <= '1' when STATE = ALARM_SET else '0';

  SHOW_T   <= '1' when STATE = SHOW_TIME else '0'; 
  LOAD_T   <= '1' when STATE = TIME_SET else '0';

  with STATE select
    INC_HOUR    <= '1' when INC_AL_HR | INC_TI_HR,
                   '0' when others;

  with STATE select
    INC_MIN     <= '1' when INC_AL_MIN | INC_TI_MIN,
                   '0' when others;
                 
end RTL;
