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

entity TB_CONTROL is
end TB_CONTROL;

architecture BENCH of TB_CONTROL is
   
  -- Test method
  -- Testbench uses a record type with three elements:-
  --   STIM - 3 FSM inputs (AL, MN, HR)
  --   RESP - 6 FSM outputs (SHOW_T, LOAD_T, SHOW_A, LOAD_A, INC_HOUR, INC_MIN)
  --   ESTR - string containing state name
  --
  -- We create an array of this record, one for each test pattern
  -- We create a for loop to index through all the elements in the array
  -- STIM is applied on +ve clock edge
  -- FSM outputs are compared to RESP on -ve clock edge
  -- ESTR is used in  report if RESP and outputs do not match
   
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
   
   type IO_VEC is record
     STIM : unsigned(2 downto 0);   -- stimulus
     RESP : unsigned(5 downto 0);   -- expected results
     ESTR : string(1 to 8);                -- error message
   end record;
   
   type IO_ARR_T is array (1 to 19) of IO_VEC;  -- array of 18 stimulus/response/error data
   
   constant IO_ARR : IO_ARR_T :=
      -- stim order:- AL, MN, HR
      -- resp order:- SHOW_T, LOAD_T, SHOW_A, LOAD_A, INC_HOUR, INC_MIN
            
     (("000", "100000", "SHOW_T  "),  -- test  1: reset to state show_time
      ("001", "000010", "INC_HOUR"),  -- test  2: HR: state inc_ti_hr
      ("101", "000010", "INC_HOUR"),  -- test  3: AL & HR: state inc_ti_hr unchanged
      ("000", "010000", "LOAD_T  "),  -- test  4: ~HR: state time_set
      ("000", "100000", "SHOW_T  "),  -- test  5: next clock: state show_time
      ("010", "000001", "INC_MIN "),  -- test  6: MN: state inc_ti_mn
      ("110", "000001", "INC_MIN "),  -- test  7: AL & MN: state inc_ti_hr unchanged
      ("000", "010000", "LOAD_T  "),  -- test  8: ~MN: state time_set
      ("000", "100000", "SHOW_T  "),  -- test  9: next clock: state show_time
      ("100", "001000", "SHOW_A  "),  -- test 10: AL: state show_alarm
      ("101", "000010", "INC_HOUR"),  -- test 11: AL & HR: state inc_al_hr
      ("001", "000010", "INC_HOUR"),  -- test 12: HR: state inc_al_hr unchanged when AL released
      ("100", "000100", "LOAD_A  "),  -- test 13: ~HR: state alarm_set
      ("100", "001000", "SHOW_A  "),  -- test 14: next clock: state show_alarm
      ("110", "000001", "INC_MIN "),  -- test 15: AL & MN: state inc_al_mn
      ("010", "000001", "INC_MIN "),  -- test 16: MN: state inc_al_mn unchanged when AL released
      ("100", "000100", "LOAD_A  "),  -- test 17: AL & ~MN: state alarm_set
      ("100", "001000", "SHOW_A  "),  -- test 18: AL: state show_alarm
      ("000", "100000", "SHOW_T  ")); -- test 19: ~AL: state show_time
   
   signal SHOW_T, LOAD_T, SHOW_A, LOAD_A, INC_HOUR, INC_MIN : std_logic;
   signal AL, MN, HR : std_logic;
   signal CLOCK, RESET : std_logic := '0';
   signal OUTVEC : unsigned(5 downto 0);
     
 begin
       
   DUT: CONTROL port map (CLOCK, RESET, AL, MN, HR,
                          SHOW_A, LOAD_A, SHOW_T, LOAD_T, INC_HOUR, INC_MIN);
   
   CLOCK <= not CLOCK after 10 ns;
   
   RESET <= '1', '0' after 5 ns, '1' after 15 ns;
   
   OUTVEC <= (SHOW_T, LOAD_T, SHOW_A, LOAD_A, INC_HOUR, INC_MIN);  -- capture outputs into vector

   TEST : 
   process
   begin
     -- sync to negative edge of clock
     wait until CLOCK = '0';
      
     for I in IO_ARR'range loop
       -- assign inputs
       (AL, MN, HR) <= IO_ARR(I).STIM;
       -- wait one clock
       wait until CLOCK = '0';
       -- check outputs
       if OUTVEC /= IO_ARR(I).RESP then
         case to_integer(OUTVEC) is
           when 0 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found no output" severity ERROR;
           when 1 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found INC_MIN" severity ERROR;
           when 2 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found INC_HOUR" severity ERROR;
           when 4 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found LOAD_A" severity ERROR;
           when 8 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found SHOW_A" severity ERROR;
           when 16 => 
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": found LOAD_T" severity ERROR;
           when 32 => 
             report "test " & integer'image(I) & " failed: expected output "
                     & IO_ARR(I).ESTR & ": found SHOW_T" severity ERROR;
           when others =>
             report "test " & integer'image(I) & " failed: expected output " 
                     & IO_ARR(I).ESTR & ": multiple outputs set" severity ERROR;
         end case;    
       end if;
     end loop;
      
     --assert FALSE
       report "simulation over"
        severity failure;
     wait;
   end process TEST;
   
end BENCH;
