library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Interface is
	port(
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		-- LT24 Slave signals
		start_single : in  std_logic;
		data_cmd_n   : in  std_logic;
		data_in      : in  std_logic_vector(15 downto 0);
		busy         : out std_logic;
		-- LT24 board signals
		csx          : out std_logic;
		dcx          : out std_logic;
		wrx          : out std_logic;
		rdx          : out std_logic;
		data_out     : out std_logic_vector(15 downto 0);
		-- LT24 Master signals
		running      : in  std_logic;
		-- FIFO signals
		read_fifo    : out std_logic;
		read_data    : in  std_logic_vector(15 downto 0);
		fifo_empty   : in  std_logic
	);
end entity LT24_Interface;

architecture RTL of LT24_Interface is
	type state_type is (IDLE, WRITE_CMD, WRITE_DATA, DMA_TRANSFER, DMA_AVAILABLE, DMA_WRITE);
	signal state_reg, state_next     : state_type;
	signal counter_reg, counter_next : integer;

	signal csx_reg, csx_next   : std_logic;
	signal dcx_reg, dcx_next   : std_logic;
	signal wrx_reg, wrx_next   : std_logic;
	signal rdx_reg, rdx_next   : std_logic;
	signal data_reg, data_next : std_logic_vector(15 downto 0);
begin
	busy <= '1' when start_single = '1' or state_reg /= IDLE else '0';

	state_machine : process(data_cmd_n, counter_reg, csx_reg, data_in, data_reg, dcx_reg, rdx_reg, start_single, state_reg, wrx_reg, running, fifo_empty, read_data) is
	begin
		state_next   <= state_reg;
		counter_next <= counter_reg;
		csx_next     <= csx_reg;
		dcx_next     <= dcx_reg;
		wrx_next     <= wrx_reg;
		rdx_next     <= rdx_reg;
		data_next    <= data_reg;
		read_fifo    <= '0';

		case state_reg is
			when IDLE =>
				if start_single = '1' then
					data_next <= data_in;
					if data_cmd_n = '1' then
						state_next <= WRITE_DATA;
					else
						state_next <= WRITE_CMD;
					end if;
				end if;
				if running = '1' then
					state_next <= DMA_TRANSFER;
				end if;
			when WRITE_CMD =>
				counter_next <= counter_reg + 1;
				case counter_reg is
					when 0 => dcx_next <= '0';
					when 1 => csx_next <= '0';
					when 2 => wrx_next <= '0';
					when 3 => wrx_next <= '1';
					when 4 => csx_next <= '1';
					when 5 =>
						dcx_next     <= '1';
						state_next   <= IDLE;
						counter_next <= 0;
						data_next    <= (others => '0');
					when others => null;
				end case;
			when WRITE_DATA =>
				counter_next <= counter_reg + 1;
				case counter_reg is
					when 0 => csx_next <= '0';
						wrx_next       <= '0';
					when 1 => wrx_next <= '1';
					when 2 =>
						csx_next     <= '1';
						state_next   <= IDLE;
						counter_next <= 0;
						data_next    <= (others => '0');
					when others => null;
				end case;
			when DMA_TRANSFER =>
				if (fifo_empty = '0') then
					state_next <= DMA_AVAILABLE;
					read_fifo  <= '1';
				elsif (running = '0') then
					state_next <= IDLE;
				end if;
			when DMA_AVAILABLE =>
				data_next  <= read_data;
				state_next <= DMA_WRITE;
			when DMA_WRITE =>
				counter_next <= counter_reg + 1;
				case counter_reg is
					when 0 => csx_next <= '0';
						wrx_next       <= '0';
					when 1 => wrx_next <= '1';
					when 2 =>
						csx_next     <= '1';
						state_next   <= DMA_TRANSFER;
						counter_next <= 0;
						data_next    <= (others => '0');
					when others => null;
				end case;
		end case;
	end process state_machine;

	output_process : process(csx_reg, data_reg, dcx_reg, rdx_reg, wrx_reg) is
	begin
		csx      <= csx_reg;
		dcx      <= dcx_reg;
		wrx      <= wrx_reg;
		rdx      <= rdx_reg;
		data_out <= data_reg;
	end process output_process;

	reg_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			state_reg   <= IDLE;
			counter_reg <= 0;
			csx_reg     <= '1';
			dcx_reg     <= '1';
			wrx_reg     <= '1';
			rdx_reg     <= '1';
			data_reg    <= (others => '0');
		elsif rising_edge(clk) then
			state_reg   <= state_next;
			counter_reg <= counter_next;
			csx_reg     <= csx_next;
			dcx_reg     <= dcx_next;
			wrx_reg     <= wrx_next;
			rdx_reg     <= rdx_next;
			data_reg    <= data_next;
		end if;
	end process reg_process;
end architecture RTL;

