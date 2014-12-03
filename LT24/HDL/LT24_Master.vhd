library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Master is
	port(
		clk             : in  std_logic;
		reset_n         : in  std_logic;
		-- Avalon signals
		address         : out std_logic_vector(31 downto 0);
		read            : out std_logic;
		read_data       : in  std_logic_vector(31 downto 0);
		wait_request    : in  std_logic;
		-- Avalon burst signals
		burst_cnt       : out std_logic_vector(6 downto 0);
		read_data_valid : in  std_logic_vector;
		-- LT24 Slave signals
		start_dma       : in  std_logic;
		address_dma     : in  std_logic_vector(31 downto 0);
		len_dma         : in  std_logic_vector(31 downto 0);
		-- FIFO signals
		write_fifo      : out std_logic;
		write_data      : out std_logic_vector(31 downto 0);
		fifo_full       : in  std_logic;
		fifo_free_cnt   : in  std_logic_vector(6 downto 0);
		-- LT24 Interface signals
		running         : out std_logic
	);
end entity LT24_Master;

architecture RTL of LT24_Master is
begin
	
end architecture RTL;
