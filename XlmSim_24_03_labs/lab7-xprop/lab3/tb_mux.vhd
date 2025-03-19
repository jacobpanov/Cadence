library ieee ;
use ieee.std_logic_1164.all;
use work.all;

entity tb_mux is

end entity tb_mux;

architecture test_tb_mux of tb_mux is
	signal a, b, c, sel : std_logic_vector(1 downto 0);
	signal q : std_logic_vector(1 downto 0);

	component mux4to1 is
		port(a,b,c, sel : in std_logic_vector(1 downto 0) ; q : out std_logic_vector(1 downto 0));
	end component;

begin

	mux_inst: mux4to1 port map (a,b,c,sel,q);
	
	process
	begin
		wait for 10 ns;
		a <= "00" ; b <= "00" ; c <= "00"; sel <= "00";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "01";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "11";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "XX";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "11";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "X1";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "11";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "0X";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "11";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "1X";
		wait for 10 ns;
		a <= "00" ; b <= "01" ; c <= "10"; sel <= "11";
		wait;
	end process;	

end architecture test_tb_mux;

