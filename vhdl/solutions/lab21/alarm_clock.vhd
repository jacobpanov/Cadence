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

entity ALARM_CLOCK is
  port (CLOCK, RESET : in  std_logic;
        -- control button inputs
        SHARLM       : in  std_logic;  -- show alarm push button
        MINS         : in  std_logic;  -- minute adjust push button
        HOURS        : in  std_logic;  -- hour adjust push button
        ALRMON       : in  std_logic;  -- alarm on toggle button
      
        -- alarm output
        LED          : out std_logic;  -- alarm indication
      
        -- display outputs
        MS_HOURS     : out std_logic_vector(6 downto 0); -- MS hour digit
        LS_HOURS     : out std_logic_vector(6 downto 0); -- LS hour digit
        COLON        : out std_logic;                    -- colon alarm on indication 
        MS_MINS      : out std_logic_vector(6 downto 0); -- MS minute digit
        LS_MINS      : out std_logic_vector(6 downto 0); -- LS minute digit
        MS_HOURS_DP  : out std_logic;                    -- decimal point 1
        LS_HOURS_DP  : out std_logic;                    -- decimal point 2
        MS_MINS_DP   : out std_logic;                    -- decimal point 3
      
        -- display control signal
       LCD_COM1     : out std_logic;                    --LCD Backplane clock
       LCD_COM2     : out std_logic;                   --LCD Backplane clock
      
       -- additional control outputs
       TH_SMODE     : out std_logic;
       TH_SDI       : out std_logic;
       TH_SCLK      : out std_logic;
       TH_CE        : out std_logic;
       INPUT_HOLD1  : out std_logic;
       INPUT_HOLD2  : out std_logic;
       INPUT_HOLD3  : out std_logic;
      
       JTAG_TDO     : in std_logic;
       PCB_NO_CONNECT : out std_logic);   
   
end ALARM_CLOCK;

architecture RTL of ALARM_CLOCK is
   
  component DEBOUNCE
    port (RESET : in std_logic;
          CLOCK : in std_logic;
          SWITCH_IN : in std_logic;
          DEB_SWITCH: out std_logic);
  end component;
  
  component DEBOUNCE_TOGGLE
    port (RESET : in std_logic;
          CLOCK : in std_logic;
          SWITCH_IN : in std_logic;
          TOG_SWITCH: out std_logic);
  end component;
   
  component CONTROL 
    port (CLOCK, RESET : in  std_logic;
          AL           : in  std_logic;
          MN           : in  std_logic;
          HR           : in  std_logic;
          SHOW_A       : out std_logic;
          LOAD_A       : out std_logic;
          SHOW_T       : out std_logic;
          LOAD_T       : out std_logic;
          INC_HOUR     : out std_logic;
          INC_MIN      : out std_logic);
  end component;
   
  component PULSEGEN 
    port (CLOCK, RESET : in  std_logic;
          HALF_SECOND  : out std_logic;  
          ONE_MINUTE   : out std_logic);  
  end component;
   
  component TIME_SET 
    port (CLOCK, RESET : in  std_logic;
          HALF_SECOND  : in  std_logic;
          TIME_DATA    : in  DISPLAY_4;
          ALARM_DATA   : in  DISPLAY_4;
          SHOW_A       : in  std_logic;
          SHOW_T       : in  std_logic;
          INC_HOUR     : in  std_logic;
          INC_MIN      : in  std_logic;
          SET_DATA     : out DISPLAY_4);
  end component;
   
  component TIME_COUNT
    port(SET_DATA            : in DISPLAY_4;
         LOAD_T              : in std_logic;
         CLOCK, ONE_MINUTE, 
         RESET               : in std_logic;
         TIME_DATA           : out DISPLAY_4);
  end component;
   
  component ALARM_REG4
    port (CLOCK, RESET : in  std_logic;
          SET_DATA     : in  DISPLAY_4;
          LOAD_A       : in  std_logic;
          ALARM_DATA   : out DISPLAY_4);
  end component;
   
  component DDRV4
    port (TIME_DATA    : in  DISPLAY_4;
          ALARM_DATA   : in  DISPLAY_4;
          SET_DATA     : in  DISPLAY_4;
          SHOW_T       : in  std_logic;
          ALARM_ON     : in  std_logic;
          SHOW_A       : in  std_logic;
          SOUND_A      : out std_logic;
          DISP_7SEG    : out DISP7_T);
  end component;
   
  component LCD_DRIVER 
    port(RESET       : in  std_logic;
         CLOCK       : in  std_logic;
         HALF_SECOND : in  std_logic;
         LED_EN      : in std_logic;
         LCD_IN      : in  std_logic_vector(31 downto 0);
         LCD_OUT     : out std_logic_vector(31 downto 0);
         LCD_CLK     : out std_logic;
         LED         : out std_logic);
  end component;
   
  -- arrays for debouncing inputs
  signal SW_IN, SW_OUT : std_logic_vector(3 downto 0); 
   
  -- BCD time data signals
  signal TIME_DATA, ALARM_DATA, SET_DATA : DISPLAY_4;
   
  -- controller signals
  signal AL, MN, HR, ALARM_ON : std_logic;
  signal SHOW_A, LOAD_A, SHOW_T, LOAD_T, INC_HOUR, INC_MIN : std_logic;
  signal SOUND_A : std_logic;
   
  -- internal timing signals
  signal HALF_SECOND, ONE_MINUTE : std_logic;
   
  -- output signals
  signal DISP_7SEG : DISP7_T;
  -- extra LCD display segments
  signal COLON_AL, MSHR_DP, LSHR_DP, MSMN_DP : std_logic;
   
  -- LCD reference clock intermediate signal
  signal LCD_CLK : std_logic;
   
  -- vectors for all segments
  -- 4X7 segment digits + colon & 3 decimal points
  signal LCD_IN  : std_logic_vector(31 downto 0);
  signal LCD_OUT : std_logic_vector(31 downto 0);
   
  constant GND : std_logic := '0';
  constant VCC : std_logic := '1';
   
begin  
   
  SW_IN <= (SHARLM, MINS, HOURS, ALRMON);   
   
  DB_GEN: 
  for I in 0 to 3 generate
      
    DB_TOG:
    if I = 0 generate
    
      DBTOG: DEBOUNCE_TOGGLE
        port map (CLOCK => CLOCK,
                  RESET => RESET,
                  SWITCH_IN => SW_IN(I),
                  TOG_SWITCH => SW_OUT(I));
                  
    end generate DB_TOG;
      
    DB_ONLY:  
    if I > 0 generate
    
      DB: DEBOUNCE
        port map (CLOCK => CLOCK,
                  RESET => RESET,
                  SWITCH_IN => SW_IN(I),
                  DEB_SWITCH => SW_OUT(I));
                  
    end generate DB_ONLY;

      
  end generate DB_GEN;
   
  (AL, MN, HR, ALARM_ON) <= SW_OUT;
      
  AC: CONTROL 
    port map (CLOCK => CLOCK,
              RESET => RESET,
              AL => AL,
              MN => MN,
              HR => HR,
              SHOW_A => SHOW_A,
              LOAD_A => LOAD_A,
              SHOW_T => SHOW_T,
              LOAD_T =>LOAD_T,
              INC_HOUR => INC_HOUR,
              INC_MIN => INC_MIN);
   
  PG: PULSEGEN 
    port map (CLOCK => CLOCK,
              RESET => RESET,
              HALF_SECOND => HALF_SECOND,  
              ONE_MINUTE => ONE_MINUTE);
   
  TS: TIME_SET 
    port map (CLOCK => CLOCK,
              RESET => RESET,
              HALF_SECOND => HALF_SECOND,
              TIME_DATA => TIME_DATA,
              ALARM_DATA => ALARM_DATA,
              SHOW_A => SHOW_A,
              SHOW_T => SHOW_T,
              INC_HOUR => INC_HOUR,
              INC_MIN => INC_MIN,
              SET_DATA => SET_DATA);
   
  TC: TIME_COUNT
    port map (SET_DATA => SET_DATA,
              LOAD_T => LOAD_T,
              CLOCK => CLOCK,
              ONE_MINUTE => ONE_MINUTE,
              RESET => RESET,
              TIME_DATA => TIME_DATA);
   
  ALREG: ALARM_REG4
    port map (CLOCK => CLOCK,
              RESET => RESET,
              SET_DATA => SET_DATA,
              LOAD_A => LOAD_A,
              ALARM_DATA => ALARM_DATA);
   
  DRV: DDRV4
     port map (TIME_DATA => TIME_DATA, 
               ALARM_DATA => ALARM_DATA,
               SET_DATA => SET_DATA,
               SHOW_T => SHOW_T,
               ALARM_ON => ALARM_ON,
               SHOW_A => SHOW_A,
               SOUND_A => SOUND_A,
               DISP_7SEG => DISP_7SEG);
   
 -- DO NOT EDIT BELOW THIS LINE
   
 -- clear decimal points - not used for alarm clock
 MSHR_DP <= GND;
 LSHR_DP <= GND;
 MSMN_DP <= GND;
   
 -- assemble LCD vector for input to driver
 -- ALARM_ON mapped to colon display segment
 LCD_IN <= (DISP_7SEG(3) & MSHR_DP & DISP_7SEG(2) & LSHR_DP & ALARM_ON &
            DISP_7SEG(1) & MSMN_DP & DISP_7SEG(0));
   
 LCDRV: LCD_DRIVER
   port map (CLOCK => CLOCK,
             RESET => RESET,
             HALF_SECOND => HALF_SECOND,
             LED_EN => SOUND_A,
             LCD_IN => LCD_IN,
             LCD_OUT => LCD_OUT,
             LCD_CLK => LCD_CLK,
             LED => LED);
   
 -- disassemble LCD vector for output
 MS_HOURS    <= LCD_OUT(31 downto 25);
 MS_HOURS_DP <= LCD_OUT(24);
 LS_HOURS    <= LCD_OUT(23 downto 17);
 LS_HOURS_DP <= LCD_OUT(16);
 COLON       <= LCD_OUT(15);
 MS_MINS     <= LCD_OUT(14 downto 8);
 MS_MINS_DP  <= LCD_OUT(7);
 LS_MINS     <= LCD_OUT(6 downto 0);
   
 -- LCD reference clock
 LCD_COM1 <= LCD_CLK;
 LCD_COM2 <= LCD_CLK;
   
 -- additional control outputs
 -- refer to user guide
 INPUT_HOLD1 <= GND; --Need to drive out a GND to hold an unused dedicated CLK/Dedicated input net
 INPUT_HOLD2 <= GND; --Need to drive out a GND to hold an unused dedicated CLK/Dedicated input net
 INPUT_HOLD3 <= GND; --Need to drive out a GND to hold an unused dedicated CLK/Decicated input net
   
 PCB_NO_CONNECT  <= JTAG_TDO; --Need TDO as an input so we can program a pullup for when JTAG not in use.
                              --Need to assign to a no connect pin to stop it getting optimised away.
   
  -- thermometer control outputs
  TH_SDI      <= GND; --DS1722 is in Sleep mode, so need to hold siganl at some level
  TH_SCLK     <= GND; --DS1722 is in Sleep mode, so need to hold siganl at some level
  TH_SMODE    <= VCC; --Hold DS1722 in SPI mode
  TH_CE       <= GND; --Keep DS1722 disabled
   
end RTL;
