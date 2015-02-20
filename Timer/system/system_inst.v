	system u0 (
		.clk_clk                      (<connected-to-clk_clk>),                      //                   clk.clk
		.leds_export                  (<connected-to-leds_export>),                  //                  leds.export
		.pll_areset_conduit_export    (<connected-to-pll_areset_conduit_export>),    //    pll_areset_conduit.export
		.pll_locked_conduit_export    (<connected-to-pll_locked_conduit_export>),    //    pll_locked_conduit.export
		.pll_phasedone_conduit_export (<connected-to-pll_phasedone_conduit_export>), // pll_phasedone_conduit.export
		.pll_sdram_clk_clk            (<connected-to-pll_sdram_clk_clk>),            //         pll_sdram_clk.clk
		.reset_reset_n                (<connected-to-reset_reset_n>),                //                 reset.reset_n
		.sdram_wire_addr              (<connected-to-sdram_wire_addr>),              //            sdram_wire.addr
		.sdram_wire_ba                (<connected-to-sdram_wire_ba>),                //                      .ba
		.sdram_wire_cas_n             (<connected-to-sdram_wire_cas_n>),             //                      .cas_n
		.sdram_wire_cke               (<connected-to-sdram_wire_cke>),               //                      .cke
		.sdram_wire_cs_n              (<connected-to-sdram_wire_cs_n>),              //                      .cs_n
		.sdram_wire_dq                (<connected-to-sdram_wire_dq>),                //                      .dq
		.sdram_wire_dqm               (<connected-to-sdram_wire_dqm>),               //                      .dqm
		.sdram_wire_ras_n             (<connected-to-sdram_wire_ras_n>),             //                      .ras_n
		.sdram_wire_we_n              (<connected-to-sdram_wire_we_n>)               //                      .we_n
	);

