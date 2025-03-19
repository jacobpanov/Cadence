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

entity TEST_TIME_SET is
end TEST_TIME_SET;

architecture BENCH of TEST_TIME_SET is

component TIME_SET
  port (CLOCK, RESET : in  std_logic;   -- control
        HALF_SECOND  : in  std_logic;   -- 1/2 sec timed pulse 
        TIME_DATA    : in  DISPLAY_4;
        ALARM_DATA   : in  DISPLAY_4;
        SHOW_A       : in  std_logic;
        SHOW_T       : in  std_logic;
        INC_HOUR     : in  std_logic;
        INC_MIN      : in  std_logic;
        SET_DATA     : out DISPLAY_4);
end component;

  signal CLOCK, RESET, HALF_SECOND : std_logic := '0';
  signal SHOW_T, SHOW_A, INC_HOUR, INC_MIN : std_logic := '0';
  signal TIME_DATA, ALARM_DATA, SET_DATA : DISPLAY_4;

begin

  CLOCK <= not CLOCK after 10 ns;
  RESET <= '1', '0' after 5 ns, '1' after 15 ns;

  HSGEN: process
  begin
    HALF_SECOND <= '0';
    wait until CLOCK = '1';
    loop
      wait until CLOCK = '1';
      wait until CLOCK = '1';
      HALF_SECOND <= '1';
      wait until CLOCK = '1';
      HALF_SECOND <= '0';
    end loop;
  end process;
      
  TS: TIME_SET
  port map (CLOCK, RESET, HALF_SECOND,
            TIME_DATA, ALARM_DATA,
            SHOW_A, SHOW_T, INC_HOUR, INC_MIN,
            SET_DATA);

  BC: process
  begin
    -- initialize inputs
    TIME_DATA <= ("0000", "0000", "0101", "0101");  -- 0055
    ALARM_DATA <= ("0001", "1001", "0000", "0000"); -- 1900
    SHOW_A <= '0';
    INC_HOUR <= '0';
    INC_MIN <= '0';
    -- sync to -ve edge clock
    wait until CLOCK = '0';
    
    -- load time (00:55)
    SHOW_T <= '1';    
    wait until CLOCK = '0';
    SHOW_T <= '0'; 
    
    -- inc minute for 7 HALF_SECOND cycles
    INC_MIN <= '1';
    for I in 0 to 6 loop
      wait until HALF_SECOND = '0';
    end loop;
    INC_MIN <= '0';
    
    -- load alarm (19:00)
    wait until CLOCK = '0';
    SHOW_A <= '1';
    wait until CLOCK = '0';
    SHOW_A <= '0';
        
    -- inc hour for 7 HALF_SECOND cycles   
    INC_HOUR <= '1';
    for I in 0 to 6 loop
      wait until HALF_SECOND = '0';
    end loop;

    report "simulation over" severity failure;
    wait;
   
  end process BC;

              
end BENCH;
