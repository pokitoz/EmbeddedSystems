library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
	port(
		Clk        : in  std_logic;
		Reset_n    : in  std_logic;

		-- Avalon Slave signals
		Address    : in  std_logic_vector(2 downto 0);
		ChipSelect : in  std_logic;

		Read       : in  std_logic;
		Write      : in  std_logic;

		ReadData   : out std_logic_vector(31 downto 0);
		WriteData  : in  std_logic_vector(31 downto 0);

		IRQ        : out std_logic
	);
end entity Timer;

architecture RTL of Timer is
	-- Counter signals
	signal CounterReg       : unsigned(31 downto 0);
	signal EnableCounterReg : std_logic;
	signal LimitReg         : unsigned(31 downto 0);
	signal RzReg            : std_logic;

	-- IRQ signals
	signal EOTReg    : std_logic;
	signal IRQEnReg  : std_logic;
	signal ClrEOTReg : std_logic;
begin
	proc_counter : process(Clk, Reset_n) is
	begin
		if Reset_n = '0' then
			CounterReg <= (others => '0');
		elsif rising_edge(Clk) then
			if RzReg = '1' then
				CounterReg <= (others => '0');
			elsif EnableCounterReg = '1' then
				if CounterReg = LimitReg then
					CounterReg <= (others => '0');
				else
					CounterReg <= CounterReg + 1;
				end if;
			end if;
		end if;
	end process proc_counter;

	proc_read : process(Clk) is
	begin
		if rising_edge(Clk) then
			ReadData <= (others => '0');
			if ChipSelect = '1' and Read = '1' then
				case Address is
					when "000" => ReadData <= std_logic_vector(CounterReg);
					when "100" => ReadData(0) <= IRQEnReg;
					when "101" =>
						ReadData(1)        <= EnableCounterReg;
						ReadData(0)        <= EOTReg;
					when "110" => ReadData <= std_logic_vector(LimitReg);
					when others => null;
				end case;
			end if;
		end if;
	end process proc_read;

	proc_write : process(Clk, Reset_n) is
	begin
		if Reset_n = '0' then
			RzReg            <= '0';
			EnableCounterReg <= '0';
			LimitReg         <= X"FFFF_FFFF";
			IRQEnReg         <= '0';
			ClrEOTReg        <= '0';
		elsif rising_edge(Clk) then
			RzReg     <= '0';
			ClrEOTReg <= '0';
			if ChipSelect = '1' and Write = '1' then
				case Address is
					when "001"  => RzReg <= '1';
					when "010"  => EnableCounterReg <= '1';
					when "011"  => EnableCounterReg <= '0';
					when "100"  => IRQEnReg <= WriteData(0);
					when "101"  => ClrEOTReg <= WriteData(0);
					when "110"  => LimitReg <= unsigned(WriteData);
					when others => null;
				end case;

			end if;
		end if;
	end process proc_write;

	proc_interrupt : process(Clk, Reset_n) is
	begin
		if Reset_n = '0' then
			EOTReg <= '0';
		elsif rising_edge(Clk) then
			if CounterReg = X"0000_0000" then
				EOTReg <= '1';
			elsif ClrEOTReg = '1' then
				EOTReg <= '0';
			end if;
		end if;
	end process proc_interrupt;

	IRQ <= '1' when IRQEnReg = '1' and EnableCounterReg = '1' and EOTReg = '1' else '0';

end architecture RTL;

