library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Transmit is
	port(
		clk_9600Hz     : in std_logic;
		reset_n        : in  std_logic;
		newDataToWrite : in  std_logic;
		readyToWrite   : out std_logic;
		dataToWrite    : in  std_logic_vector(7 downto 0);
		Tx             : out std_logic
	);
end entity UART_Transmit;

architecture RTL of UART_Transmit is
	signal buffer_reg, buffer_next   : std_logic_vector(7 downto 0);
	signal counter_reg, counter_next : unsigned(3 downto 0);
	type state_type is (IDLE, TRANSMIT);
	signal state_reg, state_next : state_type;
	signal shift_reg, shift_next : std_logic_vector(7 downto 0);
	
	-- synchronization
	signal dataToWrite_in : std_logic_vector(7 downto 0);
	signal newDataToWrite_in : std_logic;
	signal ackNewData : std_logic;
	
begin
	
	sync : process (dataToWrite, ackNewData) is
	begin
		if ackNewData = '1' then
			dataToWrite_in <= (others => '0');
			newDataToWrite_in <= '0';
		elsif rising_edge(dataToWrite) then
			dataToWrite_in <= dataToWrite;
			newDataToWrite_in <= '1';
		end if;
	end process sync;
	
	
	state_machine : process(state_reg, buffer_reg, newDataToWrite, counter_reg, shift_reg, dataToWrite) is
	begin
		state_next   <= state_reg;
		shift_next <= shift_reg;
		counter_next <= (others => '0');
		buffer_next  <= buffer_reg;
		readyToWrite <= '0';
		Tx           <= '1';
		ackNewData <= '0';

		case state_reg is
			when IDLE =>
				readyToWrite <= '1';
				if (newDataToWrite_in = '1') then
					state_next  <= TRANSMIT;
					buffer_next <= dataToWrite_in;
				end if;
			when TRANSMIT =>
				ackNewData <= '1';
				counter_next <= counter_reg + 1;
				case counter_reg is
					when "0000" => Tx <= '1';
					when "0001" => shift_next <= buffer_reg;
					when "0010" => Tx <= '0';
					when "1011" => Tx <= '1';
					when "1100" => state_next <= IDLE;
					when others =>
						shift_next <= '0' & shift_reg(7 downto 1);
						Tx         <= shift_reg(0);
				end case;

		end case;
	end process state_machine;

	reg_slow_process : process(clk_9600Hz, reset_n, reset_slow) is
	begin
		if reset_n = '0' or reset_slow = '1' then
			counter_reg <= (others => '0');
			shift_reg   <= (others => '0');
			buffer_reg <= (others => '0');
			state_reg  <= IDLE;
		elsif rising_edge(clk_9600Hz) then
			counter_reg <= counter_next;
			shift_reg   <= shift_next;
			buffer_reg <= buffer_next;
			state_reg  <= state_next;
		end if;
	end process reg_slow_process;

end architecture RTL;
