library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interrupt_Benchmark is
	port(
		CLOCK_50              : in    std_logic;
		KEY                   : in    std_logic_vector(1 downto 0);
		LED                   : out   std_logic_vector(7 downto 0)
	);
end entity Interrupt_Benchmark;

architecture Structural of Interrupt_Benchmark is
component nios2_system is
	port (
		clk_clk              : in  std_logic                    := '0';             --           clk.clk
		inputs_export        : in  std_logic_vector(7 downto 0) := (others => '0'); --        inputs.export
		leds_export          : out std_logic_vector(7 downto 0);                    --          leds.export
		pll_areset_export    : in  std_logic                    := '0';             --    pll_areset.export
		pll_locked_export    : out std_logic;                                       --    pll_locked.export
		pll_phasedone_export : out std_logic;                                       -- pll_phasedone.export
		pll_sdram_clk_clk    : out std_logic;                                       -- pll_sdram_clk.clk
		reset_reset_n        : in  std_logic                    := '0'              --         reset.reset_n
	);
end component nios2_system;
begin
	system_inst : component nios2_system
		port map(clk_clk                      		=> CLOCK_50,
			     reset_reset_n                		=> KEY(0),
				  leds_export(7 downto 0)				=> LED,
				  inputs_export(7 downto 1)			=> (others => '0'),
				  inputs_export(0)						=> KEY(1),
			     pll_areset_export    					=> '0',
			     pll_locked_export    					=> open,
			     pll_phasedone_export 					=> open,
				  pll_sdram_clk_clk						=> open);
end architecture Structural;

