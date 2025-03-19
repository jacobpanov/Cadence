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

entity BCD2_COUNT is
  generic (MSMAX, LSMAX : integer);
  port (CLOCK, RESET : in  std_logic;
        LOAD_EN      : in  std_logic;
        LOAD_DATA    : in  DISPLAY_2;
        COUNT_EN     : in  std_logic;
        OP_DATA      : out DISPLAY_2);
end BCD2_COUNT;

architecture RTL of BCD2_COUNT is

  constant NINE : unsigned(3 downto 0) := "1001";
  signal MS, LS: unsigned(3 downto 0);

begin

  BC: process (CLOCK, RESET)
  begin
    if RESET = '0' then
      MS <= "0000";
      LS <= "0000";
    elsif CLOCK'event and CLOCK='1' then
      if LOAD_EN = '1' then
        LS <= LOAD_DATA(0);
        MS <= LOAD_DATA(1);
      elsif COUNT_EN = '1' then

        if MS < MSMAX then
          if LS < NINE then
            LS <= LS + 1;
          else               -- LS = NINE
            LS <= "0000";
            MS <= MS + 1;
          end if;
        else                 -- MS = MSMAX
          if LS < LSMAX then
            LS <= LS + 1;
          else               -- LS = LSMAX, MS = MSMAX
            LS <= "0000";
            MS <= "0000";
          end if;          
        end if;

      end if;  -- count_en
    end if;  -- clk
  end process BC;

  OP_DATA <= (MS, LS);
              
end RTL;
