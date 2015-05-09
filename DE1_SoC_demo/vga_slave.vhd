library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 8 memory-mapped slave registers:
--     000: framebuffer address (R/W)
--     001: start (1), stop (0) drawing (R/W)
--     010: Vsync irq, read to assert (R)

entity vga_slave is
    port(
        clk                 : in  std_logic;
        rst_n               : in  std_logic;

        -- Vsync Interrupt
        vsync_irq           : out std_logic;

        -- DMA Signals
        framebuffer_address : out  std_logic_vector(31 downto 0);
        framebuffer_set     : out  std_logic;

        -- VGA Controller signals
        vga_start           : out std_logic;
        vga_stop            : out std_logic;
        vga_vsync           : in std_logic;

        -- Avalon 32-bit Slave Interface
        -- 8 memory-mapped registers
        as_address          : in  std_logic_vector(2 downto 0);
        as_byteenable       : in  std_logic_vector(3 downto 0);
        as_read             : in  std_logic;
        as_readdata         : out std_logic_vector(31 downto 0);
        as_write            : in  std_logic;
        as_writedata        : in  std_logic_vector(31 downto 0)
    );
end entity vga_slave;
