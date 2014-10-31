library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Receive is
	port(
		clk          : in  std_logic;
		clk_9600Hz   : in std_logic;
		reset_n      : in  std_logic;
		ackNewData   : in  std_logic;
		newDataReady : out std_logic;
		dataToRead   : out std_logic_vector(7 downto 0);
		Rx           : in  std_logic
	);
end entity UART_Receive;

architecture RTL of UART_Receive is
	signal counter     : unsigned(3 downto 0);
	signal buffer_read : std_logic_vector(7 downto 0);
	signal lastData    : std_logic_vector(7 downto 0);

begin
	dataToRead <= lastData;

	reg_slow_process : process(clk_9600Hz, reset_n, ackNewData) is
	begin
		if reset_n = '0' then
			lastData    <= (others => '0');
			counter     <= (others => '0');
			buffer_read <= (others => '0');

		elsif rising_edge(clk_9600Hz) then
			if counter = 0 and Rx = '0' then
				counter <= counter + 1;
			elsif counter = 9 then
				counter  <= (others => '0');
				lastData <= buffer_read;
				newDataReady <= '1';
			elsif counter /= 0 then
				buffer_read <= Rx & buffer_read(7 downto 1);
				counter     <= counter + 1;
			end if;

		end if;
	end process reg_slow_process;

end architecture RTL;



