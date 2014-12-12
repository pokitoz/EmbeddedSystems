library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LT24_Module is
	port(
		clk              : in  std_logic;
		reset_n          : in  std_logic;
		-- Avalon Slave signals
		address_slave    : in  std_logic_vector(2 downto 0);
		chip_select      : in  std_logic;
		read_slave       : in  std_logic;
		write            : in  std_logic;
		read_data_slave  : out std_logic_vector(31 downto 0);
		write_data_slave : in  std_logic_vector(31 downto 0);
		-- LT24 Board signals
		lcd_reset_n      : out std_logic;
		lcd_on           : out std_logic;
		-- LT24 Interface signals
		csx              : out std_logic;
		dcx              : out std_logic;
		wrx              : out std_logic;
		rdx              : out std_logic;
		data_out         : out std_logic_vector(15 downto 0);
		-- LT24 Master signals
		address_master   : out std_logic_vector(31 downto 0);
		read_master      : out std_logic;
		read_data_master : in  std_logic_vector(31 downto 0);
		wait_request     : in  std_logic;
		
		read_data_master_debug : out  std_logic_vector(31 downto 0);
		read_master_debug : out std_logic;
		address_master_debug : out std_logic_vector(31 downto 0);
		wait_request_debug : out std_logic
	);
end entity LT24_Module;

architecture RTL of LT24_Module is
	component LT24_Slave
		port(clk          : in  std_logic;
			 reset_n      : in  std_logic;
			 address      : in  std_logic_vector(2 downto 0);
			 chip_select  : in  std_logic;
			 read         : in  std_logic;
			 write        : in  std_logic;
			 read_data    : out std_logic_vector(31 downto 0);
			 write_data   : in  std_logic_vector(31 downto 0);
			 lcd_reset_n  : out std_logic;
			 lcd_on       : out std_logic;
			 start_single : out std_logic;
			 data_cmd_n   : out std_logic;
			 data_in      : out std_logic_vector(15 downto 0);
			 busy         : in  std_logic;
			 start_dma    : out std_logic;
			 address_dma  : out std_logic_vector(31 downto 0);
			 len_dma      : out std_logic_vector(31 downto 0));
	end component LT24_Slave;

	component LT24_Interface
		port(clk          : in  std_logic;
			 reset_n      : in  std_logic;
			 start_single : in  std_logic;
			 data_cmd_n   : in  std_logic;
			 data_in      : in  std_logic_vector(15 downto 0);
			 busy         : out std_logic;
			 csx          : out std_logic;
			 dcx          : out std_logic;
			 wrx          : out std_logic;
			 rdx          : out std_logic;
			 data_out     : out std_logic_vector(15 downto 0);
			 running      : in  std_logic;
			 read_fifo    : out std_logic;
			 read_data    : in  std_logic_vector(15 downto 0);
			 fifo_empty   : in  std_logic);
	end component LT24_Interface;

	component LT24_Master
		port(clk             : in  std_logic;
			 reset_n         : in  std_logic;
			 address         : out std_logic_vector(31 downto 0);
			 read            : out std_logic;
			 read_data       : in  std_logic_vector(31 downto 0);
			 wait_request    : in  std_logic;
			 start_dma       : in  std_logic;
			 address_dma     : in  std_logic_vector(31 downto 0);
			 len_dma         : in  std_logic_vector(31 downto 0);
			 write_fifo      : out std_logic;
			 write_data      : out std_logic_vector(31 downto 0);
			 fifo_full       : in  std_logic;
			 fifo_free_cnt   : in  std_logic_vector(5 downto 0);
			 running         : out std_logic;
			 
			 read_debug      : out std_logic;
			 address_master_debug : out std_logic_vector(31 downto 0));
	end component LT24_Master;

	component FIFO
		port(data    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			 rdclk   : IN  STD_LOGIC;
			 rdreq   : IN  STD_LOGIC;
			 wrclk   : IN  STD_LOGIC;
			 wrreq   : IN  STD_LOGIC;
			 q       : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rdempty : OUT STD_LOGIC;
			 wrfull  : OUT STD_LOGIC;
			 wrusedw : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));
	end component FIFO;

	-- LT24 Slave <-> LT24 Interface
	signal start_single : std_logic;
	signal data_cmd_n   : std_logic;
	signal data_in      : std_logic_vector(15 downto 0);
	signal busy         : std_logic;

	-- LT24 Slave <-> LT24 Master
	signal start_dma   : std_logic;
	signal address_dma : std_logic_vector(31 downto 0);
	signal len_dma     : std_logic_vector(31 downto 0);

	-- LT24 Interface <-> LT24 Master
	signal running : std_logic;

	-- LT24 Interface <-> FIFO
	signal read_fifo      : std_logic;
	signal fifo_empty     : std_logic;
	signal read_data_fifo : std_logic_vector(15 downto 0);

	-- LT24 Master <-> FIFO
	signal write_fifo      : std_logic;
	signal fifo_full       : std_logic;
	signal write_data_fifo : std_logic_vector(31 downto 0);
	signal fifo_free_cnt   : std_logic_vector(5 downto 0);

begin
	LT24_Slave_inst : component LT24_Slave
		port map(clk          => clk,
			     reset_n      => reset_n,
			     address      => address_slave,
			     chip_select  => chip_select,
			     read         => read_slave,
			     write        => write,
			     read_data    => read_data_slave,
			     write_data   => write_data_slave,
			     lcd_reset_n  => lcd_reset_n,
			     lcd_on       => lcd_on,
			     start_single => start_single,
			     data_cmd_n   => data_cmd_n,
			     data_in      => data_in,
			     busy         => busy,
			     start_dma    => start_dma,
			     address_dma  => address_dma,
			     len_dma      => len_dma);

	LT24_Interface_inst : component LT24_Interface
		port map(clk          => clk,
			     reset_n      => reset_n,
			     start_single => start_single,
			     data_cmd_n   => data_cmd_n,
			     data_in      => data_in,
			     busy         => busy,
			     csx          => csx,
			     dcx          => dcx,
			     wrx          => wrx,
			     rdx          => rdx,
			     data_out     => data_out,
			     running      => running,
			     read_fifo    => read_fifo,
			     read_data    => read_data_fifo,
			     fifo_empty   => fifo_empty);

	LT24_Master_inst : component LT24_Master
		port map(clk             => clk,
			     reset_n         => reset_n,
			     address         => address_master,
			     read            => read_master,
			     read_data       => read_data_master,
			     wait_request    => wait_request,
			     start_dma       => start_dma,
			     address_dma     => address_dma,
			     len_dma         => len_dma,
			     write_fifo      => write_fifo,
			     write_data      => write_data_fifo,
			     fifo_full       => fifo_full,
			     fifo_free_cnt   => fifo_free_cnt,
			     running         => running,
				  read_debug		=> read_master_debug,
				  address_master_debug => address_master_debug);

	FIFO_inst : component FIFO
		port map(data    => write_data_fifo,
			     rdclk   => clk,
			     rdreq   => read_fifo,
			     wrclk   => clk,
			     wrreq   => write_fifo,
			     q       => read_data_fifo,
			     rdempty => fifo_empty,
			     wrfull  => fifo_full,
			     wrusedw => fifo_free_cnt);
				  
				  
	read_data_master_debug <= read_data_master;
	wait_request_debug		<= wait_request;
									
									
end architecture RTL;
