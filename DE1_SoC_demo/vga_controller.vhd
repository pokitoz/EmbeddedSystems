library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port(

        -- 25.175 MHz pixel clock
        pixel_clk          : in  std_logic;
        rst_n              : in  std_logic;

        -- Start drawing frames
        start              : in  std_logic;

        -- Stop and reset the controller to the default state
        stop               : in  std_logic;

        -- Tell DMA to start prefetching
        dma_start_fetching : out std_logic;

        -- Tell system of vsync
        vsync              : out std_logic;

        -- FIFO Signals
        fifo_empty         : in  std_logic;
        fifo_read          : out std_logic;
        fifo_data          : in  std_logic_vector(31 downto 0);

        -- Output to VGA DAC
        vga_r              : out std_logic_vector(7 downto 0);
        vga_g              : out std_logic_vector(7 downto 0);
        vga_b              : out std_logic_vector(7 downto 0);
        vga_clk            : out std_logic;
        vga_sync_n         : out std_logic;
        vga_blank_n        : out std_logic;

        -- Direct Output to VGA Connector
        vga_vs             : out std_logic;
        vga_hs             : out std_logic
    );
end entity vga_controller;
