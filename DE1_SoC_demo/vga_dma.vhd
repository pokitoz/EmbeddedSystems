library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_dma is
    port(
        clk                 : in  std_logic;
        rst_n               : in  std_logic;

        -- Image Buffer in memory
        framebuffer_address : in  std_logic_vector(31 downto 0);
        framebuffer_set     : in  std_logic;

        -- signal from vga_controller
        dma_start_fetching  : in  std_logic;

        -- FIFO signals
        fifo_clr            : out std_logic;
        fifo_data           : out std_logic_vector(31 downto 0);
        fifo_write          : out std_logic;
        fifo_full           : out std_logic;
        fifo_used           : out std_logic_vector(7 downto 0);

        -- Avalon 32-bit Master Interface (Read DMA)
        -- Maximum read burst length is 2^(11-1) = 1024
        am_address          : out std_logic_vector(31 downto 0);
        am_byteenable       : out std_logic_vector(3 downto 0);
        am_read             : out std_logic;
        am_burstcount       : out std_logic_vector(10 downto 0);
        am_readdata         : in  std_logic_vector(31 downto 0);
        am_waitrequest      : in  std_logic;
        am_readdatavalid    : in  std_logic
    );
end entity vga_dma;
