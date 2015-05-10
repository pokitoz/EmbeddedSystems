library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_slave_tb is
end entity vga_slave_tb;

architecture testbench of vga_slave_tb is
	constant PERIOD : time      := 20 ns;
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
	signal vga_vsync           : std_logic                     := '0';
	signal as_address          : std_logic_vector(2 downto 0)  := "000";
	signal as_byteenable       : std_logic_vector(3 downto 0)  := "1111";
	signal as_read             : std_logic                     := '0';
	signal as_readdata         : std_logic_vector(31 downto 0) := X"00000000";
	signal as_write            : std_logic                     := '0';
	signal as_writedata        : std_logic_vector(31 downto 0) := X"00000000";

	constant REG_ADDRESS     : std_logic_vector(as_address'range)   := "000";
	constant EXAMPLE_ADDRESS : std_logic_vector(as_writedata'range) := X"12345678";
	constant REG_COMMAND     : std_logic_vector(as_address'range)   := "001";
	constant COMMAND_START   : std_logic_vector(as_writedata'range) := X"00000001";
	constant COMMAND_STOP    : std_logic_vector(as_writedata'range) := X"00000000";
	constant REG_VSYNC       : std_logic_vector(as_address'range)   := "010";

begin
	clk   <= not clk after PERIOD / 2 when not stop else '0';
	rst_n <= '1' after PERIOD when not stop else '1';

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
		procedure write_register(
			reg   : std_logic_vector(as_address'range);
			value : std_logic_vector(as_writedata'range)) is
		begin
			as_address   <= reg;
			as_write     <= '1';
			as_writedata <= value;
			wait for PERIOD;
			as_address   <= (others => '0');
			as_write     <= '0';
			as_writedata <= (others => '0');
		end procedure write_register;

		procedure assert_read(
			reg      : std_logic_vector(as_address'range);
			expected : std_logic_vector(as_writedata'range)) is
		begin
			as_address <= reg;
			as_read    <= '1';
			wait for PERIOD;
			as_read    <= '0';
			as_address <= (others => '0');
			wait until rising_edge(clk);
			assert as_readdata = expected report "Read: expected " & integer'image(to_integer(unsigned(expected))) & " but was " & integer'image(to_integer(unsigned(as_readdata))) severity error;
			wait for PERIOD / 4;
		end procedure assert_read;

	begin
		wait for 2 * PERIOD;
		wait for (PERIOD / 2) + (PERIOD / 4);

		-- Write the address should force the slave to write it to the DMA unit
		write_register(REG_ADDRESS, EXAMPLE_ADDRESS);
		wait until rising_edge(clk);
		assert framebuffer_address = EXAMPLE_ADDRESS report "Framebuffer address: expected " & integer'image(to_integer(unsigned(EXAMPLE_ADDRESS))) & " but was " & integer'image(to_integer(unsigned(framebuffer_address))) severity error;
		assert framebuffer_set = '1' report "Framebuffer_set is not set" severity error;
		wait for PERIOD / 4;
		assert_read(REG_ADDRESS, X"12345678");

		-- Command register should be cleared initially
		assert_read(REG_COMMAND, COMMAND_STOP);

		-- Start VGA system
		assert vga_start = '0' report "vga_start not cleared before use" severity error;
		write_register(REG_COMMAND, COMMAND_START);
		wait until rising_edge(clk);
		assert vga_start = '1' report "vga_start not set" severity error;
		wait for PERIOD / 4;
		assert vga_start = '0' report "vga_start not cleared after use" severity error;
		assert_read(REG_COMMAND, COMMAND_START);

		-- Stop VGA system
		assert vga_stop = '0' report "vga_stop not cleared before use" severity error;
		write_register(REG_COMMAND, COMMAND_STOP);
		wait until rising_edge(clk);
		assert vga_stop = '1' report "vga_stop not set" severity error;
		wait for PERIOD / 4;
		assert vga_stop = '0' report "vga_stop not cleared after use" severity error;
		assert_read(REG_COMMAND, COMMAND_STOP);

		-- Testing IRQ coming from a slower system (long irq pulse)
		assert vsync_irq = '0' report "vsync_irq not cleared before" severity error;
		vga_vsync <= '1';
		wait for period / 4;
		assert vsync_irq = '1' report "vsync_irq not set right after vsync" severity error;
		wait until rising_edge(clk);
		assert vsync_irq = '1' report "vsync_irq not set right after rising edge" severity error;
		wait for period / 4;
		assert_read(REG_VSYNC, X"00000000");
		assert vsync_irq = '0' report "vsync_irq not cleared after reading" severity error;
		wait for 4 * period;
		assert vsync_irq = '0' report "vsync_irq came back from the dead !" severity error;
		vga_vsync <= '0';

		stop <= true;
		wait;
	end process test;

end architecture testbench;
