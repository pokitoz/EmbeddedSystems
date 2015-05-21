library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- memory-mapped slave registers:
--     00: Flip buffers (R)
--     01: Vsync irq, read to assert (R)

entity vga_slave is
	port(
		clk              : in  std_logic;
		rst_n            : in  std_logic;

		-- Vsync Interrupt
		vsync_irq        : out std_logic;

		-- VGA Controller signals
		vga_vsync        : in  std_logic;

		-- DMA signals
		dma_flip_buffers : out  std_logic;

		-- Avalon 32-bit Slave Interface
		as_address       : in  std_logic_vector(1 downto 0);
		as_writedata	  : in std_logic_vector(31 downto 0);
		as_write         : in  std_logic
	);
end entity vga_slave;

architecture rtl of vga_slave is
	signal clear_vsync_irq : std_logic;

begin
	pr_read : process(clk, rst_n) is
	begin
		if rst_n = '0' then
			clear_vsync_irq <= '0';
			dma_flip_buffers <= '0';
		elsif rising_edge(clk) then
			clear_vsync_irq <= '0';
			dma_flip_buffers <= '0';
			if (as_write = '1') then
				case as_address is
					-- Reading framebuffer address
					when "00" =>
						dma_flip_buffers <= '1';

					-- Clearing vsync irq
					when "01" =>
						clear_vsync_irq <= '1';
					when others => null;
				end case;

			end if;
		end if;
	end process pr_read;

	pr_vsync : process(vga_vsync, rst_n, clear_vsync_irq) is
	begin
		if rst_n = '0' or clear_vsync_irq = '1' then
			vsync_irq <= '0';
		elsif rising_edge(vga_vsync) then
			vsync_irq <= '1';
		end if;
	end process pr_vsync;

end architecture rtl;
