library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Controller is
	port(
		-- Avalon signals
		clk         : in    std_logic;
		reset_n     : in    std_logic;
		address     : in    std_logic_vector(1 downto 0);
		chip_select : in    std_logic;

		read        : in    std_logic;
		write       : in    std_logic;

		read_data   : out   std_logic_vector(15 downto 0);
		write_data  : in    std_logic_vector(15 downto 0);

		-- LT24 signals
		lcd_reset_n : out   std_logic;
		lcd_on      : out   std_logic;

		csx         : out   std_logic;
		dcx         : out   std_logic;
		wrx         : out   std_logic;
		rdx         : out   std_logic;

		data        : inout std_logic_vector(15 downto 0)
	);
end entity LT24_Controller;

architecture RTL of LT24_Controller is
	signal translator_start : std_logic;
	signal translator_cmd   : std_logic;
	signal translator_data  : std_logic_vector(15 downto 0);
	signal translator_busy  : std_logic;

	component LT24_Translator
		port(clk      : in  std_logic;
			 reset_n  : in  std_logic;
			 start    : in  std_logic;
			 cmd      : in  std_logic;
			 data_in  : in  std_logic_vector(15 downto 0);
			 busy     : out std_logic;
			 csx      : out std_logic;
			 dcx      : out std_logic;
			 wrx      : out std_logic;
			 rdx      : out std_logic;
			 data_out : out std_logic_vector(15 downto 0));
	end component LT24_Translator;
begin
	read_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			read_data <= (others => '0');
		elsif rising_edge(clk) then
			if chip_select = '1' and read = '1' then
				case address is
					when "10" =>
						read_data(0) <= translator_busy;
					when others => null;
				end case;
			end if;
		end if;
	end process read_process;

	write_process : process(clk, reset_n) is
	begin
		if reset_n = '0' then
			translator_start <= '0';
			translator_cmd   <= '0';
			translator_data  <= (others => '0');
			lcd_on           <= '0';
		elsif rising_edge(clk) then
			translator_start <= '0';
			translator_cmd   <= '0';
			translator_data  <= (others => '0');
			lcd_reset_n      <= '1';
			if chip_select = '1' and write = '1' then
				case address is
					when "00" =>
						translator_start <= '1';
						translator_cmd   <= '1';
						translator_data  <= write_data;
					when "01" =>
						translator_start <= '1';
						translator_cmd   <= '0';
						translator_data  <= write_data;
					when "11" =>
						lcd_on      <= write_data(0);
						lcd_reset_n <= write_data(1);
				end case;
			end if;
		end if;
	end process write_process;

	LT24_Translator_inst : component LT24_Translator
		port map(clk      => clk,
			     reset_n  => reset_n,
			     start    => translator_start,
			     cmd      => translator_cmd,
			     data_in  => translator_data,
			     busy     => translator_busy,
			     csx      => csx,
			     dcx      => dcx,
			     wrx      => wrx,
			     rdx      => rdx,
			     data_out => data);
end architecture RTL;



