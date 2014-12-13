library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE0_NANO is
    port(
        -- CLOCK
        CLOCK_50           : in    std_logic;

        -- LED
        LED                : out   std_logic_vector(7 downto 0);

        -- KEY_N
        KEY_N              : in    std_logic_vector(1 downto 0);

        -- SW_N
        SW_N               : in    std_logic_vector(3 downto 0);

        -- SDRAM
        DRAM_ADDR          : out   std_logic_vector(12 downto 0);
        DRAM_BA            : out   std_logic_vector(1 downto 0);
        DRAM_CAS_N         : out   std_logic;
        DRAM_CKE           : out   std_logic;
        DRAM_CLK           : out   std_logic;
        DRAM_CS_N          : out   std_logic;
        DRAM_DQ            : inout std_logic_vector(15 downto 0);
        DRAM_DQM           : out   std_logic_vector(1 downto 0);
        DRAM_RAS_N         : out   std_logic;
        DRAM_WE_N          : out   std_logic;

        -- GPIO_0, GPIO_0 connected to D5M - 5M Pixel Camera
        GPIO_0_D5M_D       : in    std_logic_vector(11 downto 0);
        GPIO_0_D5M_FVAL    : in    std_logic;
        GPIO_0_D5M_LVAL    : in    std_logic;
        GPIO_0_D5M_PIXCLK  : in    std_logic;
        GPIO_0_D5M_RESET_N : out   std_logic;
        GPIO_0_D5M_SCLK    : inout std_logic;
        GPIO_0_D5M_SDATA   : inout std_logic;
        GPIO_0_D5M_STROBE  : in    std_logic;
        GPIO_0_D5M_TRIGGER : out   std_logic;
        GPIO_0_D5M_XCLKIN  : out   std_logic;
		  
		  -- GPIO_1, GPIO_1 connected to the LT24 - 320x240 ILI9341 LCD
		  GPIO_1_D31			: out std_logic; -- lcd_reset_n
		  GPIO_1_D33			: out std_logic; -- lcd_on
		  GPIO_1_D23			: out std_logic; -- csx
		  GPIO_1_D10			: out std_logic; -- dcx
		  GPIO_1_D9				: out std_logic; -- wrx
		  GPIO_1_D8				: out std_logic; -- rdx
		  GPIO_1_D3			   : out std_logic; -- data_out[3]
		  GPIO_1_D4			   : out std_logic; -- data_out[2]
		  GPIO_1_D5			   : out std_logic; -- data_out[1]
		  GPIO_1_D6			   : out std_logic; -- data_out[0]
		  
		  GPIO_1_D11			: out std_logic; -- data_out[4]
		  GPIO_1_D12			: out std_logic; -- data_out[5]
		  GPIO_1_D13			: out std_logic; -- data_out[6]
		  GPIO_1_D14			: out std_logic; -- data_out[7]
		  GPIO_1_D15			: out std_logic; -- data_out[8]
		  GPIO_1_D16			: out std_logic; -- data_out[9]
		  GPIO_1_D17			: out std_logic; -- data_out[10]
		  GPIO_1_D18			: out std_logic; -- data_out[11]
		  GPIO_1_D19			: out std_logic; -- data_out[12]
		  GPIO_1_D20			: out std_logic; -- data_out[13]
		  GPIO_1_D21			: out std_logic; -- data_out[14]
		  GPIO_1_D22			: out std_logic -- data_out[15]
		  
		  );
end DE0_NANO;

architecture rtl of DE0_NANO is
    component system is
        port(
            clk_clk                                 : in    std_logic                     := 'X';
            reset_reset_n                           : in    std_logic                     := 'X';
            sdram_addr                              : out   std_logic_vector(12 downto 0);
            sdram_ba                                : out   std_logic_vector(1 downto 0);
            sdram_cas_n                             : out   std_logic;
            sdram_cke                               : out   std_logic;
            sdram_cs_n                              : out   std_logic;
            sdram_dq                                : inout std_logic_vector(15 downto 0) := (others => 'X');
            sdram_dqm                               : out   std_logic_vector(1 downto 0);
            sdram_ras_n                             : out   std_logic;
            sdram_we_n                              : out   std_logic;
            camera_interface_0_camera_pixclk_export : in    std_logic                     := 'X';
            camera_interface_0_camera_data_export   : in    std_logic_vector(11 downto 0) := (others => 'X');
            camera_interface_0_camera_lval_export   : in    std_logic                     := 'X';
            camera_interface_0_camera_fval_export   : in    std_logic                     := 'X';
            camera_interface_0_camera_scl_export    : inout std_logic                     := 'X';
            camera_interface_0_camera_sda_export    : inout std_logic                     := 'X';
            pio_leds_export                         : out   std_logic_vector(7 downto 0);
            pio_buttons_export                      : in    std_logic_vector(1 downto 0)  := (others => 'X');
            pio_switches_export                     : in    std_logic_vector(3 downto 0)  := (others => 'X');
            pll_sdram_clk                           : out   std_logic;
            pll_areset_export                       : in    std_logic                     := 'X';
            pll_locked_export                       : out   std_logic;
            pll_phasedone_export                    : out   std_logic;
            pll_camera_clk                          : out   std_logic;
				lt24_ctrl_0_lcd_reset_n_export			 : out std_logic;
				lt24_ctrl_0_lcd_on_export					 : out std_logic;
				lt24_ctrl_0_csx_export						 : out std_logic;
				LT24_CTRL_0_dcx_export						 : out std_logic;
				lt24_ctrl_0_wrx_export						 : out std_logic;
				lt24_ctrl_0_rdx_export						 : out std_logic;
				lt24_ctrl_0_data_out_export				 : out std_logic_vector(15 downto 0)
        );
    end component system;

    signal TRIGGER_BUTTON : std_logic;
    signal RESET_BUTTON_N : std_logic;

begin
    TRIGGER_BUTTON <= not KEY_N(1);
    RESET_BUTTON_N <= KEY_N(0);

    GPIO_0_D5M_TRIGGER <= TRIGGER_BUTTON;
    GPIO_0_D5M_RESET_N <= RESET_BUTTON_N;

    system_inst : component system
        port map(
            clk_clk                                 => CLOCK_50,
            reset_reset_n                           => RESET_BUTTON_N,
            sdram_addr                              => DRAM_ADDR,
            sdram_ba                                => DRAM_BA,
            sdram_cas_n                             => DRAM_CAS_N,
            sdram_cke                               => DRAM_CKE,
            sdram_cs_n                              => DRAM_CS_N,
            sdram_dq                                => DRAM_DQ,
            sdram_dqm                               => DRAM_DQM,
            sdram_ras_n                             => DRAM_RAS_N,
            sdram_we_n                              => DRAM_WE_N,
            camera_interface_0_camera_pixclk_export => GPIO_0_D5M_PIXCLK,
            camera_interface_0_camera_data_export   => GPIO_0_D5M_D,
            camera_interface_0_camera_lval_export   => GPIO_0_D5M_LVAL,
            camera_interface_0_camera_fval_export   => GPIO_0_D5M_FVAL,
            camera_interface_0_camera_scl_export    => GPIO_0_D5M_SCLK,
            camera_interface_0_camera_sda_export    => GPIO_0_D5M_SDATA,
            pio_leds_export                         => LED,
            pio_buttons_export                      => open,
            pio_switches_export                     => SW_N,
            pll_sdram_clk                           => DRAM_CLK,
            pll_areset_export                       => '0',
            pll_locked_export                       => open,
            pll_phasedone_export                    => open,
            pll_camera_clk                          => GPIO_0_D5M_XCLKIN,
				lt24_ctrl_0_lcd_reset_n_export			 => GPIO_1_D31,
				lt24_ctrl_0_lcd_on_export					 => GPIO_1_D33,
				lt24_ctrl_0_csx_export						 => GPIO_1_D23,
				LT24_CTRL_0_dcx_export						 => GPIO_1_D10,
				LT24_ctrl_0_wrx_export						 => GPIO_1_D9,
				lt24_ctrl_0_rdx_export						 => GPIO_1_D8,
				lt24_ctrl_0_data_out_export(3)			 => GPIO_1_D3,
				lt24_ctrl_0_data_out_export(2)			 => GPIO_1_D4,
				lt24_ctrl_0_data_out_export(1)			 => GPIO_1_D5,
				lt24_ctrl_0_data_out_export(0)			 => GPIO_1_D6,
				lt24_ctrl_0_data_out_export(4)			 => GPIO_1_D11,
				lt24_ctrl_0_data_out_export(5)			 => GPIO_1_D12,
				lt24_ctrl_0_data_out_export(6)			 => GPIO_1_D13,
				lt24_ctrl_0_data_out_export(7)			 => GPIO_1_D14,
				lt24_ctrl_0_data_out_export(8)			 => GPIO_1_D15,
				lt24_ctrl_0_data_out_export(9)			 => GPIO_1_D16,
				lt24_ctrl_0_data_out_export(10)			 => GPIO_1_D17,
				lt24_ctrl_0_data_out_export(11)			 => GPIO_1_D18,
				lt24_ctrl_0_data_out_export(12)			 => GPIO_1_D19,
				lt24_ctrl_0_data_out_export(13)			 => GPIO_1_D20,
				lt24_ctrl_0_data_out_export(14)			 => GPIO_1_D21,
				lt24_ctrl_0_data_out_export(15)			 => GPIO_1_D22
        );

end architecture;
