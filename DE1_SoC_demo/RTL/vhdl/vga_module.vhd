library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_module is
    port(
        clk            : in  std_logic;
        rst_n          : in  std_logic;

        -- 25MHz Pixel Clock for VGA Controller
        pixel_clk      : in  std_logic;

        -- Output to VGA DAC
        vga_r          : out std_logic_vector(7 downto 0);
        vga_g          : out std_logic_vector(7 downto 0);
        vga_b          : out std_logic_vector(7 downto 0);
        vga_clk        : out std_logic;
        vga_sync_n     : out std_logic;
        vga_blank_n    : out std_logic;

        -- Direct Output to VGA Connector
        vga_vs         : out std_logic;
        vga_hs         : out std_logic;

        -- Avalon 32-bit Master Interface (Read DMA)
        am_address     : out std_logic_vector(31 downto 0);
        am_byteenable  : out std_logic_vector(3 downto 0);
        am_read        : out std_logic;
        am_readdata    : in  std_logic_vector(31 downto 0);
        am_waitrequest : in  std_logic;
        
        -- Avalon 32-bit Slave Interface
		as_address       : in  std_logic_vector(1 downto 0);
		as_readdata		  : out std_logic_vector(31 downto 0);
		as_read          : in  std_logic;
		
		-- Vsync Interrupt
		vsync_irq        : out std_logic
    );
end entity vga_module;

architecture structural of vga_module is
    component vga_dma
        port(clk                : in  std_logic;
             rst_n              : in  std_logic;
             dma_flip_buffers   : in std_logic;
             dma_start_fetching : in  std_logic;
             fifo_clr           : out std_logic;
             fifo_data          : out std_logic_vector(31 downto 0);
             fifo_write         : out std_logic;
             fifo_full          : in  std_logic;
             am_address         : out std_logic_vector(31 downto 0);
             am_byteenable      : out std_logic_vector(3 downto 0);
             am_read            : out std_logic;
             am_readdata        : in  std_logic_vector(31 downto 0);
             am_waitrequest     : in  std_logic);
    end component vga_dma;

    component vga_fifo
        port(aclr    : IN  STD_LOGIC := '0';
             data    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
             rdclk   : IN  STD_LOGIC;
             rdreq   : IN  STD_LOGIC;
             wrclk   : IN  STD_LOGIC;
             wrreq   : IN  STD_LOGIC;
             q       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
             rdempty : OUT STD_LOGIC;
             wrfull  : OUT STD_LOGIC);
    end component vga_fifo;

    component vga_controller
        port(pixel_clk          : in  std_logic;
             rst_n              : in  std_logic;
             dma_start_fetching : out std_logic;
             vsync              : out std_logic;
             fifo_empty         : in  std_logic;
             fifo_read          : out std_logic;
             fifo_data          : in  std_logic_vector(7 downto 0);
             vga_r              : out std_logic_vector(7 downto 0);
             vga_g              : out std_logic_vector(7 downto 0);
             vga_b              : out std_logic_vector(7 downto 0);
             vga_clk            : out std_logic;
             vga_sync_n         : out std_logic;
             vga_blank_n        : out std_logic;
             vga_vs             : out std_logic;
             vga_hs             : out std_logic);
    end component vga_controller;
    signal fifo_clr           : std_logic;
    signal fifo_writedata     : std_logic_vector(31 downto 0);
    signal fifo_write         : std_logic;
    signal fifo_full          : std_logic;
    signal dma_start_fetching : std_logic;
    signal fifo_read          : STD_LOGIC;
    signal fifo_readdata      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal fifo_empty         : STD_LOGIC;
    
    component vga_slave
    	port(clk              : in  std_logic;
    		 rst_n            : in  std_logic;
    		 vsync_irq        : out std_logic;
    		 vga_vsync        : in  std_logic;
    		 dma_flip_buffers : out std_logic;
    		 as_address       : in  std_logic_vector(1 downto 0);
			 as_readdata		  : out std_logic_vector(31 downto 0);
    		 as_read          : in  std_logic);
    end component vga_slave;
    
    signal dma_flip_buffers : std_logic;
    signal vga_vsync : std_logic;

begin
    vga_dma_inst : component vga_dma
        port map(clk                => clk,
                 rst_n              => rst_n,
                 dma_flip_buffers   => dma_flip_buffers,
                 dma_start_fetching => dma_start_fetching,
                 fifo_clr           => fifo_clr,
                 fifo_data          => fifo_writedata,
                 fifo_write         => fifo_write,
                 fifo_full          => fifo_full,
                 am_address         => am_address,
                 am_byteenable      => am_byteenable,
                 am_read            => am_read,
                 am_readdata        => am_readdata,
                 am_waitrequest     => am_waitrequest);

    vga_fifo_inst : component vga_fifo
        port map(aclr    => fifo_clr,
                 data    => fifo_writedata,
                 rdclk   => pixel_clk,
                 rdreq   => fifo_read,
                 wrclk   => clk,
                 wrreq   => fifo_write,
                 q       => fifo_readdata,
                 rdempty => fifo_empty,
                 wrfull  => fifo_full);

    vga_controller_inst : component vga_controller
        port map(pixel_clk          => pixel_clk,
                 rst_n              => rst_n,
                 dma_start_fetching => dma_start_fetching,
                 vsync              => vga_vsync,
                 fifo_empty         => fifo_empty,
                 fifo_read          => fifo_read,
                 fifo_data          => fifo_readdata,
                 vga_r              => vga_r,
                 vga_g              => vga_g,
                 vga_b              => vga_b,
                 vga_clk            => vga_clk,
                 vga_sync_n         => vga_sync_n,
                 vga_blank_n        => vga_blank_n,
                 vga_vs             => vga_vs,
                 vga_hs             => vga_hs);
                 
    vga_slave_inst : component vga_slave
    	port map(
    		clk              => clk,
    		rst_n            => rst_n,
    		vsync_irq        => vsync_irq,
    		vga_vsync        => vga_vsync,
    		dma_flip_buffers => dma_flip_buffers,
    		as_address       => as_address,
			as_readdata		  => as_readdata,
    		as_read          => as_read
    	);

end architecture structural;

