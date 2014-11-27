library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Translator is
	port(
		clk      : in  std_logic;
		reset_n  : in  std_logic;

		start    : in  std_logic;
		cmd      : in  std_logic;
		data_in  : in  std_logic_vector(15 downto 0);
		busy     : out std_logic;

		csx      : out std_logic;
		dcx      : out std_logic;
		wrx      : out std_logic;
		rdx      : out std_logic;
		data_out : out std_logic_vector(15 downto 0)
	);
end entity LT24_Translator;