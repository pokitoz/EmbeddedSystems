library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Clock is
	port(
		clk_50Mhz  : in  std_logic;
		reset_n    : in  std_logic;
		clk_9600Hz : out std_logic);
end UART_Clock;

architecture RTL of UART_Clock is
	constant MAX9600      : unsigned(15 downto 0) := X"1458";
	signal counter        : unsigned(15 downto 0);
	signal clk_9600Hz_reg : std_logic;
begin
	generate_clk : process(clk_50Mhz, reset_n)
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
	end process generate_clk;

	clk_9600Hz <= clk_9600Hz_reg;

end RTL;