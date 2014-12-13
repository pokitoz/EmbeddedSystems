	system u0 (
		.clk_clk                                 (<connected-to-clk_clk>),                                 //                              clk.clk
		.reset_reset_n                           (<connected-to-reset_reset_n>),                           //                            reset.reset_n
		.sdram_addr                              (<connected-to-sdram_addr>),                              //                            sdram.addr
		.sdram_ba                                (<connected-to-sdram_ba>),                                //                                 .ba
		.sdram_cas_n                             (<connected-to-sdram_cas_n>),                             //                                 .cas_n
		.sdram_cke                               (<connected-to-sdram_cke>),                               //                                 .cke
		.sdram_cs_n                              (<connected-to-sdram_cs_n>),                              //                                 .cs_n
		.sdram_dq                                (<connected-to-sdram_dq>),                                //                                 .dq
		.sdram_dqm                               (<connected-to-sdram_dqm>),                               //                                 .dqm
		.sdram_ras_n                             (<connected-to-sdram_ras_n>),                             //                                 .ras_n
		.sdram_we_n                              (<connected-to-sdram_we_n>),                              //                                 .we_n
		.pio_leds_export                         (<connected-to-pio_leds_export>),                         //                         pio_leds.export
		.pio_buttons_export                      (<connected-to-pio_buttons_export>),                      //                      pio_buttons.export
		.pio_switches_export                     (<connected-to-pio_switches_export>),                     //                     pio_switches.export
		.pll_sdram_clk                           (<connected-to-pll_sdram_clk>),                           //                        pll_sdram.clk
		.pll_areset_export                       (<connected-to-pll_areset_export>),                       //                       pll_areset.export
		.pll_locked_export                       (<connected-to-pll_locked_export>),                       //                       pll_locked.export
		.pll_phasedone_export                    (<connected-to-pll_phasedone_export>),                    //                    pll_phasedone.export
		.pll_camera_clk                          (<connected-to-pll_camera_clk>),                          //                       pll_camera.clk
		.camera_interface_0_camera_pixclk_export (<connected-to-camera_interface_0_camera_pixclk_export>), // camera_interface_0_camera_pixclk.export
		.camera_interface_0_camera_data_export   (<connected-to-camera_interface_0_camera_data_export>),   //   camera_interface_0_camera_data.export
		.camera_interface_0_camera_lval_export   (<connected-to-camera_interface_0_camera_lval_export>),   //   camera_interface_0_camera_lval.export
		.camera_interface_0_camera_fval_export   (<connected-to-camera_interface_0_camera_fval_export>),   //   camera_interface_0_camera_fval.export
		.camera_interface_0_camera_scl_export    (<connected-to-camera_interface_0_camera_scl_export>),    //    camera_interface_0_camera_scl.export
		.camera_interface_0_camera_sda_export    (<connected-to-camera_interface_0_camera_sda_export>),    //    camera_interface_0_camera_sda.export
		.lt24_ctrl_0_lcd_reset_n_export          (<connected-to-lt24_ctrl_0_lcd_reset_n_export>),          //          lt24_ctrl_0_lcd_reset_n.export
		.lt24_ctrl_0_lcd_on_export               (<connected-to-lt24_ctrl_0_lcd_on_export>),               //               lt24_ctrl_0_lcd_on.export
		.lt24_ctrl_0_csx_export                  (<connected-to-lt24_ctrl_0_csx_export>),                  //                  lt24_ctrl_0_csx.export
		.lt24_ctrl_0_wrx_export                  (<connected-to-lt24_ctrl_0_wrx_export>),                  //                  lt24_ctrl_0_wrx.export
		.lt24_ctrl_0_rdx_export                  (<connected-to-lt24_ctrl_0_rdx_export>),                  //                  lt24_ctrl_0_rdx.export
		.lt24_ctrl_0_data_out_export             (<connected-to-lt24_ctrl_0_data_out_export>),             //             lt24_ctrl_0_data_out.export
		.lt24_ctrl_0_dcx_export                  (<connected-to-lt24_ctrl_0_dcx_export>)                   //                  lt24_ctrl_0_dcx.export
	);

