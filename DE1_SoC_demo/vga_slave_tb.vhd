library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_slave_tb is
end entity vga_slave_tb;

architecture testbench of vga_slave_tb is
    constant period : time      := 20 ns;
    signal clk      : std_logic := '0';
    signal rst_n    : std_logic := '0';
    signal stop     : boolean   := false;

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

    signal vsync_irq           : std_logic;
    signal framebuffer_address : std_logic_vector(31 downto 0);
    signal framebuffer_set     : std_logic;
    signal vga_start           : std_logic;
    signal vga_stop            : std_logic;
    signal vga_vsync           : std_logic;
    signal as_address          : std_logic_vector(2 downto 0);
    signal as_byteenable       : std_logic_vector(3 downto 0);
    signal as_read             : std_logic;
    signal as_readdata         : std_logic_vector(31 downto 0);
    signal as_write            : std_logic;
    signal as_writedata        : std_logic_vector(31 downto 0);

begin
    clk   <= not clk after period / 2 when not stop else '0';
    rst_n <= '1' after period when not stop else '1';

    duv : component vga_slave
        port map(clk                 => clk,
                 rst_n               => rst_n,
                 vsync_irq           => vsync_irq,
                 framebuffer_address => framebuffer_address,
                 framebuffer_set     => framebuffer_set,
                 vga_start           => vga_start,
                 vga_stop            => vga_stop,
                 vga_vsync           => vga_vsync,
                 as_address          => as_address,
                 as_byteenable       => as_byteenable,
                 as_read             => as_read,
                 as_readdata         => as_readdata,
                 as_write            => as_write,
                 as_writedata        => as_writedata);

    test : process is
    begin
        wait for 2 * period;

        stop <= true;
        wait;
    end process test;

end architecture testbench;
