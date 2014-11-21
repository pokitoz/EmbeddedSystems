library ieee;
use ieee.std_logic_1164.all;

entity LCDControler is
	port(
		clk        : in    std_logic;
		reset_n    : in    std_logic;
		Address    : in    std_logic_vector(1 downto 0);
		chipSelect : in    std_logic;

		Read       : in    std_logic;
		Write      : in    std_logic;

		ReadData   : out   std_logic_vector(15 downto 0);
		WriteData  : in    std_logic_vector(15 downto 0);

		CSX        : out   std_logic;
		DCX        : out   std_logic;
		WRX        : out   std_logic;
		RDX        : out   std_logic;

		D          : inout std_logic_vector(15 downto 0)
	);
end entity LCDControler;

architecture RTL of LCDControler is
begin
	pRegWr : process(clk, reset_n) is
	begin
		if reset_n = '0' then
		elsif rising_edge(clk) then
			if chipSelect = '1' and Write = '1' then
				case Address is
					
					-- Write Command
					when "00" =>
						WRX <= '0';
						CSX <= '0';
						RDX <= '1';
						DCX <= '0';
						D   <= WriteData;

					-- Write Data
					when "01" => 
						WRX <= '0';
						CSX <= '0';
						RDX <= '1';
						DCX <= '1';
						D   <= WriteData;

					when others =>
						null;
				end case;
			else
				WRX <= '1';
				CSX <= '1';
				RDX <= '1';
				DCX <= '1';
				D   <= (others => '0');

			end if;

		elsif falling_edge(clk) then
			WRX <= '1';

		end if;

	end process pRegWr;

end architecture RTL;



