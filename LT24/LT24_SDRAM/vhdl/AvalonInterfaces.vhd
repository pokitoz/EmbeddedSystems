library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AvalonInterfaces is
    port(
        signal CLKxCI                          : in    std_logic;
        signal RSTxRBI                         : in    std_logic;

        -- Avalon Slave Port Signals
        signal ASlaveChipSelectxSI             : in    std_logic;
        signal ASlaveAddressxDI                : in    std_logic_vector(2 downto 0);
        signal ASlaveReadxSI                   : in    std_logic;
        signal ASlaveReadDataxDO               : out   std_logic_vector(31 downto 0);
        signal ASlaveWritexSI                  : in    std_logic;
        signal ASlaveWriteDataxDI              : in    std_logic_vector(31 downto 0);

        -- Avalon Master Port Signals
        signal AMasterAddressxDO               : out   std_logic_vector(31 downto 0);
        signal AMasterByteEnablexDBO           : out   std_logic_vector(3 downto 0);
        signal AMasterWritexSO                 : out   std_logic;
        signal AMasterWriteDataxDO             : out   std_logic_vector(31 downto 0);
        signal AMasterWaitRequestxSI           : in    std_logic;
        signal AMasterBurstCountxSO            : out   std_logic_vector(4 downto 0);

        -- FIFO signals
        signal FifoOutputDataxDI               : in    std_logic_vector(31 downto 0);
        signal FifoUsedxDI                     : in    std_logic_vector(4 downto 0);
        signal FifoFullxSI                     : in    std_logic;
        signal FifoReadReqxSO, FifoAsyncClrxSO : out   std_logic;

        -- I2C signals
        signal SCL                             : inout std_logic;
        signal SDA                             : inout std_logic
    );
end entity AvalonInterfaces;

architecture RTL of AvalonInterfaces is
    component i2c_interface
        port(clk        : in    std_logic;
             reset      : in    std_logic;
             address    : in    std_logic_vector(1 downto 0);
             chipselect : in    std_logic;
             write      : in    std_logic;
             writedata  : in    std_logic_vector(7 downto 0);
             read       : in    std_logic;
             readdata   : out   std_logic_vector(7 downto 0);
             irq        : out   std_logic;
             scl        : inout std_logic;
             sda        : inout std_logic);
    end component i2c_interface;

    -- DMA Registers Signals
    signal DMAStatusxDP, DMAStatusxDN : std_logic_vector(5 downto 0); -- all status except I2C status
    constant STATUS_FIFO_FULL_POS     : integer := 0;
    constant STATUS_IPE_POS           : integer := STATUS_FIFO_FULL_POS + 1;
    constant STATUS_LEN_POS           : integer := STATUS_IPE_POS + 1;
    constant STATUS_WEOP_POS          : integer := STATUS_LEN_POS + 1;
    constant STATUS_BUSY_POS          : integer := STATUS_WEOP_POS + 1;
    constant STATUS_DONE_POS          : integer := STATUS_BUSY_POS + 1;

    signal DMAControlxDP, DMAControlxDN : std_logic_vector(2 downto 0);
    constant CTRL_LEEN_POS              : integer := 0;
    constant CTRL_IEN_POS               : integer := CTRL_LEEN_POS + 1;
    constant CTRL_GO_POS                : integer := CTRL_IEN_POS + 1;

    signal DMAStartAddressxDP, DMAStartAddressxDN : std_logic_vector(31 downto 0);
    signal DMALengthxDP, DMALengthxDN             : unsigned(31 downto 0);

    -- Avalon Slave Read Internal Signals To Store Last Address
    subtype ASlaveAddress_t is std_logic_vector(2 downto 0);
    signal ASlaveReadEnablexDP, ASlaveReadEnablexDN   : std_logic;
    signal ASlaveLastAddressxDP, ASlaveLastAddressxDN : ASlaveAddress_t;

    -- Avalon Slave I2C signals
    signal ASlaveI2CSelect   : std_logic;
    signal ASlaveI2CReadData : std_logic_vector(7 downto 0);
    signal ASlaveI2CIRQ      : std_logic;

    -- Avalon Slave Address Map
    constant ASlaveStatusAddr       : ASlaveAddress_t := "000";
    constant ASlaveControlAddr      : ASlaveAddress_t := "001";
    constant ASlaveStartAddressAddr : ASlaveAddress_t := "010";
    constant ASlaveLengthAddr       : ASlaveAddress_t := "011";

    constant ASlaveI2CDR : ASlaveAddress_t := "100";
    constant ASlaveI2CCD : ASlaveAddress_t := "101";
    signal I2CAddr       : std_logic_vector(1 downto 0);

    -- Avalon Master
    type state_t is (IDLE, READING, WRITING);
    signal StatexSP, StatexSN : state_t;

    signal DataBufferxDP, DataBufferxDN : std_logic_vector(31 downto 0);

    signal RSTxR : std_logic;

    signal InternalBurstCountxDP, InternalBurstCountxDN : unsigned(3 downto 0);

begin
    RSTxR <= not RSTxRBI;

    I2CINT : i2c_interface
        port map(clk        => CLKxCI,
                 reset      => RSTxR,
                 address    => I2CAddr,
                 chipselect => ASlaveI2CSelect,
                 write      => ASlaveWritexSI,
                 writedata  => ASlaveWriteDataxDI(7 downto 0),
                 read       => ASlaveReadxSI,
                 readdata   => ASlaveI2CReadData,
                 irq        => ASlaveI2CIRQ,
                 scl        => SCL,
                 sda        => SDA);

    ASlaveI2CSelect <= '1' when ASlaveChipSelectxSI = '1' and (ASlaveAddressxDI = ASlaveStatusAddr or ASlaveAddressxDI = ASlaveControlAddr or unsigned(ASlaveAddressxDI) > unsigned(ASlaveLengthAddr)) else '0';
    I2CAddr         <= "00" when ASlaveAddressxDI = ASlaveI2CDR
        else "01" when ASlaveAddressxDI = ASlaveControlAddr
        else "10" when ASlaveAddressxDI = ASlaveStatusAddr
        else "11" when ASlaveAddressxDI = ASlaveI2CCD;

    -- Generate all the DFFs needed
    p_registers : process(CLKxCI, RSTxRBI) is
    begin
        if RSTxRBI = '0' then
            StatexSP <= IDLE;

            DMAStatusxDP       <= (others => '0');
            DMAControlxDP      <= (others => '0');
            DMAStartAddressxDP <= (others => '0');
            DMALengthxDP       <= (others => '0');

            ASlaveReadEnablexDP  <= '0';
            ASlaveLastAddressxDP <= (others => '0');

            DataBufferxDP <= (others => '0');

            InternalBurstCountxDP <= X"F";

        elsif rising_edge(CLKxCI) then
            StatexSP              <= StatexSN;
            DMAStatusxDP          <= DMAStatusxDN;
            DMAControlxDP         <= DMAControlxDN;
            DMAStartAddressxDP    <= DMAStartAddressxDN;
            DMALengthxDP          <= DMALengthxDN;
            DataBufferxDP         <= DataBufferxDN;
            InternalBurstCountxDP <= InternalBurstCountxDN;

            -- Avalon Slave Write Logic
            if ASlaveWritexSI = '1' and ASlaveChipSelectxSI = '1' then
                case ASlaveAddressxDI is
                    when ASlaveControlAddr =>
                        DMAControlxDP <= ASlaveWriteDataxDI(8 downto 6);
                    when ASlaveStartAddressAddr =>
                        DMAStartAddressxDP <= ASlaveWriteDataxDI;
                    when ASlaveLengthAddr =>
                        DMALengthxDP <= unsigned(ASlaveWriteDataxDI);
                    when others => null;
                end case;

            end if;

            ASlaveReadEnablexDP  <= ASlaveReadEnablexDN;
            ASlaveLastAddressxDP <= ASlaveLastAddressxDN;

        end if;
    end process p_registers;

    ASlaveLastAddressxDN <= ASlaveAddressxDI;
    ASlaveReadEnablexDN  <= ASlaveChipSelectxSI and ASlaveReadxSI;

    DMAControlxDN <= DMAControlxDP;

    -- Avalon Slave Read Process
    p_aslave_read : process(ASlaveReadEnablexDP, ASlaveLastAddressxDP, DMAControlxDP, DMAStatusxDP, DMALengthxDP, DMAStartAddressxDP, ASlaveI2CReadData)
    begin
        ASlaveReadDataxDO <= (others => '0');

        if ASlaveReadEnablexDP = '1' then
            case ASlaveLastAddressxDP is
                when ASlaveStatusAddr =>
                    ASlaveReadDataxDO <= (31 downto 10 => '0') & DMAStatusxDP & ASlaveI2CReadData(3 downto 0);
                when ASlaveControlAddr =>
                    ASlaveReadDataxDO <= (31 downto 9 => '0') & DMAControlxDP & ASlaveI2CReadData(5 downto 0);
                when ASlaveStartAddressAddr =>
                    ASlaveReadDataxDO <= DMAStartAddressxDP;
                when ASlaveLengthAddr =>
                    ASlaveReadDataxDO <= std_logic_vector(DMALengthxDP);
                when others =>
                    ASlaveReadDataxDO(7 downto 0) <= ASlaveI2CReadData;
            end case;

        end if;
    end process p_aslave_read;

    -- Avalon Master Port Processes

    AMasterByteEnablexDBO <= (others => '0');

    p_amaster_next_state_logic : process(AMasterWaitRequestxSI, FifoUsedxDI, StatexSP, InternalBurstCountxDP, DMAControlxDP, DMALengthxDP) is
    begin
        StatexSN <= StatexSP;

        case StatexSP is
            when IDLE =>
                if DMAControlxDP(CTRL_GO_POS) = '1' and unsigned(FifoUsedxDI) >= "10000" then
                    StatexSN <= READING;
                end if;

            when READING =>
                StatexSN <= WRITING;

            when WRITING =>
                if AMasterWaitRequestxSI = '0' and (InternalBurstCountxDP = 0 or (DMALengthxDP = 0 and DMAControlxDP(CTRL_LEEN_POS) = '1')) then
                    StatexSN <= IDLE;
                end if;
        end case;
    end process p_amaster_next_state_logic;

    p_amaster_datapath : process(DMAStartAddressxDP, DataBufferxDP, FifoOutputDataxDI, StatexSP, AMasterWaitRequestxSI, InternalBurstCountxDP, DMALengthxDP, DMAStatusxDP, FifoUsedxDI, DMAControlxDP, FifoFullxSI) is
    begin
        AMasterAddressxDO    <= (others => '0');
        AMasterWritexSO      <= '0';
        AMasterWriteDataxDO  <= (others => '0');
        AMasterBurstCountxSO <= (others => '0');

        InternalBurstCountxDN <= X"F";

        FifoReadReqxSO <= '0';

        DataBufferxDN <= DataBufferxDP;

        DMAStartAddressxDN                 <= DMAStartAddressxDP;
        DMALengthxDN                       <= DMALengthxDP;
        DMAStatusxDN                       <= DMAStatusxDP;
        DMAStatusxDN(STATUS_FIFO_FULL_POS) <= FifoFullxSI;

        case StatexSP is
            when IDLE =>
                if DMAControlxDP(CTRL_GO_POS) = '1' and unsigned(FifoUsedxDI) >= "10000" then
                    DMAStatusxDN(STATUS_BUSY_POS) <= '1';
                    DMAStatusxDN(STATUS_DONE_POS) <= '0';
                    DMAStatusxDN(STATUS_WEOP_POS) <= '0';
                    DMAStatusxDN(STATUS_LEN_POS)  <= '0';

                end if;
            when READING =>
                FifoReadReqxSO <= '1';
                DataBufferxDN  <= FifoOutputDataxDI;

            when WRITING =>
                AMasterAddressxDO    <= DMAStartAddressxDP;
                AMasterWritexSO      <= '1';
                AMasterWriteDataxDO  <= DataBufferxDP;
                AMasterBurstCountxSO <= "10000";

                InternalBurstCountxDN <= InternalBurstCountxDP;

                if AMasterWaitRequestxSI = '0' then
                    DMAStartAddressxDN    <= std_logic_vector(unsigned(DMAStartAddressxDP) + 4);
                    DMALengthxDN          <= DMALengthxDP - 4;
                    InternalBurstCountxDN <= InternalBurstCountxDP - 1;

                    if DMALengthxDP = 0 then
                        DMAStatusxDN(STATUS_BUSY_POS) <= '0';
                        DMAStatusxDN(STATUS_DONE_POS) <= '1';
                        DMAStatusxDN(STATUS_WEOP_POS) <= '0';

                    elsif InternalBurstCountxDP /= 0 then
                        FifoReadReqxSO <= '1';
                        DataBufferxDN  <= FifoOutputDataxDI;

                    elsif DMAControlxDP(CTRL_LEEN_POS) = '1' and DMALengthxDP = 0 then
                        DMAStatusxDN(STATUS_BUSY_POS) <= '0';
                        DMAStatusxDN(STATUS_DONE_POS) <= '1';
                        DMAStatusxDN(STATUS_LEN_POS)  <= '1';

                    end if;
                end if;

        end case;
    end process p_amaster_datapath;

    FifoAsyncClrxSO <= not DMAControlxDP(CTRL_GO_POS);

end architecture RTL;

