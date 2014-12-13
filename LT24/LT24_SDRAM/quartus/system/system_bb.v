
module system (
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
	pio_leds_export,
	pio_buttons_export,
	pio_switches_export,
	pll_sdram_clk,
	pll_areset_export,
	pll_locked_export,
	pll_phasedone_export,
	pll_camera_clk,
	camera_interface_0_camera_pixclk_export,
	camera_interface_0_camera_data_export,
	camera_interface_0_camera_lval_export,
	camera_interface_0_camera_fval_export,
	camera_interface_0_camera_scl_export,
	camera_interface_0_camera_sda_export,
	lt24_ctrl_0_lcd_reset_n_export,
	lt24_ctrl_0_lcd_on_export,
	lt24_ctrl_0_csx_export,
	lt24_ctrl_0_wrx_export,
	lt24_ctrl_0_rdx_export,
	lt24_ctrl_0_data_out_export,
	lt24_ctrl_0_dcx_export);	

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
	output	[7:0]	pio_leds_export;
	input	[1:0]	pio_buttons_export;
	input	[3:0]	pio_switches_export;
	output		pll_sdram_clk;
	input		pll_areset_export;
	output		pll_locked_export;
	output		pll_phasedone_export;
	output		pll_camera_clk;
	input		camera_interface_0_camera_pixclk_export;
	input	[11:0]	camera_interface_0_camera_data_export;
	input		camera_interface_0_camera_lval_export;
	input		camera_interface_0_camera_fval_export;
	inout		camera_interface_0_camera_scl_export;
	inout		camera_interface_0_camera_sda_export;
	output		lt24_ctrl_0_lcd_reset_n_export;
	output		lt24_ctrl_0_lcd_on_export;
	output		lt24_ctrl_0_csx_export;
	output		lt24_ctrl_0_wrx_export;
	output		lt24_ctrl_0_rdx_export;
	output	[15:0]	lt24_ctrl_0_data_out_export;
	output		lt24_ctrl_0_dcx_export;
endmodule
