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

    entity LCD_DRIVER is 
      port(RESET       : in  std_logic;
      CLOCK       : in  std_logic;
      HALF_SECOND : in  std_logic;
      LED_EN      : in std_logic;
      LCD_IN      : in  std_logic_vector(31 downto 0);
      LCD_OUT     : out std_logic_vector(31 downto 0);
      LCD_CLK     : out std_logic;
      LED         : out std_logic);
   end LCD_DRIVER;

    architecture RTL of LCD_DRIVER is
 --As Quartus does not support initialisatiosn via function calls or fucntion calls with
 --more than one return statement, comment out this function. Also ModelSim does not handle this in accordance
 --with the VHDL language reference manual, so it is saftest not to include it.
 --      function FIND_MAX (A: integer; B:integer) return integer is
 --     begin
 --        if A > B then
 --           return A;
 --        else
 --           return B;
 --        end if;
 --     end FIND_MAX;
   
   -- declarations for segment driver
      signal BACKPLANE_CLK : std_logic;
      signal UPDATE_SEGS   : std_logic;
      constant MAXCOUNT: natural := (CLK_DIV_RATIO/2) - 1;
      signal COUNT : natural range 0 to MAXCOUNT;
      signal TMPCLK: std_logic;
   
   -- flash segment
      signal FLASH : std_logic;
   -- intermediate signal to map flash to colon
      signal LCD_INT : std_logic_vector(31 downto 0);
   
   -- declarations for LED driver 
      type LED_DRV_STATE_TYPE is (LED_ON, WAIT_FOR_NEXT_PULSE);
      signal LED_DRV_STATE : LED_DRV_STATE_TYPE;
 --Cannot use a function call to define initial values due to poor support from a couple of tools
 --     constant MAX_CNT_VAL: natural := FIND_MAX(NUM_LED_ON_CYCLES-1, COUNT_LED_OFF-1);
 --Define MAX_CNT_VAL as being equivalent to COUNT_LED_OFF instead as it is likely to be bigger than NUM_LED_ON_CYCLES
 --The simulator will detect this error if it is not, because the LED will not flash.
      constant MAX_CNT_VAL: natural := COUNT_LED_OFF-1;
      signal CYCLE_CNT : natural range 0 to MAX_CNT_VAL;
   
   begin
   
     -- map flash signal into vector in place of colon
      LCD_INT <= LCD_IN(31 downto 16) & FLASH & LCD_IN(14 downto 0);

     -- LCD reference clock
      LCD_CLK <= BACKPLANE_CLK;
   
   SEGDRIVER:
     -- LCD segments driven by clocked signal, reference BACKPLANE_CLK
     -- if segment in phase with BACKPLANE_CLK, segment is unlit
     -- if segment in anti-phase with BACKPLANE_CLK, segment is lit
       process (RESET, CLOCK)
      begin
         if RESET = '0' then
            LCD_OUT <= (others => '0');
         elsif RISING_EDGE(CLOCK) then
         -- segment drive only updated on CLK cycle before backplane clock
         -- inverted so that LCD segment always sees segment drive in phase or
         -- exactly 180 out of phase with lcd backplane clock
            if UPDATE_SEGS = '1' then
               for I in LCD_OUT'range loop
                  LCD_OUT(I) <= LCD_INT(I) xnor BACKPLANE_CLK;
               end loop;  
            end if;
         end if;
      end process;
   
   
   FLASH_SEG:
     -- FLASH_EN enable inverts segment signal on HALF_SECOND for segment flash
     -- used to flash display colon when alarm on
       process (RESET, CLOCK)
      begin
         if RESET = '0' then
            FLASH  <= '1';
         elsif RISING_EDGE(CLOCK) then
            if LCD_IN(15) = '1' then   -- alarm active
               if HALF_SECOND = '1' then
                  FLASH  <= not FLASH;
               end if;
            else
              FLASH  <= '1';  -- show steady when alarm off
            end if;
         end if;
      end process;
   
   CLKGEN:
    -- creates clock and enable signals for driving LCD segments
      process (RESET, CLOCK)
      begin
         if RESET = '0' then
            COUNT <= 0;
            TMPCLK <= '0';
            UPDATE_SEGS <= '0';
            BACKPLANE_CLK <= '0';     
         elsif RISING_EDGE(CLOCK) then
            if (COUNT = MAXCOUNT) then
               UPDATE_SEGS <= '1'; --Synchronise changes in segment drive and backplane clock
               COUNT <= 0;
               TMPCLK <= not TMPCLK;
            else
               COUNT <= COUNT + 1;
               UPDATE_SEGS <= '0'; --default assignment
            end if;
         -- LCD backplane clock to lag update_segs by one cycle 
         -- so segment drive and LCD backplane clocks are synchronised
            BACKPLANE_CLK <= TMPCLK;     
         end if;
      end process;
   
   LED_DRIVER:
     -- flashes LED when LED_ENABLE high
     -- LED flashed to save power
     -- used to indicate alarm "sounding"
       process (RESET, CLOCK)
      begin
         if (RESET = '0') then
            LED <= '0';   -- LED off when reset pressed
            CYCLE_CNT <= 0;
            LED_DRV_STATE <= WAIT_FOR_NEXT_PULSE;
         elsif RISING_EDGE(CLOCK) then
            case LED_DRV_STATE is
               when LED_ON => 
                  LED <= '1';
                  if (CYCLE_CNT = NUM_LED_ON_CYCLES-1) then
                     CYCLE_CNT <= 0;      
                     LED_DRV_STATE <= WAIT_FOR_NEXT_PULSE;  
                  else
                     CYCLE_CNT <= CYCLE_CNT + 1;
                  end if;
                  
               when WAIT_FOR_NEXT_PULSE =>
                 LED <= '0';                                  -- clear LED
                 if (CYCLE_CNT = COUNT_LED_OFF-1) then        -- if off cycle complete...
                    if LED_EN = '1' then                    -- go immediately to LED_ON when LED_EN = '1'
                      CYCLE_CNT <= 0;   
                      LED_DRV_STATE <= LED_ON;
                    end if;
                 elsif (HALF_SECOND = '1') then             -- decrement off cycle counter on half_second
                    CYCLE_CNT <= CYCLE_CNT + 1;
                 end if;
          
            end case;
         end if;
      end process;
   
   end RTL;
