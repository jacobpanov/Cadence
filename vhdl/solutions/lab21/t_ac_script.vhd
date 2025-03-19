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
use work.ALARM_TEST.all;
use work.P_DISP4.all;
   
use std.textio.all;

entity TB_AC_SCRIPT is
end TB_AC_SCRIPT;

architecture BENCH of TB_AC_SCRIPT is
   
   component ALARM_CLOCK
   
   port (CLOCK, RESET : in  std_logic;
         SHARLM       : in  std_logic;  
         MINS         : in  std_logic; 
         HOURS        : in  std_logic; 
         ALRMON       : in  std_logic; 
   
         LED          : out std_logic;  
   
         MS_HOURS     : out std_logic_vector(6 downto 0);
         LS_HOURS     : out std_logic_vector(6 downto 0); 
         COLON        : out std_logic;        
         MS_MINS      : out std_logic_vector(6 downto 0);
         LS_MINS      : out std_logic_vector(6 downto 0); 
         MS_HOURS_DP  : out std_logic;     
         LS_HOURS_DP  : out std_logic;    
         MS_MINS_DP   : out std_logic;     
   
         LCD_COM1     : out std_logic;    
         LCD_COM2     : out std_logic;      
         
         TH_SMODE     : out std_logic;
         TH_SDI       : out std_logic;
         TH_SCLK      : out std_logic;
         TH_CE        : out std_logic;
         INPUT_HOLD1  : out std_logic;
         INPUT_HOLD2  : out std_logic;
         INPUT_HOLD3  : out std_logic;
   
         JTAG_TDO     : in std_logic;
         PCB_NO_CONNECT : out std_logic);   
   
   end component;
   
   -- input control signals
   signal CLOCK, RESET : std_logic := '1';
   
   -- push button inputs
   signal SHARLM, MINS, HOURS, ALRMON : std_logic := '1';
   
   -- digits
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
   signal ALARM_SOUND : std_logic := '0';
   signal COMMAND : string (1 to 10);
   
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
       DISPBCD(I) <=  "0000" when ZERO_SEG,
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
    
   AL_DETECT : process
     -- LED flash timing is:-
     constant LED_ON  : time := NUM_LED_ON_CYCLES * PERIOD;
     constant LED_OFF : time :=  (COUNT_LED_OFF - 1) * HALF_SEC_PERIOD;
     constant FLASH_PERIOD : time := LED_ON + LED_OFF;
   begin
     wait until LED = '1';
     ALARM_SOUND <= '1';
     loop
        wait until LED = '1' for FLASH_PERIOD;
        exit when LED = '0';
     end loop;
     ALARM_SOUND <= '0';
   end process AL_DETECT;
     
   
   ------------------------------------------------------------------------
   -- COMMAND INPUT process
   -- This process reads command strings from  the test file "command.txt"
   -- and generates input stimulus to the block under test, depending upon
   -- which command is read in. The commands are:
   --
   -- SHALM   -- show alarm
   -- TI_MN DD   -- set time minutes to DD
   -- TI_HR DD   -- set time hours to DD
   -- AL_MN DD   -- set alarm minutes to DD
   -- AL_HR DD   -- set alarm hours to DD
   -- TIMED DDDD -- advance the clock to DDDD
   -- ALTOG   -- toggle alarm on/off
   --
   -- (D = integer ascii character in range 0-9)
   ------------------------------------------------------------------------
   COMMAND_INPUT: 
   process 
     file COMFILE          : text open read_mode is "command.txt";
     variable L            : line;
     variable CMD          : string(1 to 5);
     variable TWO_DIGIT    : string(1 to 2);
     variable FOUR_DIGIT   : string(1 to 4);     
     variable SEPARATOR    : character;
   begin
     -- if there are still lines to read in the text file ...
     while not ENDFILE(COMFILE) loop
   
       -- read in next line from text file, then read the first text string
       -- from the line and call this CMD.
       readline(COMFILE, L);
       COMMAND <= L(L'left to L'left + 9);
       read (L, CMD);
   
       -- Depending on what the command is, read in any extra information
       -- from the line read from the file and then "do" the command
       case CMD is
          when "SHALM" => DO_SHALM(SHARLM);
       
          when "TI_MN" => read (L, SEPARATOR);
              read (L, TWO_DIGIT);
              DO_TI_MN(TWO_DIGIT, DISPLAY_MS_MN, DISPLAY_LS_MN, MINS);
   
          when "TI_HR" => read (L, SEPARATOR);
              read (L, TWO_DIGIT);
              DO_TI_HR(TWO_DIGIT, DISPLAY_MS_HR, DISPLAY_LS_HR, HOURS);       
      
          when "AL_MN" => read (L, SEPARATOR);
              read (L, TWO_DIGIT);
              DO_AL_MN(TWO_DIGIT, DISPLAY_MS_MN, DISPLAY_LS_MN, SHARLM, MINS);
      
          when "AL_HR" => read (L, SEPARATOR);
              read (L, TWO_DIGIT);
              DO_AL_HR(TWO_DIGIT, DISPLAY_MS_HR, DISPLAY_LS_HR, SHARLM, HOURS);  
      
      
          when "TIMED" => read (L, SEPARATOR);
              read (L, FOUR_DIGIT);
              DO_TIME(FOUR_DIGIT, DISPLAY_MS_HR, DISPLAY_LS_HR, DISPLAY_MS_MN, DISPLAY_LS_MN);
      
          when "ALTOG" => DO_ALTOG(ALRMON);
      
          when others => assert FALSE 
                           report "Unrecognised Instruction - " & CMD 
                           severity FAILURE;
      end case;
      
      end loop;
   
   -- No new lines to read from file, so report simulation complete and
   -- stop clock generator with SIM_END signal
      assert FALSE report "Simulation complete" severity FAILURE;
      --SIM_END <= TRUE;
   
      wait;
   
   end process COMMAND_INPUT;
   
   
   ------------------------------------------------------------------------
   -- TRACE OUTPUT process
   -- This process writes out the outputs of the Alarm Clock
   -- to an external text file
   ------------------------------------------------------------------------
   TRACE_OUTPUT: 
   process 
      file TRACEFILE   : text open write_mode is "trace.txt";
      variable L    : line;
      variable READING : string(1 to 5);
      
      constant SPACE : character := ' ';
   
      function BCD2CHAR (BCD : std_logic_vector(3 downto 0)) return character is
        variable CHAR : character;
      begin
        case BCD is
           when "0000" => CHAR := '0';
           when "0001" => CHAR := '1';    
           when "0010" => CHAR := '2';
           when "0011" => CHAR := '3';
           when "0100" => CHAR := '4';
           when "0101" => CHAR := '5';    
           when "0110" => CHAR := '6';
           when "0111" => CHAR := '7';       
           when "1000" => CHAR := '8';
           when "1001" => CHAR := '9'; 
           when others =>
              assert false
                report "Unknown BCD in BCD2CHAR conversion"
                severity note;
             CHAR := '-';
        end case;
        return CHAR;
      end BCD2CHAR;
   
   begin
      wait on DISPLAY_MS_HR, DISPLAY_LS_HR, DISPLAY_MS_MN, DISPLAY_LS_MN, ALARM_SOUND;
   
    -- Build up the line to be written out:
    -- first print current simulation time, then a space,...
      write(L, NOW);
      write(L, SPACE);
   
    -- Build up the line to be written out:
    -- write the value of the DISPLAY, type-converting to CHARACTER
   
      READING := (BCD2CHAR(DISPLAY_MS_HR), BCD2CHAR(DISPLAY_LS_HR),':',
      BCD2CHAR(DISPLAY_MS_MN), BCD2CHAR(DISPLAY_LS_MN));
   
      write(L, READING);
      write(L, SPACE);
      write(L, std_logic'image(ALARM_SOUND));
   
    -- write out the line you have built-up to the output file
      writeline(TRACEFILE, L);     
   
   end process TRACE_OUTPUT;
   
   
   
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
