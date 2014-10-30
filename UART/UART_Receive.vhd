library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Receive is
	port (
		clk : in std_logic;
		clk_9600Hz : std_logic;
		reset_n : in std_logic;
		ackNewData: in std_logic;
		newDataReady : out std_logic;
		dataToRead : out std_logic_vector(7 downto 0);
		Rx : in std_logic
	);
end entity UART_Receive;

architecture RTL of UART_Receive is
	
begin
	dataToRead <= (others => '0');
	newDataReady <= '0';
end architecture RTL;

