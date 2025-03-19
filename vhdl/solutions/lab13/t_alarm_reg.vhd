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

Library IEEE;
use IEEE.Std_Logic_1164.all; 

entity T_ALREG is
end T_ALREG;

architecture TEST of T_ALREG is

   component ALARM_REG
      port (CLOCK, RESET : in  std_logic;
            SET_DATA     : in  std_logic_vector (3 downto 0);
            LOAD_A       : in  std_logic;
            ALARM_DATA   : out std_logic_vector (3 downto 0));
   end component;

   signal SET_DATA       : std_logic_vector (3 downto 0);
   signal LOAD_A         : std_logic;
   signal ALARM_DATA     : std_logic_vector (3 downto 0);
   signal CLOCK          : std_logic := '0';
   signal RESET          : std_logic;
 
   constant PERIOD       : time := 10 ns;

begin

   ---------------------------------------------
   -- instantiate UUT
   ---------------------------------------------
   uut : ALARM_REG 
         port map (CLOCK, RESET, 
                   SET_DATA, LOAD_A, ALARM_DATA);

   ---------------------------------------------
   -- infinite clock generator 
   ---------------------------------------------
      CLOCK <= not CLOCK after PERIOD/2;
            
   --------------------------------------------------
   -- Stimulus   
   -------------------------------------------------
   STIMULUS : process
   begin
      -- pulse reset
      SET_DATA <= "0101";
      LOAD_A <= '0';
      RESET <= '1';
      wait for 2 * PERIOD;
      RESET <= '0';
      wait for PERIOD;
      RESET <= '1';
      
      LOAD_A <= '1';
      wait for PERIOD;
     
      LOAD_A <= '0';
      SET_DATA <= "1111";
      wait for PERIOD;

      LOAD_A <= '1';
      SET_DATA <= "0000";
      wait for PERIOD;
      
      LOAD_A <= '0';
      SET_DATA <= "1010";
      wait for PERIOD;

      report "Simulation over"
        severity failure;
        
      wait;
     
   end process STIMULUS;

end TEST;

