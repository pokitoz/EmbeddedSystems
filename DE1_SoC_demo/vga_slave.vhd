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
		framebuffer_address : out std_logic_vector(31 downto 0);
		framebuffer_set     : out std_logic;

		-- VGA Controller signals
		vga_start           : out std_logic;
		vga_stop            : out std_logic;
		vga_vsync           : in  std_logic;

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

architecture rtl of vga_slave is
	signal framebuffer_address_reg : std_logic_vector(31 downto 0);
	signal command_reg             : std_logic_vector(31 downto 0);

begin
	pr_read : process(clk, rst_n) is
	begin
		if rst_n = '0' then
			as_readdata <= (others => '0');
		elsif rising_edge(clk) then
			as_readdata <= (others => '0');
			if (as_read = '1') then
				case as_address is
					-- Reading framebuffer address
					when "000" =>
						as_readdata <= framebuffer_address_reg;
					-- Reading command register
					when "001" =>
						as_readdata <= command_reg;
					when others => null;
				end case;

			end if;
		end if;
	end process pr_read;

	pr_write : process(clk, rst_n) is
	begin
		if rst_n = '0' then
			framebuffer_address_reg <= (others => '0');
			command_reg             <= (others => '0');
			framebuffer_address     <= (others => '0');
			framebuffer_set         <= '0';
			vga_start               <= '0';
			vga_stop                <= '0';
		elsif rising_edge(clk) then
			framebuffer_address <= (others => '0');
			framebuffer_set     <= '0';
			vga_start           <= '0';
			vga_stop            <= '0';
			if (as_write = '1') then
				case as_address is
					-- Writing framebuffer address
					when "000" =>
						framebuffer_address_reg <= as_writedata;
						framebuffer_address     <= as_writedata;
						framebuffer_set         <= '1';
					-- Writing command register
					when "001" =>
						command_reg <= (31 downto 1 => '0') & as_writedata(0);
						if (as_writedata(0) = '1') then -- start
							vga_start <= '1';
						else            -- stop
							vga_stop <= '1';
						end if;
					when others => null;
				end case;

			end if;
		end if;
	end process pr_write;

end architecture rtl;

