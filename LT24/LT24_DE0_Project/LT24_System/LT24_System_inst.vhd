	component LT24_System is
		port (
			clk_clk                                      : in    std_logic                     := 'X';             -- clk
			reset_reset_n                                : in    std_logic                     := 'X';             -- reset_n
			sdram_addr                                   : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_ba                                     : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_cas_n                                  : out   std_logic;                                        -- cas_n
			sdram_cke                                    : out   std_logic;                                        -- cke
			sdram_cs_n                                   : out   std_logic;                                        -- cs_n
			sdram_dq                                     : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_dqm                                    : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_ras_n                                  : out   std_logic;                                        -- ras_n
			sdram_we_n                                   : out   std_logic;                                        -- we_n
			pll_sdram_clk                                : out   std_logic;                                        -- clk
			pll_areset_export                            : in    std_logic                     := 'X';             -- export
			pll_locked_export                            : out   std_logic;                                        -- export
			pll_phasedone_export                         : out   std_logic;                                        -- export
			lt24_ctrl_0_lcd_reset_n_export               : out   std_logic;                                        -- export
			lt24_ctrl_0_lcd_on_export                    : out   std_logic;                                        -- export
			lt24_ctrl_0_csx_export                       : out   std_logic;                                        -- export
			lt24_ctrl_0_dcx_export                       : out   std_logic;                                        -- export
			lt24_ctrl_0_wrx_export                       : out   std_logic;                                        -- export
			lt24_ctrl_0_rdx_export                       : out   std_logic;                                        -- export
			lt24_ctrl_0_data_out_export                  : out   std_logic_vector(15 downto 0);                    -- export
			lt24_ctrl_0_wait_request_master_debug_export : out   std_logic;                                        -- export
			lt24_ctrl_0_read_master_debug_export         : out   std_logic;                                        -- export
			lt24_ctrl_0_read_data_master_debug_export    : out   std_logic_vector(31 downto 0);                    -- export
			lt24_ctrl_0_address_master_debug_export      : out   std_logic_vector(31 downto 0);                    -- export
			pll_c2_conduit_export                        : out   std_logic                                         -- export
		);
	end component LT24_System;

	u0 : component LT24_System
		port map (
			clk_clk                                      => CONNECTED_TO_clk_clk,                                      --                                   clk.clk
			reset_reset_n                                => CONNECTED_TO_reset_reset_n,                                --                                 reset.reset_n
			sdram_addr                                   => CONNECTED_TO_sdram_addr,                                   --                                 sdram.addr
			sdram_ba                                     => CONNECTED_TO_sdram_ba,                                     --                                      .ba
			sdram_cas_n                                  => CONNECTED_TO_sdram_cas_n,                                  --                                      .cas_n
			sdram_cke                                    => CONNECTED_TO_sdram_cke,                                    --                                      .cke
			sdram_cs_n                                   => CONNECTED_TO_sdram_cs_n,                                   --                                      .cs_n
			sdram_dq                                     => CONNECTED_TO_sdram_dq,                                     --                                      .dq
			sdram_dqm                                    => CONNECTED_TO_sdram_dqm,                                    --                                      .dqm
			sdram_ras_n                                  => CONNECTED_TO_sdram_ras_n,                                  --                                      .ras_n
			sdram_we_n                                   => CONNECTED_TO_sdram_we_n,                                   --                                      .we_n
			pll_sdram_clk                                => CONNECTED_TO_pll_sdram_clk,                                --                             pll_sdram.clk
			pll_areset_export                            => CONNECTED_TO_pll_areset_export,                            --                            pll_areset.export
			pll_locked_export                            => CONNECTED_TO_pll_locked_export,                            --                            pll_locked.export
			pll_phasedone_export                         => CONNECTED_TO_pll_phasedone_export,                         --                         pll_phasedone.export
			lt24_ctrl_0_lcd_reset_n_export               => CONNECTED_TO_lt24_ctrl_0_lcd_reset_n_export,               --               lt24_ctrl_0_lcd_reset_n.export
			lt24_ctrl_0_lcd_on_export                    => CONNECTED_TO_lt24_ctrl_0_lcd_on_export,                    --                    lt24_ctrl_0_lcd_on.export
			lt24_ctrl_0_csx_export                       => CONNECTED_TO_lt24_ctrl_0_csx_export,                       --                       lt24_ctrl_0_csx.export
			lt24_ctrl_0_dcx_export                       => CONNECTED_TO_lt24_ctrl_0_dcx_export,                       --                       lt24_ctrl_0_dcx.export
			lt24_ctrl_0_wrx_export                       => CONNECTED_TO_lt24_ctrl_0_wrx_export,                       --                       lt24_ctrl_0_wrx.export
			lt24_ctrl_0_rdx_export                       => CONNECTED_TO_lt24_ctrl_0_rdx_export,                       --                       lt24_ctrl_0_rdx.export
			lt24_ctrl_0_data_out_export                  => CONNECTED_TO_lt24_ctrl_0_data_out_export,                  --                  lt24_ctrl_0_data_out.export
			lt24_ctrl_0_wait_request_master_debug_export => CONNECTED_TO_lt24_ctrl_0_wait_request_master_debug_export, -- lt24_ctrl_0_wait_request_master_debug.export
			lt24_ctrl_0_read_master_debug_export         => CONNECTED_TO_lt24_ctrl_0_read_master_debug_export,         --         lt24_ctrl_0_read_master_debug.export
			lt24_ctrl_0_read_data_master_debug_export    => CONNECTED_TO_lt24_ctrl_0_read_data_master_debug_export,    --    lt24_ctrl_0_read_data_master_debug.export
			lt24_ctrl_0_address_master_debug_export      => CONNECTED_TO_lt24_ctrl_0_address_master_debug_export,      --      lt24_ctrl_0_address_master_debug.export
			pll_c2_conduit_export                        => CONNECTED_TO_pll_c2_conduit_export                         --                        pll_c2_conduit.export
		);

