library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Master is
	port (
		clk : in std_logic;
		reset_n : in std_logic;
		
		data_fifo : out std_logic_vector(31 downto 0);
		write_fifo : out std_logic;
		fifo_full : in std_logic;
		fifo_almost_full : in std_logic_vector(5 downto 0);
		
		address : out std_logic_vector(31 downto 0);
		write : out std_logic;
		write_data : out std_logic;
		wait_request : in std_logic
	);
end entity LT24_Master;