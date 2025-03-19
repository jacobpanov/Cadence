-----------------------------------------------------------------------
-- 
-- Original Code Copyright (c)2003 by Esperan (www.esperan.com)
--  World-wide leaders in independent, 
--  methodology-based training for electronic design
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

package P_DISP4 is

  procedure DISP4(signal MS_HR, LS_HR, MS_MIN, LS_MIN : std_logic_vector(6 downto 0));

end P_DISP4;


use std.textio.all;
package body P_DISP4 is

----------------------------------------------------------------
-- This is the procedure that outputs a seven segment display
-- to a text file.
--
-- Display (6 downto 0) looks like this:
--
--             111111111122222222223333333333
--   0123456789012345678901234567890123456789
--  1   #0##     ####     ####     ####
--  2  #    #   #    #   #    #   #    #
--  3  5    1   #    #   #    #   #    #
--  4  #    #   #    #   #    #   #    #
--  5  #    #   #    #   #    #   #    #
--  6   #6##     ####     ####     ####
--  7  #    #   #    #   #    #   #    #
--  8  4    2   #    #   #    #   #    #
--  9  #    #   #    #   #    #   #    #
-- 10  #    #   #    #   #    #   #    #
-- 11   #3##     ####     ####     ####
--
--     <-- 9 -->
----------------------------------------------------------------

procedure DISP4(signal MS_HR, LS_HR, MS_MIN, LS_MIN: std_logic_vector(6 downto 0)) is
   file OUTFILE : text open write_mode is "clock.txt";
   --file OUTFILE : text IS out "clock.txt";
   variable L : line;
   constant SEG_CHAR : character := '#';
   constant SEG : string(4 downto 1) := (others => SEG_CHAR);
   type T_DIGIT_ARRAY is array (1 to 11) of string (1 to 36);
   -- DIGIT ARRAY (Y)(X)
   variable DIGIT_ARRAY : T_DIGIT_ARRAY := (others=>(others=> ' '));
   type T_CLOCK_TIME is array (3 downto 0) of std_logic_vector (6 downto 0);
   variable DISPLAY: T_CLOCK_TIME:= (MS_HR, LS_HR, MS_MIN, LS_MIN);
   variable XOFF : integer;
begin

   DIGIT_ARRAY := (others=>(others=> ' '));


   for I in DISPLAY'low to DISPLAY'high loop -- this should be 4!

      XOFF := (DISPLAY'high - I - DISPLAY'low) * 9;

      -- Bit 0 
      if DISPLAY(I)(DISPLAY(I)'LOW + 0) = '1' then
         DIGIT_ARRAY(1)(XOFF+3 to XOFF+6) := SEG;
      end if;
   

      -- Bit 1 
      if DISPLAY(I)(DISPLAY(I)'LOW + 1) = '1' then
         -- DIGIT_ARRAY(2 to 5)(7):= SEG;
         DIGIT_ARRAY(2)(XOFF+7):= SEG_CHAR;
         DIGIT_ARRAY(3)(XOFF+7):= SEG_CHAR;
         DIGIT_ARRAY(4)(XOFF+7):= SEG_CHAR;
         DIGIT_ARRAY(5)(XOFF+7):= SEG_CHAR;
      end if;
   
      -- Bit 2 
      if DISPLAY(I)(DISPLAY(I)'LOW + 2) = '1' then
         -- DIGIT_ARRAY(7 to 10)(7) := SEG;
         DIGIT_ARRAY(7)(XOFF+7) := SEG_CHAR;
         DIGIT_ARRAY(8)(XOFF+7) := SEG_CHAR;
         DIGIT_ARRAY(9)(XOFF+7) := SEG_CHAR;
         DIGIT_ARRAY(10)(XOFF+7) := SEG_CHAR;
      end if;
   
      -- Bit 3 
      if DISPLAY(I)(DISPLAY(I)'LOW + 3) = '1' then
         DIGIT_ARRAY(11)(XOFF+3 to XOFF+6) := SEG;
      end if;
   
      -- Bit 4 
      if DISPLAY(I)(DISPLAY(I)'LOW + 4) = '1' then
         -- DIGIT_ARRAY(7 to 10)(2) := SEG;
         DIGIT_ARRAY(7)(XOFF+2) := SEG_CHAR;
         DIGIT_ARRAY(8)(XOFF+2) := SEG_CHAR;
         DIGIT_ARRAY(9)(XOFF+2) := SEG_CHAR;
         DIGIT_ARRAY(10)(XOFF+2) := SEG_CHAR;
      end if;
   
      -- Bit 5 
      if DISPLAY(I)(DISPLAY(I)'LOW + 5) = '1' then
         -- DIGIT_ARRAY(2 to 5)(2):= SEG;
         DIGIT_ARRAY(2)(XOFF+2):= SEG_CHAR;
         DIGIT_ARRAY(3)(XOFF+2):= SEG_CHAR;
         DIGIT_ARRAY(4)(XOFF+2):= SEG_CHAR;
         DIGIT_ARRAY(5)(XOFF+2):= SEG_CHAR;
      end if;
   
-- Bit 6 
      if DISPLAY(I)(DISPLAY(I)'LOW + 6) = '1' then
         DIGIT_ARRAY(6)(XOFF+3 to XOFF+6) := SEG;
      end if;

   end loop;
   
      -- now write it out to the file...
  for I in DIGIT_ARRAY'range loop
     write(L, DIGIT_ARRAY(I));
     writeline(OUTFILE, L);
  end loop; 
   
end DISP4;
                     
end P_DISP4;
