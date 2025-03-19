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

use work.ALARM_TYPES.all;
use work.P_DISP4.all;
   
use std.textio.all;

entity TB_ALARM_CLOCK is
end TB_ALARM_CLOCK;

architecture BENCH of TB_ALARM_CLOCK is
   
   component ALARM_CLOCK
     port ( 
           -- control inputs
           CLOCK, RESET : in  std_logic;
           SHARLM       : in  std_logic;  
           MINS         : in  std_logic; 
           HOURS        : in  std_logic; 
           ALRMON       : in  std_logic; 
           -- alarm output
           LED          : out std_logic;  
           -- LCD display outputs 
           MS_HOURS     : out std_logic_vector(6 downto 0);
           LS_HOURS     : out std_logic_vector(6 downto 0); 
           COLON        : out std_logic;        
           MS_MINS      : out std_logic_vector(6 downto 0);
           LS_MINS      : out std_logic_vector(6 downto 0); 
           MS_HOURS_DP  : out std_logic;     
           LS_HOURS_DP  : out std_logic;    
           MS_MINS_DP   : out std_logic;     
           -- LCD reference clock
           LCD_COM1     : out std_logic;    
           LCD_COM2     : out std_logic;      
           -- thermometer control outputs (unused in Alarm Clock)
           TH_SMODE     : out std_logic;
           TH_SDI       : out std_logic;
           TH_SCLK      : out std_logic;
           TH_CE        : out std_logic;
           INPUT_HOLD1  : out std_logic;
           INPUT_HOLD2  : out std_logic;
           INPUT_HOLD3  : out std_logic;
           -- optimization control
           JTAG_TDO     : in std_logic;
           PCB_NO_CONNECT : out std_logic);   
   
   end component;
   
   -- Constant for the clock period we will use      
   constant PERIOD : time := 10 ns;
   constant HALFPERIOD : time := PERIOD/2;
      
   -- input control signals
   signal CLOCK, RESET : std_logic := '1';
   
   -- push button inputs
   signal SHARLM, MINS, HOURS, ALRMON : std_logic := '1';
   
   -- LCD 7 segment digits
   signal MS_HOURS, LS_HOURS, MS_MINS, LS_MINS : std_logic_vector(6 downto 0);
   -- BCD equivalents
   signal DISPLAY_MS_HR, DISPLAY_LS_HR, DISPLAY_MS_MN, DISPLAY_LS_MN : std_logic_vector(3 downto 0);
   
   -- other LCD outputs
   signal COLON, MS_HOURS_DP, LS_HOURS_DP, MS_MINS_DP : std_logic;
   -- alarm LED
   signal LED : std_logic;
   
   -- control outputs
   signal TH_SMODE, TH_SDI, TH_SCLK, TH_CE : std_logic;
   signal INPUT_HOLD1, INPUT_HOLD2, INPUT_HOLD3 : std_logic;
   signal LCD_COM1, LCD_COM2, JTAG_TDO, PCB_NO_CONNECT : std_logic; 
   
   -- testbench signals
   signal SIM_OVER : boolean := false;
   signal DISPLCD, DISPBIN  : std_logic_vector(27 downto 0);
   signal DISP7SEG : DISP7_T;
   signal DISPBCD  : DISPLAY_4;
   
   constant GND : std_logic := '0';
   constant VCC : std_logic := '1';
   
begin
   
   UUT: ALARM_CLOCK 
          port map (CLOCK, RESET, SHARLM, MINS, HOURS, ALRMON, LED, 
                    MS_HOURS, LS_HOURS, COLON, MS_MINS, LS_MINS, MS_HOURS_DP, LS_HOURS_DP, MS_MINS_DP,    
                    LCD_COM1, LCD_COM2,    
                    TH_SMODE, TH_SDI, TH_SCLK, TH_CE,
                    INPUT_HOLD1, INPUT_HOLD2, INPUT_HOLD3,
                    JTAG_TDO, PCB_NO_CONNECT);
   
    -- clock generator
   CLOCK <= not CLOCK after HALFPERIOD when SIM_OVER = false else '0';
    -- reset generator
   RESET <= '1', '0' after HALFPERIOD, '1' after (HALFPERIOD + PERIOD);
   
   
   -- decode and translate LCD driver outputs
   -- concatenate outputs
   DISPLCD <= (MS_HOURS & LS_HOURS & MS_MINS & LS_MINS);
   
   -- extract Seven Segment encoding
   SEGDECODER:
     -- LCD segments driven by clocked signal, reference BACKPLANE_CLK
     -- if segment in phase with BACKPLANE_CLK, segment is unlit
     -- if segment in anti-phase with BACKPLANE_CLK, segment is lit
   process (LCD_COM1)
   begin
     for I in DISPLCD'range loop
       DISPBIN(I) <= DISPLCD(I) xor LCD_COM1;
     end loop;  
   end process;
   
   -- build 4 element array of seven segment encodingd   
   DISP7SEG <= (DISPBIN(27 downto 21), DISPBIN(20 downto 14), DISPBIN(13 downto 7), DISPBIN(6 downto 0));
   
   DISP4(DISP7SEG(3), DISP7SEG(2), DISP7SEG(1), DISP7SEG(0));
   
   -- convert seven segment to BCD
   SEVENSEG2BCD: 
   for I in 0 to 3 generate
   
     with DISP7SEG(I) select
       DISPBCD(I) <=  "0000"  when ZERO_SEG,
                      "0001"  when ONE_SEG,
                      "0010"  when TWO_SEG,
                      "0011"  when THREE_SEG,
                      "0100"  when FOUR_SEG,
                      "0101"  when FIVE_SEG,
                      "0110"  when SIX_SEG,
                      "0111"  when SEVEN_SEG,
                      "1000"  when EIGHT_SEG,
                      "1001"  when NINE_SEG,
                      "1111"  when OTHERS;
   
   end generate SEVENSEG2BCD;
   
    -- expand BCD array for readability
    DISPLAY_MS_HR  <=  std_logic_vector(DISPBCD(3));
    DISPLAY_LS_HR  <=  std_logic_vector(DISPBCD(2));
    DISPLAY_MS_MN <=  std_logic_vector(DISPBCD(1));
    DISPLAY_LS_MN <=  std_logic_vector(DISPBCD(0));       
   
    -- Conectivity checks
    -- DO NOT EDIT BELOW THIS LINE
   
   CONCHK: 
   process
   begin
      wait for 2 ns;
   
    --  control outputs
      assert INPUT_HOLD1 <= GND
      report "CONNECTIVITY ERROR: input_hold1 not grounded"
      severity error;
      assert INPUT_HOLD2 <= GND
      report "CONNECTIVITY ERROR: input_hold2 not grounded"
      severity error;
      assert INPUT_HOLD3 <= GND
      report "CONNECTIVITY ERROR: input_hold3 not grounded"
      severity error;
   
     -- thermometer control outputs
      assert TH_SDI = GND
      report "CONNECTIVITY ERROR: TH_SDI not grounded"
      severity error;
      assert TH_SCLK  = GND
      report "CONNECTIVITY ERROR: TH_SCLK not grounded"
      severity error;
      assert TH_SMODE = VCC
      report "CONNECTIVITY ERROR: TH_SMODE not grounded"
      severity error;
      assert TH_CE    = GND
      report "CONNECTIVITY ERROR: TH_CE not grounded"
      severity error;
      wait;
   end process CONCHK;
   
end bench;
