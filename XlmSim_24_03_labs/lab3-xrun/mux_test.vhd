library ieee ; use ieee.std_logic_1164.all ;
               use ieee.std_logic_textio.all ;
library std  ; use std.textio.all ;

entity mux_test is
end mux_test ;

architecture vhdl of mux_test is

  component mux
    port
    (
      y  : out std_logic ;
      s  : in  std_logic ;
      i1 : in  std_logic ;
      i0 : in  std_logic  
    ) ;
  end component ;

  for all : mux use entity work.mux(vhdl) ;

  signal y  : std_logic ;
  signal s  : std_logic ;
  signal i1 : std_logic ;
  signal i0 : std_logic ;

  procedure expect ( y_e : in std_logic ) is
    variable vline : line ;
    begin
      write ( vline, string'( "time=" ) ) ; write ( vline, now ) ;
      write ( vline, string'( " s="   ) ) ; write ( vline, s   ) ;
      write ( vline, string'( " i1="  ) ) ; write ( vline, i1  ) ;
      write ( vline, string'( " i0="  ) ) ; write ( vline, i0  ) ;
      write ( vline, string'( " y="   ) ) ; write ( vline, y   ) ;
      writeline ( output, vline ) ;
      if y /= y_e then
        write ( vline, string'( "WANT:                   y=" ) ) ;
        write ( vline, y_e ) ;
        writeline ( output, vline ) ;
        write ( output, string'( "TEST FAILED" & LF) ) ;
        assert false severity error ;
      end if ;
    end expect ;

  begin

    mux_i : mux
      port map
      (
        y  => y  ,
        s  => s  ,
        i1 => i1 ,
        i0 => i0  
      ) ;

    process
      begin
        s <= '0' ; i1 <= '0' ; i0 <= '1' ; wait for 1 ns ; expect ( '1' ) ;
        s <= '0' ; i1 <= '1' ; i0 <= '0' ; wait for 1 ns ; expect ( '0' ) ;
        s <= '1' ; i1 <= '0' ; i0 <= '1' ; wait for 1 ns ; expect ( '0' ) ;
        s <= '1' ; i1 <= '1' ; i0 <= '0' ; wait for 1 ns ; expect ( '1' ) ;
        wait for 1 ns ;
        write ( output, string'( "TEST PASSED" & LF) ) ;
        wait ;
      end process ;

  end vhdl ;
