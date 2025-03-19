library ieee ; use ieee.std_logic_1164.all ;

entity mux is
  port
    (
      y  : out std_logic ;
      s  : in  std_logic ;
      i1 : in  std_logic ;
      i0 : in  std_logic  
    ) ;
end mux ;

architecture vhdl of mux is
  begin

    process ( s, i1, i0 )
      begin
        if ( s = '1' ) then
          y <= i1 ;
        else
          y <= i0 ;
        end if ;
      end process ;

  end vhdl ;
