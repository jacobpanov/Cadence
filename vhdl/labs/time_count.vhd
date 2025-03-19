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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;   

use work.ALARM_TYPES.all;

entity TIME_COUNT is
   port( SET_DATA            : in DISPLAY_4;
         LOAD_T              : in std_logic;
         CLOCK, ONE_MINUTE, 
         RESET               : in std_logic;
         TIME_DATA           : out DISPLAY_4);
end TIME_COUNT;

architecture RTL of TIME_COUNT is
   
   constant ZERO : unsigned(3 downto 0) := "0000";

   -- Declaration of intermediate signal required...
   -- use type unsigned 

begin

   -- Put your algorithm here!!

   -- remember, you can convert between unsigned signals 
   -- and std_logic_vector ports as follows:-
   --   ASIGNAL <= unsigned(APORT);
   --   APORT   <= std_logic_vector(ASIGNAL);
   -- Otherwise refer to your workbooks for further guidance
               
end RTL ;
