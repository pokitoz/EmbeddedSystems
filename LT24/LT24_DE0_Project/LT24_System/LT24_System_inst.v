	LT24_System u0 (
		.clk_clk                                      (<connected-to-clk_clk>),                                      //                                   clk.clk
		.reset_reset_n                                (<connected-to-reset_reset_n>),                                //                                 reset.reset_n
		.lt24_ctrl_0_lcd_reset_n_export               (<connected-to-lt24_ctrl_0_lcd_reset_n_export>),               //               lt24_ctrl_0_lcd_reset_n.export
		.lt24_ctrl_0_lcd_on_export                    (<connected-to-lt24_ctrl_0_lcd_on_export>),                    //                    lt24_ctrl_0_lcd_on.export
		.lt24_ctrl_0_csx_export                       (<connected-to-lt24_ctrl_0_csx_export>),                       //                       lt24_ctrl_0_csx.export
		.lt24_ctrl_0_dcx_export                       (<connected-to-lt24_ctrl_0_dcx_export>),                       //                       lt24_ctrl_0_dcx.export
		.lt24_ctrl_0_wrx_export                       (<connected-to-lt24_ctrl_0_wrx_export>),                       //                       lt24_ctrl_0_wrx.export
		.lt24_ctrl_0_rdx_export                       (<connected-to-lt24_ctrl_0_rdx_export>),                       //                       lt24_ctrl_0_rdx.export
		.lt24_ctrl_0_data_out_export                  (<connected-to-lt24_ctrl_0_data_out_export>),                  //                  lt24_ctrl_0_data_out.export
		.lt24_ctrl_0_wait_request_master_debug_export (<connected-to-lt24_ctrl_0_wait_request_master_debug_export>), // lt24_ctrl_0_wait_request_master_debug.export
		.lt24_ctrl_0_read_master_debug_export         (<connected-to-lt24_ctrl_0_read_master_debug_export>),         //         lt24_ctrl_0_read_master_debug.export
		.lt24_ctrl_0_read_data_master_debug_export    (<connected-to-lt24_ctrl_0_read_data_master_debug_export>),    //    lt24_ctrl_0_read_data_master_debug.export
		.lt24_ctrl_0_address_master_debug_export      (<connected-to-lt24_ctrl_0_address_master_debug_export>)       //      lt24_ctrl_0_address_master_debug.export
	);

