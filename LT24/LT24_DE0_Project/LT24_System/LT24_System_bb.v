
module LT24_System (
	clk_clk,
	reset_reset_n,
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
	lt24_ctrl_0_address_master_debug_export);	

	input		clk_clk;
	input		reset_reset_n;
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
endmodule
