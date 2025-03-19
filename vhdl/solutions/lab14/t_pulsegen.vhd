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
    port( CLOCK, RESET : in  std_logic;    -- control
        HALF_SECOND  : out std_logic;    -- 1/2 sec timed pulse
        ONE_MINUTE   : out std_logic
          -- add port list
          );   
  end component;

   signal CLOCK          : std_logic := '0' ; -- give intial value for clock
   signal RESET          : std_logic;
   signal HALF_SECOND, ONE_MINUTE : std_logic;
 
   constant PERIOD       : time := 10 ns;
	signal HS_count : integer := 0;

begin

  UUT: PULSEGEN
      port map (
	CLOCK, RESET ,HALF_SECOND , ONE_MINUTE   
                ); 
        
   ---------------------------------------------
   -- infinite clock generator 
   ---------------------------------------------
      CLOCK <= not CLOCK after PERIOD/2;  -- complete clock generator
            
   --------------------------------------------------
   -- Stimulus   
   -------------------------------------------------
   RST_GEN : process
   begin
        -- add stimulus
    RESET <= '1';
      wait for 2 * PERIOD;
      RESET <= '0';
      wait for PERIOD;
      RESET <= '1';
      
--report "Simulation over"
      wait;
 
  end process RST_GEN;

HS_TRACK: process
begin
 	wait until HALF_SECOND = '1';
	if ONE_MINUTE = '1' then
		HS_COUNT <= 0;
	else
	HS_COUNT <= HS_COUNT + 1;
	end if;
end process HS_TRACK;   

end TEST;
