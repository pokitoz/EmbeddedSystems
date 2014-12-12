
module LT24_System (
	clk_clk,
	reset_reset_n,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	pll_sdram_clk,
	pll_areset_export,
	pll_locked_export,
	pll_phasedone_export,
	lt24_ctrl_0_lcd_reset_n_export,
	lt24_ctrl_0_lcd_on_export,
	lt24_ctrl_0_csx_export,
	lt24_ctrl_0_dcx_export,
	lt24_ctrl_0_wrx_export,
	lt24_ctrl_0_rdx_export,
	lt24_ctrl_0_data_out_export,
	lt24_ctrl_0_wait_request_master_debug_export,
	lt24_ctrl_0_read_master_debug_export,
	lt24_ctrl_0_read_data_master_debug_export,
	lt24_ctrl_0_address_master_debug_export,
	pll_c2_conduit_export);	

	input		clk_clk;
	input		reset_reset_n;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	output		pll_sdram_clk;
	input		pll_areset_export;
	output		pll_locked_export;
	output		pll_phasedone_export;
	output		lt24_ctrl_0_lcd_reset_n_export;
	output		lt24_ctrl_0_lcd_on_export;
	output		lt24_ctrl_0_csx_export;
	output		lt24_ctrl_0_dcx_export;
	output		lt24_ctrl_0_wrx_export;
	output		lt24_ctrl_0_rdx_export;
	output	[15:0]	lt24_ctrl_0_data_out_export;
	output		lt24_ctrl_0_wait_request_master_debug_export;
	output		lt24_ctrl_0_read_master_debug_export;
	output	[31:0]	lt24_ctrl_0_read_data_master_debug_export;
	output	[31:0]	lt24_ctrl_0_address_master_debug_export;
	output		pll_c2_conduit_export;
endmodule
