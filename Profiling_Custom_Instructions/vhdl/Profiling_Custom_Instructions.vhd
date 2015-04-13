library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Profiling_Custom_Instructions is
port(
	CLOCK_50 : in std_logic;
	KEY 		: in std_logic_vector(0 downto 0)
);
end entity Profiling_Custom_Instructions;

architecture Structural of Profiling_Custom_Instructions is

component nios2_system is
	port (
		clk_clk       : in  std_logic := '0'; --   clk.clk
		reset_reset_n : in  std_logic := '0'  -- reset.reset_n
	);
end component nios2_system;

begin
	system_inst: component nios2_system
	port map(
		clk_clk 									=> CLOCK_50,
		reset_reset_n 							=> KEY(0));
end architecture Structural;