
module system (
	clk_clk,
	reset_reset_n,
	pll_sdram_clk_clk,
	pll_areset_conduit_export,
	pll_locked_conduit_export,
	pll_phasedone_conduit_export,
	sdram_wire_addr,
	sdram_wire_ba,
	sdram_wire_cas_n,
	sdram_wire_cke,
	sdram_wire_cs_n,
	sdram_wire_dq,
	sdram_wire_dqm,
	sdram_wire_ras_n,
	sdram_wire_we_n,
	leds_export);	

	input		clk_clk;
	input		reset_reset_n;
	output		pll_sdram_clk_clk;
	input		pll_areset_conduit_export;
	output		pll_locked_conduit_export;
	output		pll_phasedone_conduit_export;
	output	[12:0]	sdram_wire_addr;
	output	[1:0]	sdram_wire_ba;
	output		sdram_wire_cas_n;
	output		sdram_wire_cke;
	output		sdram_wire_cs_n;
	inout	[15:0]	sdram_wire_dq;
	output	[1:0]	sdram_wire_dqm;
	output		sdram_wire_ras_n;
	output		sdram_wire_we_n;
	output	[7:0]	leds_export;
endmodule
