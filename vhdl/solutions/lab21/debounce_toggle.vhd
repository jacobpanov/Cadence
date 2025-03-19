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

--The incoming switch will be logic 0 when the switch is pressed
--The debounced signal will be logic 1 when the switch is pressed.

library ieee;
use ieee.std_logic_1164.all;
use work.alarm_types.all;

entity DEBOUNCE_TOGGLE is
  port (RESET      : in std_logic;
        CLOCK      : in std_logic;
        SWITCH_IN  : in std_logic;
        TOG_SWITCH : out std_logic);
end DEBOUNCE_TOGGLE;

architecture RTL of DEBOUNCE_TOGGLE is
    
  type DEBOUNCE_STATE_TYPE is (WAIT_FOR_PRESS, PRESSED, WAIT_FOR_RELEASE, RELEASED);
  signal DEBOUNCE_STATE : DEBOUNCE_STATE_TYPE;
  signal DEB_CYCLE_CNT : natural range 0 to NUM_DEBOUNCE_CYCLES-1;
  signal SW_IN_D1, SW_IN_D2: std_logic;    --Double buffer switch input to minimises risk of Metastability
  
  -- signals for toggle
  signal DEB_SWITCH, TOG, SIG_OUT_I : std_logic;
   
begin

  BUF2:
  process (RESET, CLOCK)
  begin
    if (RESET = '0') then
      SW_IN_D1 <= '1';
      SW_IN_D2 <= '1';
    elsif RISING_EDGE(CLOCK) then
      SW_IN_D1 <= SWITCH_IN;
      SW_IN_D2 <= SW_IN_D1;
    end if;
  end process BUF2;   
   
  SWITCH_DEBOUNCE:
  process (RESET, CLOCK)
    begin
      if (RESET = '0') then
        DEB_SWITCH <= '0';
        DEB_CYCLE_CNT <= 0;
        DEBOUNCE_STATE <= WAIT_FOR_PRESS;
         
      elsif RISING_EDGE(CLOCK) then

        case  DEBOUNCE_STATE is

          when WAIT_FOR_PRESS =>
            if (SW_IN_D2 = '0') then               -- if switch has been pressed
               DEB_CYCLE_CNT <= 0;                 -- reset the counter for use in the next state
               DEBOUNCE_STATE <= PRESSED;
            end if;   


          when PRESSED =>
            DEB_SWITCH <= '1';                     -- output indicates button pressed                               
            if (DEB_CYCLE_CNT = NUM_DEBOUNCE_CYCLES-1) then
              DEBOUNCE_STATE <= WAIT_FOR_RELEASE;  -- count cycles until debounce period is over
            else
              DEB_CYCLE_CNT <= DEB_CYCLE_CNT + 1;  --Increment debounce cycle counter
            end if;
              
            
          when WAIT_FOR_RELEASE =>
            if (SW_IN_D2 = '1') then               -- if switch has been released
               DEB_CYCLE_CNT <= 0;                 -- reset the counter for use in the next state
               DEBOUNCE_STATE <= RELEASED;
            end if;

          when RELEASED =>
            DEB_SWITCH <= '0';                     -- output indicates button released                               
            if (DEB_CYCLE_CNT = NUM_DEBOUNCE_CYCLES-1) then
              DEBOUNCE_STATE <= WAIT_FOR_PRESS;    -- count cycles until debounce period is over
            else
              DEB_CYCLE_CNT <= DEB_CYCLE_CNT + 1;  --Increment debounce cycle counter
            end if;
            
        end case;
         
      end if;
    end process;
   
  TOGGLE: 
  process (CLOCK, RESET)
  begin
    if RESET = '0' then
      TOG <= '1';
      SIG_OUT_I <= '0';
    elsif CLOCK'event and CLOCK='1' then
      if DEB_SWITCH = '1' then
        if TOG = '1' then
          SIG_OUT_I <= not SIG_OUT_I;
          TOG <= '0';
        end if;
      else
        TOG <= '1';
      end if;
    end if;
  end process TOGGLE;
   
  TOG_SWITCH <= SIG_OUT_I;

end RTL;
