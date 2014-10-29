library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
	port(
		clk        : IN  std_logic;
		reset_n    : IN  std_logic;

		Address    : IN  std_logic_vector(1 DOWNTO 0);
		ChipSelect : IN  std_logic;

		Read       : IN  std_logic;
		Write      : IN  std_logic;
		ReadData   : OUT std_logic_vector(7 DOWNTO 0);
		WriteData  : IN  std_logic_vector(7 DOWNTO 0);

		Tx         : OUT std_logic;
		Rx         : IN  std_logic
	);
end entity UART;

architecture RTL of UART is
	component UART_Transmit
		port(clk            : in  std_logic;
			 clk_9600Hz     : std_logic;
			 reset_n        : in  std_logic;
			 newDataToWrite : in  std_logic;
			 readyToWrite   : out std_logic;
			 dataToWrite    : in std_logic_vector(7 downto 0);
			 Tx : out std_logic);
	end component UART_Transmit;

	signal newDataToWrite : std_logic;
	signal readyToWrite   : std_logic;
	signal dataToWrite    : std_logic_vector(7 downto 0);

	component UART_Receive
		port(clk          : in  std_logic;
			 clk_9600Hz   : std_logic;
			 reset_n      : in  std_logic;
			 ackNewData   : in  std_logic;
			 newDataReady : out std_logic;
			 dataToRead   : out std_logic_vector(7 downto 0);
			 Rx : in std_logic);
	end component UART_Receive;

	signal ackNewData   : std_logic;
	signal newDataReady : std_logic;
	signal dataToRead   : std_logic_vector(7 downto 0);
	signal ReadData_reg : std_logic_vector(7 downto 0);

	component UART_Clock
		port(clk_50Mhz  : in  std_logic;
			 reset_n    : in  std_logic;
			 clk_9600Hz : out std_logic);
	end component UART_Clock;

	signal clk_9600Hz : std_logic;

begin
	UART_Transmit_inst : component UART_Transmit
		port map(clk            => clk,
			     clk_9600Hz     => clk_9600Hz,
			     reset_n        => reset_n,
			     newDataToWrite => newDataToWrite,
			     readyToWrite   => readyToWrite,
			     dataToWrite    => dataToWrite,
			     Tx => Tx);

	UART_Receive_inst : component UART_Receive
		port map(clk          => clk,
			     clk_9600Hz   => clk_9600Hz,
			     reset_n      => reset_n,
			     ackNewData   => ackNewData,
			     newDataReady => newDataReady,
			     dataToRead   => dataToRead,
			     Rx => Rx);

	UART_Clock_inst : component UART_Clock
		port map(clk_50Mhz  => clk,
			     reset_n    => reset_n,
			     clk_9600Hz => clk_9600Hz);

	write_to_reg : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			newDataToWrite <= '0';
			dataToWrite    <= (others => '0');
		elsif rising_edge(clk) then
			newDataToWrite <= '0';
			dataToWrite    <= (others => '0');
			if (ChipSelect = '1' and Write = '1') then
				case Address is
					when "01" =>
						newDataToWrite <= '1';
						dataToWrite    <= WriteData;
					when others => null;
				end case;
			end if;
		end if;
	end process write_to_reg;

	read_from_reg : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			ReadData_reg <= (others => '0');
		elsif rising_edge(clk) then
			ReadData_reg <= X"00";
			if (ChipSelect = '1' and Read = '1') then
				case Address is
					when "00"   => ReadData_reg <= "000000" & newDataReady & readyToWrite;
					when "01"   => ReadData_reg <= X"FF";
					when others => null;
				end case;
			end if;
		end if;
	end process read_from_reg;
	
	ReadData <= ReadData_reg;

end architecture RTL;
