library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity Shuffle is
port(

	dataa 	: in std_logic_vector(31 downto 0);
	result 	: out std_logic_vector(31 downto 0)
);
end Shuffle;


architecture behavior of Shuffle is
begin

	process(dataa)
	begin
		result(31 downto 24) <= dataa(7 downto 0);
		for i in 8 to 23 loop
			result(i) <= dataa(31 - i);
		end loop;
		result(7 downto 0) 	<= dataa(31 downto 24);
	end process;
	
end behavior;