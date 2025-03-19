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

library ieee;
use ieee.std_logic_1164.all;
use work.alarm_types.all;

entity TB_DEBOUNCE is
end TB_DEBOUNCE;

architecture TEST of TB_DEBOUNCE is

  -- ADD COMPONENT DECLARATION
  
  signal CLOCK, RESET : std_logic := '0';
  signal SWITCH_IN, SWITCH_OUT : std_logic;
  signal TRANSITION : std_logic := '0';
  signal TOGGLE, ENABLE : std_logic := '0';
   
begin

  --The incoming switch will be logic 0 when the switch is pressed
  --The debounced signal will be logic 1 when the switch is pressed.
  
  -- ADD COMPONENT INSTANTIATION

  CLOCK <= not CLOCK after 10 ns;
  RESET <= '1', '0' after 5 ns, '1' after 15 ns;
  
  -- Transition is a rapidly toggling signal
  -- Models ocsillation of a bouncing switch input 
  TRANSITION <= not TRANSITION after 7.5 ns;

  -- Enable used to mux switch_in between toggle (switched value)
  -- and transition (bouncing input)
  SWITCH_IN <= TOGGLE when ENABLE = '1' else TRANSITION;
  
  STIM: process
    -- input switch is active low
  begin
    ENABLE <= '1';             -- switch_in = toggle
    TOGGLE <= '1';             -- un-pressed key
    wait for 20 ns;            -- wait until reset complete
    
    ENABLE <= '0';             -- key press: switch_in = transition
    for I in 1 to NUM_DEBOUNCE_CYCLES loop
      wait until CLOCK = '1';  -- count max number of debounce cycles
    end loop;
    ENABLE <= '1';             -- switch_in = toggle
    TOGGLE <= '0';             -- press button steady state
    
    wait for 200 ns;
    ENABLE <= '0';             -- key release: switch_in = transition
    for I in 1 to NUM_DEBOUNCE_CYCLES loop
      wait until CLOCK = '1';  -- count max number of debounce cycles
    end loop;
    ENABLE <= '1';              -- switch_in = toggle
    TOGGLE <= '1';              --  release button steady state
    for I in 0 to NUM_DEBOUNCE_CYCLES loop
      wait until CLOCK = '1';
    end loop; 
       
    report "simulation over" severity failure;
    
    wait;
  end process STIM;   
    

end TEST;
