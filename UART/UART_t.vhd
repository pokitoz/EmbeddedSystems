library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_t is
	port(
		clk     : in  std_logic;
		reset_n : in  std_logic;
		tx      : out std_logic
	);
end entity UART_t;

architecture RTL of UART_t is
	component UART_Clock
		port(clk_50Mhz  : in  std_logic;
			 reset_n    : in  std_logic;
			 clk_9600Hz : out std_logic);
	end component UART_Clock;

	signal clk_9600Hz : std_logic;
	signal count      : integer;
	signal tx_next    : std_logic;
	signal tx_reg     : std_logic;

begin
	UART_Clock_inst : component UART_Clock
		port map(clk_50Mhz  => clk,
			     reset_n    => reset_n,
			     clk_9600Hz => clk_9600Hz);

	name2 : process(clk_9600Hz, reset_n) is
	begin
		if reset_n = '0' then
			tx_reg <= '0';
			count  <= 0;
		elsif rising_edge(clk_9600Hz) then
			count <= count + 1;
			case count is
				when 0 => tx_reg <= '0';
				when 4 => tx_reg <= '0';

				when 5 => tx_reg <= '0';
				when 6 => tx_reg <= '0';
				when 7 => tx_reg <= '0';
				when 8 => tx_reg <= '0';

				when 9  => tx_reg <= '0';
				when 10 => tx_reg <= '0';
				when 11 => tx_reg <= '0';
				when 12 => tx_reg <= '0';

				when 13     => tx_reg <= '0';
				when 20     => count <= 0;
				when others =>
					tx_reg <= '0';
					
			end case;

		end if;
	end process name2;

	tx <= tx_reg;

end architecture RTL;
