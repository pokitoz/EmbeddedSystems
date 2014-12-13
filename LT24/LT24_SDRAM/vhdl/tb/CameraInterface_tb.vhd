library ieee;
use ieee.std_logic_1164.all;

entity CameraInterface_tb is
end entity CameraInterface_tb;

architecture RTL of CameraInterface_tb is
    component CameraInterface
        port(CPUCLKxCI                    : in  std_logic;
             CameraCLKxCI                 : in  std_logic;
             RSTxRBI                      : in  std_logic;
             ASlaveChipSelectxSI          : in  std_logic;
             ASlaveAddressxDI             : in  std_logic_vector(2 downto 0);
             ASlaveReadxSI                : in  std_logic;
             ASlaveReadDataxDO            : out std_logic_vector(31 downto 0);
             ASlaveWritexSI               : in  std_logic;
             ASlaveWriteDataxDI           : in  std_logic_vector(31 downto 0);
             AMasterAddressxDO            : out std_logic_vector(31 downto 0);
             AMasterByteEnablexDBO         : out std_logic_vector(3 downto 0);
             AMasterWritexSO              : out std_logic;
             AMasterWriteDataxDO          : out std_logic_vector(31 downto 0);
             AMasterWaitRequestxSI        : in  std_logic;
             CameraDataxDI                : in  std_logic_vector(11 downto 0);
             CameraLVALxSI, CameraFVALxSI : in  std_logic);
    end component CameraInterface;

    signal CPUCLKxC                   : std_logic                     := '1';
    signal CameraCLKxC                : std_logic                     := '1';
    signal RSTxRB                     : std_logic;
    signal ASlaveChipSelectxS         : std_logic                     := '0';
    signal ASlaveAddressxD            : std_logic_vector(2 downto 0)  := (others => '0');
    signal ASlaveReadxS               : std_logic                     := '0';
    signal ASlaveReadDataxD           : std_logic_vector(31 downto 0) := (others => '0');
    signal ASlaveWritexS              : std_logic                     := '0';
    signal ASlaveWriteDataxD          : std_logic_vector(31 downto 0) := (others => '0');
    signal AMasterAddressxD           : std_logic_vector(31 downto 0) := (others => '0');
    signal AMasterByteEnablexD        : std_logic_vector(3 downto 0)  := (others => '0');
    signal AMasterWritexS             : std_logic                     := '0';
    signal AMasterWriteDataxD         : std_logic_vector(31 downto 0) := (others => '0');
    signal AMasterWaitRequestxS       : std_logic                     := '0';
    signal CameraDataxD               : std_logic_vector(11 downto 0) := (others => '0');
    signal CameraLVALxS, CameraFVALxS : std_logic                     := '0';

    signal CamStimStartxS : std_logic := '0';

    constant CPUCLK_PERIOD    : time := 20 ns;
    constant CameraCLK_PERIOD : time := 100 ns;
begin
    CameraInterface_inst : CameraInterface
        port map(CPUCLKxCI             => CPUCLKxC,
                 CameraCLKxCI          => CameraCLKxC,
                 RSTxRBI               => RSTxRB,
                 ASlaveChipSelectxSI   => ASlaveChipSelectxS,
                 ASlaveAddressxDI      => ASlaveAddressxD,
                 ASlaveReadxSI         => ASlaveReadxS,
                 ASlaveReadDataxDO     => ASlaveReadDataxD,
                 ASlaveWritexSI        => ASlaveWritexS,
                 ASlaveWriteDataxDI    => ASlaveWriteDataxD,
                 AMasterAddressxDO     => AMasterAddressxD,
                 AMasterByteEnablexDBO  => AMasterByteEnablexD,
                 AMasterWritexSO       => AMasterWritexS,
                 AMasterWriteDataxDO   => AMasterWriteDataxD,
                 AMasterWaitRequestxSI => AMasterWaitRequestxS,
                 CameraDataxDI         => CameraDataxD,
                 CameraLVALxSI         => CameraLVALxS,
                 CameraFVALxSI         => CameraFVALxS);

    CPUCLKxC    <= not CPUCLKxC after CPUCLK_PERIOD / 2;
    CameraCLKxC <= not CameraCLKxC after CameraCLK_PERIOD / 2;

    p_rst_gen : process
    begin
        RSTxRB <= '0';
        wait for 2 * CameraCLK_PERIOD;
        RSTxRB <= '1';
        wait;
    end process p_rst_gen;

    p_enabling_dma : process is
        variable data_to_write : std_logic_vector(31 downto 0) := (others => '0');
    begin
        wait until rising_edge(RSTxRB);
        wait until rising_edge(CPUCLKxC);
        wait for 3 * CPUCLK_PERIOD / 4;

        ASlaveAddressxD <= "001";

        data_to_write(8) := '1';
        data_to_write(6) := '1';

        ASlaveWriteDataxD  <= data_to_write;
        ASlaveWritexS      <= '1';
        ASlaveChipSelectxS <= '1';

        wait for CPUCLK_PERIOD;
        CamStimStartxS <= '1';

        ASlaveWriteDataxD  <= (others => '0');
        ASlaveWritexS      <= '0';
        ASlaveChipSelectxS <= '0';

        wait;
    end process p_enabling_dma;

    p_camera_stimulus : process
    begin
        wait until rising_edge(CamStimStartxS);
        wait until rising_edge(CameraCLKxC);
        wait for 3 * CameraCLK_PERIOD / 4;
        CameraFVALxS <= '1';
        wait for CameraCLK_PERIOD;
        CameraLVALxS <= '1';

        for i in 0 to 480 * 160 loop
            CameraDataxD <= X"ABC";
            wait for CameraCLK_PERIOD;
            CameraDataxD <= X"FFF";
            wait for CameraCLK_PERIOD;
        end loop;
        CameraLVALxS <= '0';
        wait for 3 * CameraCLK_PERIOD;
        CameraFVALxS <= '0';

        wait;
    end process p_camera_stimulus;

    p_waitrequest_gen : process is
    begin
        wait until AMasterAddressxD = X"0000000C";
        wait for CameraCLK_PERIOD / 4;

        AMasterWaitRequestxS <= '1';
        wait for 3 * CameraCLK_PERIOD;
        AMasterWaitRequestxS <= '0';

        wait;
    end process p_waitrequest_gen;

end architecture RTL;
