library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Slave is
	port(
		clk          : in  std_logic;
		reset_n      : in  std_logic;
		-- Avalon signals
		address      : in  std_logic_vector(2 downto 0);
		chip_select  : in  std_logic;
		read         : in  std_logic;
		write        : in  std_logic;
		read_data    : out std_logic_vector(31 downto 0);
		write_data   : in  std_logic_vector(31 downto 0);
		-- LT24 Board signals
		lcd_reset_n  : out std_logic;
		lcd_on       : out std_logic;
		-- LT24 Interface signals
		start_single : out std_logic;
		data_cmd_n   : out std_logic;
		data_in      : out std_logic_vector(15 downto 0);
		busy         : in  std_logic;
		-- LT24_Master signals
		start_dma    : out std_logic;
		address_dma  : out std_logic_vector(31 downto 0);
		len_dma      : out std_logic_vector(31 downto 0)
	);
end entity LT24_Slave;

architecture RTL of LT24_Slave is
begin
	read_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			read_data <= (others => '0');
		elsif rising_edge(clk) then
			if chip_select = '1' and read = '1' then
				case address is
					when "010" =>
						read_data(0) <= busy;
					when others => null;
				end case;
			end if;
		end if;
	end process read_process;

	write_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			start_single <= '0';
			data_cmd_n   <= '0';
			data_in      <= (others => '0');
			lcd_on       <= '0';
			lcd_reset_n  <= '1';
			start_dma    <= '0';
			address_dma  <= (others => '0');
			len_dma      <= (others => '0');
		elsif rising_edge(clk) then
			start_single <= '0';
			data_cmd_n   <= '0';
			data_in      <= (others => '0');
			lcd_reset_n  <= '1';
			start_dma    <= '0';
			if chip_select = '1' and write = '1' then
				case address is
					when "000" =>
						start_single <= '1';
						data_cmd_n   <= '0';
						data_in      <= write_data(15 downto 0);
					when "001" =>
						start_single <= '1';
						data_cmd_n   <= '1';
						data_in      <= write_data(15 downto 0);
					when "011" =>
						lcd_on      <= write_data(0);
						lcd_reset_n <= write_data(1);
					when "100" =>
						address_dma <= write_data;
					when "101" =>
						len_dma   <= write_data;
						start_dma <= '1';
					when others => null;
				end case;
			end if;
		end if;
	end process write_process;

end architecture RTL;

