library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Slave is
	port(
		-- Avalon signals
		clk         : in    std_logic;
		reset_n     : in    std_logic;
		address     : in    std_logic_vector(2 downto 0);
		chip_select : in    std_logic;

		read        : in    std_logic;
		write       : in    std_logic;

		read_data   : out   std_logic_vector(31 downto 0);
		write_data  : in    std_logic_vector(31 downto 0);

		-- LT24 signals
		lcd_reset_n : out   std_logic;
		lcd_on      : out   std_logic;
		
		data        : inout std_logic_vector(15 downto 0)
	);
end entity LT24_Slave;