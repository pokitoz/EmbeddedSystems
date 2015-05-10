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
		fifo_half_full      : in  std_logic;

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

architecture rtl of vga_dma is
	type state_type is (IDLE, START_BURST, IN_BURST);
	signal state_reg, state_next                             : state_type;
	signal remaining_reg, remaining_next                     : integer;
	signal pixels_done_reg, pixels_done_next                 : std_logic_vector(31 downto 0);
	signal framebuffer_address_reg, framebuffer_address_next : unsigned(31 downto 0);
	constant BURST_SIZE                                      : integer := 32;
	signal burst_remaining_reg, burst_remaining_next         : integer;

begin
	framebuffer_address_next <= unsigned(framebuffer_address) when framebuffer_set = '1' else framebuffer_address_reg;

	state_machine : process(state_reg, am_readdatavalid, am_waitrequest, burst_remaining_reg, dma_start_fetching, fifo_half_full, framebuffer_address_reg, pixels_done_reg, pixels_done_reg(29 downto 0), remaining_reg, am_readdata) is
	begin
		fifo_clr   <= '0';
		fifo_write <= '0';
		fifo_data  <= (others => '0');

		am_address    <= (others => '0');
		am_burstcount <= (others => '0');
		am_byteenable <= "1111";
		am_read       <= '0';

		pixels_done_next     <= pixels_done_reg;
		remaining_next       <= remaining_reg;
		burst_remaining_next <= burst_remaining_reg;

		state_next <= state_reg;

		case state_reg is
			when IDLE =>
				if (dma_start_fetching = '1') then
					state_next       <= START_BURST;
					fifo_clr         <= '1';
					pixels_done_next <= (others => '0');
					remaining_next   <= 640 * 480;
				end if;
			when START_BURST =>
				if (remaining_reg = 0) then
					state_next <= IDLE;
				elsif (fifo_half_full = '0') then
					am_read              <= '1';
					am_burstcount        <= std_logic_vector(to_unsigned(BURST_SIZE, 11));
					am_address           <= std_logic_vector(framebuffer_address_reg + unsigned((pixels_done_reg(29 downto 0) & "00")));
					burst_remaining_next <= BURST_SIZE;
					if (am_waitrequest = '0') then
						state_next <= IN_BURST;
					end if;
				end if;
			when IN_BURST =>
				if (burst_remaining_reg = 0) then
					state_next <= START_BURST;
				elsif (am_readdatavalid = '1') then
					burst_remaining_next <= burst_remaining_reg - 1;
					remaining_next       <= remaining_reg - 1;
					pixels_done_next     <= std_logic_vector(unsigned(pixels_done_reg) + 1);
					burst_remaining_next <= burst_remaining_reg - 1;
					fifo_data            <= am_readdata;
					fifo_write           <= '1';
				end if;
		end case;
	end process state_machine;

	pr_reg : process(clk, rst_n) is
	begin
		if rst_n = '0' then
			state_reg               <= IDLE;
			remaining_reg           <= 0;
			pixels_done_reg         <= (others => '0');
			burst_remaining_reg     <= 0;
			framebuffer_address_reg <= (others => '0');
		elsif rising_edge(clk) then
			state_reg               <= state_next;
			remaining_reg           <= remaining_next;
			pixels_done_reg         <= pixels_done_next;
			burst_remaining_reg     <= burst_remaining_next;
			framebuffer_address_reg <= framebuffer_address_next;
		end if;
	end process pr_reg;

end architecture rtl;

