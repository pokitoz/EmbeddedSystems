library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_data is
	port(
		reset_n : in std_logic;
		
		clk_write     : in std_logic;
		write_data : in std_logic_vector(31 downto 0);
		write_fifo : in std_logic;
		fifo_full : out std_logic;
		fifo_almost_full : out std_logic_vector(7 downto 0);
		
		clk_read : in std_logic;
		read_data : out std_logic_vector(15 downto 0);
		read_fifo : in std_logic;
		fifo_empty : out std_logic;
		fifo_almost_empy : out std_logic_vector(7 downto 0)
	);
end entity FIFO_data;
