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

entity T_PULSEGEN is
end T_PULSEGEN;

architecture TEST of T_PULSEGEN is

  component PULSEGEN
    port (
          -- add port list
          );   
  end component;

   signal CLOCK          : std_logic -- give intial value for clock
   signal RESET          : std_logic;
   signal HALF_SECOND, ONE_MINUTE : std_logic;
 
   constant PERIOD       : time := 10 ns;

begin

  UUT: PULSEGEN
      port map ( -- add port map
                ); 
        
   ---------------------------------------------
   -- infinite clock generator 
   ---------------------------------------------
      CLOCK <= ????? after PERIOD/2;  -- complete clock generator
            
   --------------------------------------------------
   -- Stimulus   
   -------------------------------------------------
   RST_GEN : process
   begin
        -- add stimulus
  end process RST_GEN;
   
end TEST;
