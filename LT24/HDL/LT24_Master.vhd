library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Master is
	port(
		clk             : in  std_logic;
		reset_n         : in  std_logic;
		-- Avalon signals
		address         : out std_logic_vector(31 downto 0);
		read            : out std_logic;
		read_data       : in  std_logic_vector(31 downto 0);
		wait_request    : in  std_logic;
		-- Avalon burst signals
		burst_cnt       : out std_logic_vector(6 downto 0);
		read_data_valid : in  std_logic;
		-- LT24 Slave signals
		start_dma       : in  std_logic;
		address_dma     : in  std_logic_vector(31 downto 0);
		len_dma         : in  std_logic_vector(31 downto 0);
		-- FIFO signals
		write_fifo      : out std_logic;
		write_data      : out std_logic_vector(31 downto 0);
		fifo_full       : in  std_logic;
		fifo_free_cnt   : in  std_logic_vector(6 downto 0);
		-- LT24 Interface signals
		running         : out std_logic
	);
end entity LT24_Master;

architecture RTL of LT24_Master is
	type state_type is (IDLE, READ_REQUEST, READ_AVAILABLE);
	signal state_reg, state_next             : state_type;
	signal address_dma_reg, address_dma_next : std_logic_vector(31 downto 0);
	signal len_dma_reg, len_dma_next         : unsigned(31 downto 0);
begin
	address   <= address_dma;
	burst_cnt <= (others => '0');

	state_machine : process(state_reg, address_dma, len_dma, start_dma, fifo_full, len_dma_reg, read_data, wait_request, address_dma_reg) is
	begin
		state_next       <= state_reg;
		running          <= '1';
		read             <= '0';
		write_fifo       <= '0';
		write_data       <= (others => '0');
		address_dma_next <= address_dma_reg;
		len_dma_next     <= len_dma_reg;
		case state_reg is
			when IDLE =>
				running <= '0';
				if (start_dma = '1') then
					running          <= '1';
					address_dma_next <= address_dma;
					len_dma_next     <= unsigned(len_dma);
					state_next       <= READ_REQUEST;
				end if;
			when READ_REQUEST =>
				read <= '1';
				if (wait_request = '0') then
					state_next <= READ_AVAILABLE;
				end if;
			when READ_AVAILABLE =>
				if (fifo_full = '0') then
					write_fifo <= '1';
					write_data <= read_data;
					state_next <= READ_REQUEST;
					if (len_dma_reg = X"00000001") then
						state_next <= IDLE;
					end if;
					len_dma_next <= len_dma_reg - 1;
				end if;
		end case;
	end process state_machine;

	reg_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			state_reg       <= IDLE;
			address_dma_reg <= (others => '0');
			len_dma_reg     <= (others => '0');
		elsif rising_edge(clk) then
			state_reg       <= state_next;
			address_dma_reg <= address_dma_next;
			len_dma_reg     <= len_dma_next;
		end if;
	end process reg_process;

end architecture RTL;
