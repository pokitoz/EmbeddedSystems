library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Profiling_Custom_Instructions is
	port(
		CLOCK_50 : in std_logic;
		KEY 		: in std_logic_vector(0 downto 0);
		
		-- DRAM wires
		DRAM_CLK, DRAM_CKE    : out   std_logic;
		DRAM_ADDR             : out   std_logic_vector(12 downto 0);
		DRAM_BA               : out   std_logic_vector(1 downto 0);
		DRAM_CS_N, DRAM_CAS_N : out   std_logic;
		DRAM_RAS_N, DRAM_WE_N : out   std_logic;
		DRAM_DQ               : inout std_logic_vector(15 downto 0);
		DRAM_DQM              : out   std_logic_vector(1 downto 0)
	);
end entity Profiling_Custom_Instructions;

architecture Structural of Profiling_Custom_Instructions is

component nios2_system is
	port (
		clk_clk              : in    std_logic                     := '0';             --           clk.clk
		pll_areset_export    : in    std_logic                     := '0';             --    pll_areset.export
		pll_locked_export    : out   std_logic;                                        --    pll_locked.export
		pll_phasedone_export : out   std_logic;                                        -- pll_phasedone.export
		reset_reset_n        : in    std_logic                     := '0';             --         reset.reset_n
		sdram_clk_clk        : out   std_logic;                                        --     sdram_clk.clk
		sdram_wire_addr      : out   std_logic_vector(12 downto 0);                    --    sdram_wire.addr
		sdram_wire_ba        : out   std_logic_vector(1 downto 0);                     --              .ba
		sdram_wire_cas_n     : out   std_logic;                                        --              .cas_n
		sdram_wire_cke       : out   std_logic;                                        --              .cke
		sdram_wire_cs_n      : out   std_logic;                                        --              .cs_n
		sdram_wire_dq        : inout std_logic_vector(15 downto 0) := (others => '0'); --              .dq
		sdram_wire_dqm       : out   std_logic_vector(1 downto 0);                     --              .dqm
		sdram_wire_ras_n     : out   std_logic;                                        --              .ras_n
		sdram_wire_we_n      : out   std_logic                                         --              .we_n
	);
end component nios2_system;

begin
	system_inst: component nios2_system
	port map(
		clk_clk 									=> CLOCK_50,
		reset_reset_n 							=> KEY(0),
		pll_areset_export						=> '0',
		pll_locked_export						=> open,
		pll_phasedone_export					=> open,
		sdram_clk_clk							=> DRAM_CLK,
		sdram_wire_addr						=> DRAM_ADDR,
		sdram_wire_ba							=> DRAM_BA,
		sdram_wire_cas_n						=> DRAM_CAS_N,
		sdram_wire_cke							=> DRAM_CKE,
		sdram_wire_cs_n						=> DRAM_CS_N,
		sdram_wire_dq							=> DRAM_DQ,
		sdram_wire_dqm							=> DRAM_DQM,
		sdram_wire_ras_n						=> DRAM_RAS_N,
		sdram_wire_we_n						=> DRAM_WE_N);
end architecture Structural;