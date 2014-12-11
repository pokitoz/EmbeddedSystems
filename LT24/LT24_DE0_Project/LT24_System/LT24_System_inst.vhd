	component LT24_System is
		port (
			clk_clk                                      : in  std_logic                     := 'X'; -- clk
			reset_reset_n                                : in  std_logic                     := 'X'; -- reset_n
			lt24_ctrl_0_lcd_reset_n_export               : out std_logic;                            -- export
			lt24_ctrl_0_lcd_on_export                    : out std_logic;                            -- export
			lt24_ctrl_0_csx_export                       : out std_logic;                            -- export
			lt24_ctrl_0_dcx_export                       : out std_logic;                            -- export
			lt24_ctrl_0_wrx_export                       : out std_logic;                            -- export
			lt24_ctrl_0_rdx_export                       : out std_logic;                            -- export
			lt24_ctrl_0_data_out_export                  : out std_logic_vector(15 downto 0);        -- export
			lt24_ctrl_0_wait_request_master_debug_export : out std_logic;                            -- export
			lt24_ctrl_0_read_master_debug_export         : out std_logic;                            -- export
			lt24_ctrl_0_read_data_master_debug_export    : out std_logic_vector(31 downto 0);        -- export
			lt24_ctrl_0_address_master_debug_export      : out std_logic_vector(31 downto 0)         -- export
		);
	end component LT24_System;

	u0 : component LT24_System
		port map (
			clk_clk                                      => CONNECTED_TO_clk_clk,                                      --                                   clk.clk
			reset_reset_n                                => CONNECTED_TO_reset_reset_n,                                --                                 reset.reset_n
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
			lt24_ctrl_0_address_master_debug_export      => CONNECTED_TO_lt24_ctrl_0_address_master_debug_export       --      lt24_ctrl_0_address_master_debug.export
		);

