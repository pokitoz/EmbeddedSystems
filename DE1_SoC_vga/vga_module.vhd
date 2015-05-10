library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- VGA Module: Draw 640x480 ARGB8888 frames from a memory framebuffer
-- 8 memory-mapped slave registers:
--     000: framebuffer address (R/W)
--     001: start (1), stop (0) drawing (R/W)
--     010: Vsync irq, read to assert (R)

entity vga_module is
	port(
		clk              : in  std_logic;
		rst_n            : in  std_logic;

		-- 25.175 Pixel Clock for VGA Controller
		pixel_clk        : in  std_logic;

		-- Vsync Interrupt
		vsync_irq        : out std_logic;

		-- Output to VGA DAC
		vga_r            : out std_logic_vector(7 downto 0);
		vga_g            : out std_logic_vector(7 downto 0);
		vga_b            : out std_logic_vector(7 downto 0);
		vga_clk          : out std_logic;
		vga_sync_n       : out std_logic;
		vga_blank_n      : out std_logic;

		-- Direct Output to VGA Connector
		vga_vs           : out std_logic;
		vga_hs           : out std_logic;

		-- Avalon 32-bit Slave Interface
		-- 8 memory-mapped registers
		as_address       : in  std_logic_vector(2 downto 0);
		as_byteenable    : in  std_logic_vector(3 downto 0);
		as_read          : in  std_logic;
		as_readdata      : out std_logic_vector(31 downto 0);
		as_write         : in  std_logic;
		as_writedata     : in  std_logic_vector(31 downto 0);

		-- Avalon 32-bit Master Interface (Read DMA)
		-- Maximum read burst length is 2^(11-1) = 1024
		am_address       : out std_logic_vector(31 downto 0);
		am_byteenable    : out std_logic_vector(3 downto 0);
		am_read          : out std_logic;
		am_burstcount    : out std_logic_vector(10 downto 0);
		am_readdata      : in  std_logic_vector(31 downto 0);
		am_waitrequest   : in  std_logic;
		am_readdatavalid : in  std_logic
	);
end entity vga_module;

architecture structural of vga_module is
	component vga_slave
		port(clk                 : in  std_logic;
			 rst_n               : in  std_logic;
			 vsync_irq           : out std_logic;
			 framebuffer_address : out std_logic_vector(31 downto 0);
			 framebuffer_set     : out std_logic;
			 vga_start           : out std_logic;
			 vga_stop            : out std_logic;
			 vga_vsync           : in  std_logic;
			 as_address          : in  std_logic_vector(2 downto 0);
			 as_byteenable       : in  std_logic_vector(3 downto 0);
			 as_read             : in  std_logic;
			 as_readdata         : out std_logic_vector(31 downto 0);
			 as_write            : in  std_logic;
			 as_writedata        : in  std_logic_vector(31 downto 0));
	end component vga_slave;

	signal slave_to_dma_framebuffer_address : std_logic_vector(31 downto 0);
	signal slave_to_dma_framebuffer_set     : std_logic;

	signal slave_to_controller_start        : std_logic;
	signal slave_to_controller_stop         : std_logic;
	signal controller_to_slave_vsync        : std_logic;
	signal controller_to_dma_start_fetching : std_logic;

	signal dma_to_fifo_clr   : std_logic;
	signal dma_to_fifo_data  : std_logic_vector(31 downto 0);
	signal dma_to_fifo_write : std_logic;
	signal fifo_to_dma_full  : std_logic;
	signal fifo_to_dma_used  : std_logic_vector(5 downto 0);

	signal fifo_to_controller_data  : std_logic_vector(31 downto 0);
	signal fifo_to_controller_empty : std_logic;
	signal controller_to_fifo_read  : std_logic;

	component vga_dma
		port(clk                 : in  std_logic;
			 rst_n               : in  std_logic;
			 framebuffer_address : in  std_logic_vector(31 downto 0);
			 framebuffer_set     : in  std_logic;
			 dma_start_fetching  : in  std_logic;
			 fifo_clr            : out std_logic;
			 fifo_data           : out std_logic_vector(31 downto 0);
			 fifo_write          : out std_logic;
			 fifo_half_full      : in  std_logic;
			 am_address          : out std_logic_vector(31 downto 0);
			 am_byteenable       : out std_logic_vector(3 downto 0);
			 am_read             : out std_logic;
			 am_burstcount       : out std_logic_vector(10 downto 0);
			 am_readdata         : in  std_logic_vector(31 downto 0);
			 am_waitrequest      : in  std_logic;
			 am_readdatavalid    : in  std_logic);
	end component vga_dma;

	component vga_fifo
		port(aclr    : IN  STD_LOGIC := '0';
			 data    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			 rdclk   : IN  STD_LOGIC;
			 rdreq   : IN  STD_LOGIC;
			 wrclk   : IN  STD_LOGIC;
			 wrreq   : IN  STD_LOGIC;
			 q       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			 rdempty : OUT STD_LOGIC;
			 wrfull  : OUT STD_LOGIC;
			 wrusedw : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));
	end component vga_fifo;

	component vga_controller
		port(pixel_clk          : in  std_logic;
			 rst_n              : in  std_logic;
			 start              : in  std_logic;
			 stop               : in  std_logic;
			 dma_start_fetching : out std_logic;
			 vsync              : out std_logic;
			 fifo_empty         : in  std_logic;
			 fifo_read          : out std_logic;
			 fifo_data          : in  std_logic_vector(31 downto 0);
			 vga_r              : out std_logic_vector(7 downto 0);
			 vga_g              : out std_logic_vector(7 downto 0);
			 vga_b              : out std_logic_vector(7 downto 0);
			 vga_clk            : out std_logic;
			 vga_sync_n         : out std_logic;
			 vga_blank_n        : out std_logic;
			 vga_vs             : out std_logic;
			 vga_hs             : out std_logic);
	end component vga_controller;

begin
	vga_slave_inst : component vga_slave
		port map(clk                 => clk,
			     rst_n               => rst_n,
			     vsync_irq           => vsync_irq,
			     framebuffer_address => slave_to_dma_framebuffer_address,
			     framebuffer_set     => slave_to_dma_framebuffer_set,
			     vga_start           => slave_to_controller_start,
			     vga_stop            => slave_to_controller_stop,
			     vga_vsync           => controller_to_slave_vsync,
			     as_address          => as_address,
			     as_byteenable       => as_byteenable,
			     as_read             => as_read,
			     as_readdata         => as_readdata,
			     as_write            => as_write,
			     as_writedata        => as_writedata);

	vga_dma_inst : component vga_dma
		port map(clk                 => clk,
			     rst_n               => rst_n,
			     framebuffer_address => slave_to_dma_framebuffer_address,
			     framebuffer_set     => slave_to_dma_framebuffer_set,
			     dma_start_fetching  => controller_to_dma_start_fetching,
			     fifo_clr            => dma_to_fifo_clr,
			     fifo_data           => dma_to_fifo_data,
			     fifo_write          => dma_to_fifo_write,
			     fifo_half_full      => fifo_to_dma_used(5),
			     am_address          => am_address,
			     am_byteenable       => am_byteenable,
			     am_read             => am_read,
			     am_burstcount       => am_burstcount,
			     am_readdata         => am_readdata,
			     am_waitrequest      => am_waitrequest,
			     am_readdatavalid    => am_readdatavalid);

	vga_fifo_inst : component vga_fifo
		port map(aclr    => dma_to_fifo_clr,
			     data    => dma_to_fifo_data,
			     rdclk   => pixel_clk,
			     rdreq   => controller_to_fifo_read,
			     wrclk   => clk,
			     wrreq   => dma_to_fifo_write,
			     q       => fifo_to_controller_data,
			     rdempty => fifo_to_controller_empty,
			     wrfull  => fifo_to_dma_full,
			     wrusedw => fifo_to_dma_used);

	vga_controller_inst : component vga_controller
		port map(pixel_clk          => pixel_clk,
			     rst_n              => rst_n,
			     start              => slave_to_controller_start,
			     stop               => slave_to_controller_stop,
			     dma_start_fetching => controller_to_dma_start_fetching,
			     vsync              => controller_to_slave_vsync,
			     fifo_empty         => fifo_to_controller_empty,
			     fifo_read          => controller_to_fifo_read,
			     fifo_data          => fifo_to_controller_data,
			     vga_r              => vga_r,
			     vga_g              => vga_g,
			     vga_b              => vga_b,
			     vga_clk            => vga_clk,
			     vga_sync_n         => vga_sync_n,
			     vga_blank_n        => vga_blank_n,
			     vga_vs             => vga_vs,
			     vga_hs             => vga_hs);

end architecture structural;
