library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RTOS_Benchmark is
port(
	CLOCK_50 : in std_logic;
	KEY 		: in std_logic_vector(0 downto 0);
	
	Button_n : in std_logic_vector(3 downto 0);
	GPIO_2_D : out std_logic_vector(7 downto 0);
	
	-- DRAM wires
	DRAM_CLK, DRAM_CKE    : out   std_logic;
	DRAM_ADDR             : out   std_logic_vector(12 downto 0);
	DRAM_BA               : out   std_logic_vector(1 downto 0);
	DRAM_CS_N, DRAM_CAS_N : out   std_logic;
	DRAM_RAS_N, DRAM_WE_N : out   std_logic;
	DRAM_DQ               : inout std_logic_vector(15 downto 0);
	DRAM_DQM              : out   std_logic_vector(1 downto 0)
);
end entity RTOS_Benchmark;

architecture Structural of RTOS_Benchmark is

component nios_system is
	port (
		clk_clk              : in    std_logic                     := '0';             --           clk.clk
		inputs_export        : in    std_logic_vector(7 downto 0)  := (others => '0'); --        inputs.export
		outputs_export       : out   std_logic_vector(7 downto 0);                     --       outputs.export
		pll_areset_export    : in    std_logic                     := '0';             --    pll_areset.export
		pll_locked_export    : out   std_logic;                                        --    pll_locked.export
		pll_phasedone_export : out   std_logic;                                        -- pll_phasedone.export
		reset_reset_n        : in    std_logic                     := '0';             --         reset.reset_n
		sdram_addr           : out   std_logic_vector(12 downto 0);                    --         sdram.addr
		sdram_ba             : out   std_logic_vector(1 downto 0);                     --              .ba
		sdram_cas_n          : out   std_logic;                                        --              .cas_n
		sdram_cke            : out   std_logic;                                        --              .cke
		sdram_cs_n           : out   std_logic;                                        --              .cs_n
		sdram_dq             : inout std_logic_vector(15 downto 0) := (others => '0'); --              .dq
		sdram_dqm            : out   std_logic_vector(1 downto 0);                     --              .dqm
		sdram_ras_n          : out   std_logic;                                        --              .ras_n
		sdram_we_n           : out   std_logic;                                        --              .we_n
		sdram_clk_clk        : out   std_logic                                         --     sdram_clk.clk
	);
end component nios_system;

begin
	system_inst: component nios_system
	port map(
		clk_clk 									=> CLOCK_50,
		reset_reset_n 							=> KEY(0),
		inputs_export(3 downto 0) 			=> Button_n(3 downto 0),
		inputs_export(7 downto 4) 			=> (others => '0'),
		outputs_export							=> GPIO_2_D(7 downto 0),
		pll_locked_export						=> open,
		pll_phasedone_export 				=> open,
		pll_areset_export 					=> '0',
		sdram_addr								=> DRAM_ADDR,
		sdram_ba									=> DRAM_BA,
		sdram_cas_n								=> DRAM_CAS_N,
		sdram_cke								=> DRAM_CKE,
		sdram_clk_clk							=> DRAM_CLK,
		sdram_cs_n								=> DRAM_CS_N,
		sdram_dq									=> DRAM_DQ,
		sdram_dqm								=> DRAM_DQM,
		sdram_ras_n								=> DRAM_RAS_N,
		sdram_we_n								=> DRAM_WE_N);
end architecture Structural;