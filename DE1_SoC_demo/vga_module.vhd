library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_module is
    port(
        clk              : in  std_logic;
        rst_n            : in  std_logic;

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
