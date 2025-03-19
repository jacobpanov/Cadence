library ieee ;
use ieee.std_logic_1164.all;
use work.all;

entity mux4to1 is
port    (
	a  : in std_logic_vector(1 downto 0);
	b  : in std_logic_vector(1 downto 0);
	c  : in std_logic_vector(1 downto 0);
	sel  : in std_logic_vector(1 downto 0);
	q    : out std_logic_vector(1 downto 0)
        );

end entity mux4to1;

architecture mux4to1_rtl of mux4to1 is

begin

	P1 : process(sel,a,b,c)
	begin
		case sel is
			when "00" => q <= a;
			when "01" => q <= b;
			when "10" => q <= c;
			when others => q <= "00";
		end case; 
	end process P1;


end architecture mux4to1_rtl;
