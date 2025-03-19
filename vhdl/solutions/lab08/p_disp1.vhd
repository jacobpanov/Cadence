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

use std.textio.all;
use ieee.std_logic_textio.all;
package P_DISP1 is
   procedure DISP1(signal DISPLAY:std_logic_vector(6 downto 0));
end P_DISP1;

package body P_DISP1 is
----------------------------------------------------------------
-- This is the procedure that outputs a seven segment display
-- to a text file.
-- Display (6 downto 0) looks like this:
--
--   0123456789
--  1   #0## 
--  2  #    #
--  3  5    1
--  4  #    #
--  5  #    #
--  6   #6## 
--  7  #    #
--  8  4    2
--  9  #    #
-- 10  #    #
-- 11   #3## 
--
----------------------------------------------------------------
procedure DISP1(signal DISPLAY: std_logic_vector(6 downto 0)) is
   variable L : line;
   constant SEG_CHAR : character := '#';
   constant SEG : string(4 downto 1) := (others => SEG_CHAR);
   type T_DIGIT_ARRAY is array (1 to 11) of string (1 to 9);
   -- DIGIT ARRAY (Y)(X)
   variable DIGIT_ARRAY : T_DIGIT_ARRAY := (others=>(others=> ' '));
--   file OUTFILE : text open WRITE_MODE IS "clock.txt";
    file OUTFILE : text  IS out  "clock.txt";
begin

   DIGIT_ARRAY := (others=>(others=> ' '));

-- Bit 0 
   if DISPLAY(DISPLAY'LOW + 0) = '1' then
      DIGIT_ARRAY(1)(3 to 6) := SEG;
   end if;

   -- Bit 1 
   if DISPLAY(DISPLAY'LOW + 1) = '1' then
      -- DIGIT_ARRAY(2 to 5)(7):= SEG;
      DIGIT_ARRAY(2)(7):= SEG_CHAR;
      DIGIT_ARRAY(3)(7):= SEG_CHAR;
      DIGIT_ARRAY(4)(7):= SEG_CHAR;
      DIGIT_ARRAY(5)(7):= SEG_CHAR;
   end if;

   -- Bit 2 
   if DISPLAY(DISPLAY'LOW + 2) = '1' then
      -- DIGIT_ARRAY(7 to 10)(7) := SEG;
      DIGIT_ARRAY(7)(7) := SEG_CHAR;
      DIGIT_ARRAY(8)(7) := SEG_CHAR;
      DIGIT_ARRAY(9)(7) := SEG_CHAR;
      DIGIT_ARRAY(10)(7) := SEG_CHAR;
   end if;

   -- Bit 3 
   if DISPLAY(DISPLAY'LOW + 3) = '1' then
      DIGIT_ARRAY(11)(3 to 6) := SEG;
   end if;

   -- Bit 4 
   if DISPLAY(DISPLAY'LOW + 4) = '1' then
      -- DIGIT_ARRAY(7 to 10)(2) := SEG;
      DIGIT_ARRAY(7)(2) := SEG_CHAR;
      DIGIT_ARRAY(8)(2) := SEG_CHAR;
      DIGIT_ARRAY(9)(2) := SEG_CHAR;
      DIGIT_ARRAY(10)(2) := SEG_CHAR;
   end if;

   -- Bit 5 
   if DISPLAY(DISPLAY'LOW + 5) = '1' then
      -- DIGIT_ARRAY(2 to 5)(2):= SEG;
      DIGIT_ARRAY(2)(2):= SEG_CHAR;
      DIGIT_ARRAY(3)(2):= SEG_CHAR;
      DIGIT_ARRAY(4)(2):= SEG_CHAR;
      DIGIT_ARRAY(5)(2):= SEG_CHAR;
   end if;

-- Bit 6 
   if DISPLAY(DISPLAY'LOW + 6) = '1' then
      DIGIT_ARRAY(6)(3 to 6) := SEG;
   end if;

   -- now write it out to the file...
   for I in DIGIT_ARRAY'range loop
      write(L, DIGIT_ARRAY(I));
      writeline(OUTFILE, L);
   end loop; 

end DISP1;


end P_DISP1;
