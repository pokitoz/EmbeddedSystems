library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO_To_LT24_Translator is
	port(
		clk               : in  std_logic;
		reset_n           : in  std_logic;

		data_in           : in  std_logic_vector(15 downto 0);
		read_fifo         : out std_logic;
		fifo_empty        : in  std_logic;
		fifo_almost_empty : in  std_logic_vector(7 downto 0);

		start             : out std_logic;
		data_out          : out std_logic_vector(15 downto 0);
		busy              : in  std_logic
	);
end entity FIFO_To_LT24_Translator;
