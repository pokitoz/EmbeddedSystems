library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CameraDMA_Slave_Interface_tb is
end entity CameraDMA_Slave_Interface_tb;

architecture RTL of CameraDMA_Slave_Interface_tb is
    signal CLKxC, RSTxRB      : std_logic                     := '0';
    signal STOPxS             : std_logic                     := '0';
    signal ASlaveChipSelectxS : std_logic                     := '0';
    signal ASlaveAddressxD    : std_logic_vector(2 downto 0)  := (others => '0');
    signal ASlaveReadxS       : std_logic                     := '0';
    signal ASlaveReadDataxD   : std_logic_vector(31 downto 0) := (others => '0');
    signal ASlaveWritexS      : std_logic                     := '0';
    signal ASlaveWriteDataxD  : std_logic_vector(31 downto 0) := (others => '0');

    component CameraDMA
        port(CLKxCI                : in  std_logic;
             RSTxRBI               : in  std_logic;
             ASlaveChipSelectxSI   : in  std_logic;
             ASlaveAddressxDI      : in  std_logic_vector(2 downto 0);
             ASlaveReadxSI         : in  std_logic;
             ASlaveReadDataxDO     : out std_logic_vector(31 downto 0);
             ASlaveWritexSI        : in  std_logic;
             ASlaveWriteDataxDI    : in  std_logic_vector(31 downto 0);
             AMasterAddressxDO     : out std_logic_vector(31 downto 0);
             AMasterByteEnablexDBO  : out std_logic_vector(3 downto 0);
             AMasterWritexSO       : out std_logic;
             AMasterWriteDataxDO   : out std_logic_vector(31 downto 0);
             AMasterWaitRequestxSI : in  std_logic;
             AMasterEndOfPacket    : out std_logic;
             FifoOutputDataxDI     : in  std_logic_vector(31 downto 0);
             FifoUsedxDI           : in  std_logic_vector(1 downto 0);
             FifoReadReqxSO        : out std_logic);
    end component CameraDMA;

    constant CLK_PERIOD : time                          := 40 ns;
    constant DATA1      : std_logic_vector(31 downto 0) := X"CF04BC88";
    constant DATA2      : std_logic_vector(31 downto 0) := X"FFFFFF00";
    constant DATA3      : std_logic_vector(31 downto 0) := X"010504FF";
begin
    CLKxC  <= not CLKxC after CLK_PERIOD / 2 when STOPxS = '0';
    RSTxRB <= '1' after 2 * CLK_PERIOD;

    DUV : CameraDMA
        port map(CLKxCI                => CLKxC,
                 RSTxRBI               => RSTxRB,
                 ASlaveChipSelectxSI   => ASlaveChipSelectxS,
                 ASlaveAddressxDI      => ASlaveAddressxD,
                 ASlaveReadxSI         => ASlaveReadxS,
                 ASlaveReadDataxDO     => ASlaveReadDataxD,
                 ASlaveWritexSI        => ASlaveWritexS,
                 ASlaveWriteDataxDI    => ASlaveWriteDataxD,
                 AMasterAddressxDO     => open,
                 AMasterByteEnablexDBO  => open,
                 AMasterWritexSO       => open,
                 AMasterWriteDataxDO   => open,
                 AMasterWaitRequestxSI => '0',
                 FifoOutputDataxDI     => X"00000000",
                 FifoUsedxDI           => "00",
                 FifoReadReqxSO        => open);

    p_read_write : process is
        procedure write_slave(addr : in std_logic_vector(2 downto 0);
                              data : in std_logic_vector(31 downto 0)) is
        begin
            wait for CLK_PERIOD / 4;
            ASlaveChipSelectxS <= '1';
            ASlaveWritexS      <= '1';
            ASlaveAddressxD    <= addr;
            ASlaveWriteDataxD  <= data;
            wait for CLK_PERIOD;
            ASlaveChipSelectxS <= '0';
            ASlaveWritexS      <= '0';
            ASlaveAddressxD    <= (others => '0');
            ASlaveWriteDataxD  <= (others => '0');
            wait until rising_edge(CLKxC);
        end procedure write_slave;

        procedure read_slave(addr : in std_logic_vector(2 downto 0);
                             data : in std_logic_vector(31 downto 0)) is
        begin
            wait for CLK_PERIOD / 4;

            ASlaveChipSelectxS <= '1';
            ASlaveReadxS       <= '1';
            ASlaveAddressxD    <= addr;

            wait until rising_edge(CLKxC);
            wait until rising_edge(CLKxC);

            assert ASlaveReadDataxD = data report "Wrong data on the bus." severity error;

            wait for CLK_PERIOD / 4;

            ASlaveChipSelectxS <= '0';
            ASlaveReadxS       <= '0';
            ASlaveAddressxD    <= (others => '0');

            wait until rising_edge(CLKxC);
        end procedure read_slave;

    begin
        wait for 8 * CLK_PERIOD;
        wait until rising_edge(CLKxC);

        write_slave("000", DATA1);
        write_slave("001", DATA2);
        write_slave("010", DATA3);
        write_slave("011", DATA1);
        write_slave("111", DATA1);

        wait until rising_edge(CLKxC);

        read_slave("000", DATA1);
        read_slave("001", DATA2);
        read_slave("010", DATA3);
        read_slave("011", DATA1);

        -- Take only 7 LSB since I2C interface has 8-bit data bus
        read_slave("111", X"000000" & DATA1(7 downto 0));

        STOPxS <= '1';
        wait;
        wait;
    end process p_read_write;

end architecture RTL;
