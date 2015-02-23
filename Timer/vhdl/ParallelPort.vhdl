library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ParallelPort is
	generic(portWidth : Integer := 32);

	port(
		Clk        : in  std_logic;
		Reset_n    : in  std_logic;

		-- Avalon Slave signals
		Address    : in  std_logic_vector(1 downto 0);
		ChipSelect : in  std_logic;
		Read       : in  std_logic;
		Write      : in  std_logic;
		ReadData   : out std_logic_vector(portWidth - 1 downto 0);
		WriteData  : in  std_logic_vector(portWidth - 1 downto 0)
	);
end entity ParallelPort;

architecture RTL of ParallelPort is
	signal ports : std_logic_vector(portWidth - 1 downto 0);
begin
	proc_read : process(Clk) is
	begin
		if rising_edge(Clk) then
			ReadData <= (others => '0');
			if ChipSelect = '1' and Read = '1' then
				case Address is
					when "00" => ReadData <=  ports;		
					when others => null;
				end case;
			end if;
		end if;
	end process proc_read;
	
	
	proc_write : process(Clk, Reset_n) is
	begin
		if Reset_n = '0' then
			ports            <= (others => '0');
		
		elsif rising_edge(Clk) then
			
			if ChipSelect = '1' and Write = '1' then
				case Address is
					when "00"  => ports <= WriteData;
					when "01"  => ports <= ports or WriteData;
					when "10"  => ports <= ports and (not WriteData);
					when others => null;
				end case;
			end if;
		end if;
	end process proc_write;

end architecture RTL;
