library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_Receive is
	port(
		clk_4X9600Hz   : in std_logic;
		reset_n      : in  std_logic;
		ackNewData   : in  std_logic;
		newDataReady : out std_logic;
		dataToRead   : out std_logic_vector(7 downto 0);
		Rx           : in  std_logic
	);
end entity UART_Receive;

architecture RTL of UART_Receive is
	signal Rx_a, Rx_b : std_logic;
	signal dataBuffer_reg, dataBuffer_next, lastData_next, lastData_reg : std_logic_vector(7 downto 0);
	signal ready : std_logic;
	signal counter_bit_number_reg, counter_bit_number_next : unsigned(2 downto 0);
	signal counter_bit_sample_reg, counter_bit_sample_next : unsigned(1 downto 0);
	
	type state_type is (IDLE, START, RECEIVE, STOP);
	signal state_reg, state_next : state_type;
begin
	
	dataToRead <= dataBuffer_reg;
	
	state_machine : process (Rx_b, counter_bit_number_reg, counter_bit_sample_reg, dataBuffer_reg, dataBuffer_reg(7 downto 1), state_reg) is
	begin
		state_next <= state_reg;
		counter_bit_number_next <= (others => '0');
		counter_bit_sample_next <= (others => '0');
		dataBuffer_next <= dataBuffer_reg;
		lastData_next <= lastData_reg;
		ready <= '0';
		
		case state_reg is 
			when IDLE =>
				if(Rx_b = '0') then
					state_next <= START;
					counter_bit_sample_next <= counter_bit_sample_reg + 1;
				end if;
			when START =>
				state_next <= RECEIVE;
				counter_bit_sample_next <= (others => '0');
			when RECEIVE =>
				counter_bit_sample_next <= counter_bit_sample_reg + 1;
				counter_bit_number_next <= counter_bit_number_reg;
				
				if(counter_bit_sample_reg = 3) then
					counter_bit_sample_next <= (others => '0');
					dataBuffer_next <= Rx_b & dataBuffer_reg(7 downto 1);
					
					if(counter_bit_number_reg /= 7) then
						counter_bit_number_next <= counter_bit_number_reg + 1;
					else
						counter_bit_number_next <= (others => '0');
						state_next <= STOP;
					end if;
				end if;
				
			when STOP =>
				counter_bit_sample_next <= counter_bit_sample_reg + 1;
				if(counter_bit_sample_reg = 3) then
					state_next <= IDLE;
					ready <= '1';
					lastData_next <= dataBuffer_reg;
					counter_bit_sample_next <= (others => '0');
				end if;
		end case;
		
	end process state_machine;
	
	
	ack_process : process(reset_n, ready, ackNewData) is
	begin
		if reset_n = '0' or ackNewData = '1' then
			newDataReady <= '0';
		elsif rising_edge(ready) then
			newDataReady <= '1';
		end if;
	end process ack_process;
	
	double_FF_filtering : process (clk_4X9600Hz, reset_n) is
	begin
		if reset_n = '0' then
			Rx_a <= '1'; -- hold line at 1
			Rx_b <= '1'; -- hold line at 1
		elsif rising_edge(clk_4X9600Hz) then
			Rx_a <= Rx;
			Rx_b <= Rx_a;
		end if;
	end process double_FF_filtering;
	
	reg_process : process (clk_4X9600Hz, reset_n) is
	begin
		if reset_n = '0' then
			state_reg <= IDLE;
			dataBuffer_reg <= (others => '0');
			counter_bit_number_reg <= (others => '0');
			counter_bit_sample_reg <= (others => '0');
			lastData_reg <= (others => '0');
		elsif rising_edge(clk_4X9600Hz) then
			state_reg <= state_next;
			dataBuffer_reg <= dataBuffer_next;
			counter_bit_number_reg <= counter_bit_number_next;
			counter_bit_sample_reg <= counter_bit_sample_next;
			lastData_reg <= lastData_next;
		end if;
	end process reg_process;
	
	
end architecture RTL;