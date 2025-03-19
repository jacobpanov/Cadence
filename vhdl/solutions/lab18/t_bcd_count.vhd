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

use work.ALARM_TYPES.all;

entity TEST_BCD2_COUNT is
end TEST_BCD2_COUNT;

architecture BENCH of TEST_BCD2_COUNT is
   
  component TIME_SET
    port (CLOCK, RESET : in  std_logic;   -- control
          HALF_SECOND  : in  std_logic;   -- 1/2 sec timed pulse 
          TIME_DATA    : in  DISPLAY_T;
          ALARM_DATA   : in  DISPLAY_T;
          SHOW_A       : in  std_logic;
          SHOW_T       : in  std_logic;
          INC_HOUR     : in  std_logic;
          INC_MIN      : in  std_logic;
          SET_DATA     : out DISPLAY_T);
  end component;
   
  signal CLOCK, RESET, HALF_SECOND : std_logic := '0';
  signal SHOW_T, SHOW_A, INC_HOUR, INC_MIN : std_logic := '0';
  signal TIME_DATA, ALARM_DATA, SET_DATA : DISPLAY_T;
   
begin
   
  CLOCK <= not CLOCK after 10 ns;
  RESET <= '0', '1' after 5 ns, '0' after 15 ns;
   
  HSGEN: 
  process
  begin
    HALF_SECOND <= '0';
    wait until CLOCK = '1';
    loop
      wait until CLOCK = '1';
      wait until CLOCK = '1';
      HALF_SECOND <= '0';
      wait until CLOCK = '1';
      HALF_SECOND <= '1';
    end loop;
  end process;
   
   
  -- counting to 59
  MINS: BCD2_COUNT generic map (5, 9)
        port map (CLOCK, RESET, LOAD, MN_DATA, ENABLE, MN_OP);
   
  -- counting to 23
  HRS:  BCD2_COUNT generic map (2, 3)
        port map (CLOCK, RESET, LOAD, HR_DATA, ENABLE, HR_OP);
   
   
  BC: 
  process
  begin
    TIME_DATA <= ("0000", "0000");
    ALARM_DATA <= ("0000", "0000");
    LOAD <= '0';
    -- sync to -ve edge clock
    wait until CLOCK = '0';
    -- count 12 cycles to check initial counting
    for I in 0 to 11 loop
      wait until CLOCK = '0';
    end loop;
    -- load minutes 49
    TIME_DATA <= ("0100", "1001");
    -- load hours 19
    ALARM_DATA <= ("0001", "1001");
    LOAD <= '1';
    wait until CLOCK = '0';
    LOAD <= '0';
    -- count 12 cycles to check rollover counting
    for I in 0 to 11 loop
      wait until CLOCK = '0';
    end loop;
      
    report "simulation over";
    wait;
      
  end process BC;
   
   
end BENCH;
