	LT24_System u0 (
		.clk_clk                                      (<connected-to-clk_clk>),                                      //                                   clk.clk
		.reset_reset_n                                (<connected-to-reset_reset_n>),                                //                                 reset.reset_n
		.sdram_addr                                   (<connected-to-sdram_addr>),                                   //                                 sdram.addr
		.sdram_ba                                     (<connected-to-sdram_ba>),                                     //                                      .ba
		.sdram_cas_n                                  (<connected-to-sdram_cas_n>),                                  //                                      .cas_n
		.sdram_cke                                    (<connected-to-sdram_cke>),                                    //                                      .cke
		.sdram_cs_n                                   (<connected-to-sdram_cs_n>),                                   //                                      .cs_n
		.sdram_dq                                     (<connected-to-sdram_dq>),                                     //                                      .dq
		.sdram_dqm                                    (<connected-to-sdram_dqm>),                                    //                                      .dqm
		.sdram_ras_n                                  (<connected-to-sdram_ras_n>),                                  //                                      .ras_n
		.sdram_we_n                                   (<connected-to-sdram_we_n>),                                   //                                      .we_n
		.pll_sdram_clk                                (<connected-to-pll_sdram_clk>),                                //                             pll_sdram.clk
		.pll_areset_export                            (<connected-to-pll_areset_export>),                            //                            pll_areset.export
		.pll_locked_export                            (<connected-to-pll_locked_export>),                            //                            pll_locked.export
		.pll_phasedone_export                         (<connected-to-pll_phasedone_export>),                         //                         pll_phasedone.export
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
		.lt24_ctrl_0_address_master_debug_export      (<connected-to-lt24_ctrl_0_address_master_debug_export>),      //      lt24_ctrl_0_address_master_debug.export
		.pll_c2_conduit_export                        (<connected-to-pll_c2_conduit_export>)                         //                        pll_c2_conduit.export
	);

