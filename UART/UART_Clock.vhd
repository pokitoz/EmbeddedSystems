library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Clock is
	port(
		clk_50Mhz  : in  std_logic;
		reset_n    : in  std_logic;
		clk_4X9600Hz : out std_logic;
		clk_9600Hz : out std_logic);
end UART_Clock;

architecture RTL of UART_Clock is
	constant MAX9600      	: unsigned(15 downto 0) := X"0A2C";
	constant MAX4X9600    	: unsigned(15 downto 0) := X"028B";
	signal counter        	: unsigned(15 downto 0);
	signal counter4x9600  	: unsigned(15 downto 0);
	signal clk_9600Hz_reg 	: std_logic;
	signal clk_4x9600Hz_reg	: std_logic;

begin
	generate_clk9600 : process(clk_50Mhz, reset_n)
	begin
		if reset_n = '0' then
			clk_9600Hz_reg <= '0';
			counter        <= (others => '0');
		elsif rising_edge(clk_50Mhz) then
			if counter = MAX9600 then
				counter        <= (others => '0');
				clk_9600Hz_reg <= not clk_9600Hz_reg;
			else
				counter <= counter + "1";
			end if;
		end if;
	end process generate_clk9600;
	
	
	
	generate_clk4x9600 : process(clk_50Mhz, reset_n)
	begin
		if reset_n = '0' then
			clk_4x9600Hz_reg <= '0';
			counter4x9600     <= (others => '0');
		elsif rising_edge(clk_50Mhz) then
			if counter4x9600 = MAX4X9600 then
				counter4x9600  <= (others => '0');
				clk_4x9600Hz_reg <= not clk_4x9600Hz_reg;
			else
				counter4x9600 <= counter4x9600 + "1";
			end if;
		end if;
	end process generate_clk4x9600;
	
	clk_4X9600Hz <= clk_4x9600Hz_reg;
	clk_9600Hz <= clk_9600Hz_reg;

end RTL;
