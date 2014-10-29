library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity UART is
	port(
		clk        : IN  std_logic;
		reset_n    : IN  std_logic;

		Address    : IN  std_logic_vector(2 DOWNTO 0);
		ChipSelect : IN  std_logic;

		Read       : IN  std_logic;
		Write      : IN  std_logic;
		ReadData   : OUT std_logic_vector(7 DOWNTO 0);
		WriteData  : IN  std_logic_vector(7 DOWNTO 0);

		UART_clk   : IN  std_logic;

		Tx         : OUT std_logic;
		Rx         : IN  std_logic
	);
end entity UART;

architecture RTL of UART is
	type state_type is (idle, transmit);

	signal state_reg  : state_type;
	signal state_next : state_type;

	signal Tx_reg                  : std_logic;
	signal Tx_buf_reg, Tx_sync_buf : std_logic_vector(7 downto 0);
	signal must_transmit           : std_logic;
	signal Tx_counter_reg          : unsigned(3 downto 0);

begin
	Tx <= Tx_reg;

	state_machine : process(state_reg, Write, ChipSelect, Address, Tx_counter_reg) is
	begin
		state_next    <= state_reg;
		must_transmit <= '0';
		case state_reg is
			when idle =>
				if (Write = '1' and ChipSelect = '1' and Address(1 downto 0) = "01") then
					state_next <= transmit;
				end if;
			when transmit =>
				must_transmit <= '1';
				if (Tx_counter_reg = "1001") then
					state_next <= idle;
				end if;
		end case;
	end process state_machine;

	state_machine_reg : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			state_reg <= idle;
		elsif rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process state_machine_reg;

	transmit_proc : process(UART_clk, reset_n) is
	begin
		if reset_n = '0' then
			Tx_reg         <= '1';
			Tx_counter_reg <= "0000";
			Tx_sync_buf <= "00000000";
		elsif rising_edge(UART_clk) then
			if (must_transmit = '1') then
				case Tx_counter_reg is
					when "0000" => Tx_reg <= '0';
						Tx_counter_reg <= Tx_counter_reg + 1;
						Tx_sync_buf <= Tx_buf_reg;
					when "1001" =>
						Tx_reg         <= '1';
						Tx_counter_reg <= "0000";
					when others =>
						Tx_reg         <= Tx_sync_buf(7);
						Tx_counter_reg <= Tx_counter_reg + 1;
						Tx_sync_buf <= Tx_sync_buf(6 downto 0) & '0';
				end case;
			end if;
		end if;
	end process transmit_proc;

	write_to_reg : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			Tx_buf_reg <= (others => '0');
		elsif rising_edge(clk) then
			if (ChipSelect = '1' and Write = '1') then
				case Address(1 downto 0) is
					when "01"   => Tx_buf_reg <= WriteData;
					when others => null;
				end case;
			end if;
		end if;
	end process write_to_reg;

	read_from_reg : process(clk) is
	begin
		if rising_edge(clk) then
			if (ChipSelect = '1' and Read = '1') then
				case Address(1 downto 0) is
					when "00" =>
						if (state_reg = idle) then
							ReadData <= X"00";
						else
							ReadData <= X"FF";
						end if;
					when others => null;
				end case;

			end if;
		end if;
	end process read_from_reg;

end architecture RTL;
