library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CameraInterface is
    port(
        signal CPUCLKxCI             : in    std_logic;
        signal RSTxRBI               : in    std_logic;

        -- Avalon Slave Port Signals
        signal ASlaveChipSelectxSI   : in    std_logic;
        signal ASlaveAddressxDI      : in    std_logic_vector(2 downto 0);
        signal ASlaveReadxSI         : in    std_logic;
        signal ASlaveReadDataxDO     : out   std_logic_vector(31 downto 0);
        signal ASlaveWritexSI        : in    std_logic;
        signal ASlaveWriteDataxDI    : in    std_logic_vector(31 downto 0);

        -- Avalon Master Port Signals
        signal AMasterAddressxDO     : out   std_logic_vector(31 downto 0);
        signal AMasterByteEnablexDBO : out   std_logic_vector(3 downto 0);
        signal AMasterWritexSO       : out   std_logic;
        signal AMasterWriteDataxDO   : out   std_logic_vector(31 downto 0);
        signal AMasterWaitRequestxSI : in    std_logic;
        signal AMasterBurstCountxSO  : out   std_logic_vector(4 downto 0);

        signal CameraPIXCLKxCI       : in    std_logic;
        signal CameraDataxDI         : in    std_logic_vector(11 downto 0);
        signal CameraLVALxSI         : in    std_logic;
        signal CameraFVALxSI         : in    std_logic;
        signal CameraSCLxSI          : inout std_logic;
        signal CameraSDATAxSI        : inout std_logic
    );
end entity CameraInterface;

architecture RTL of CameraInterface is
    component AvalonInterfaces
        port(CLKxCI                          : in    std_logic;
             RSTxRBI                         : in    std_logic;
             ASlaveChipSelectxSI             : in    std_logic;
             ASlaveAddressxDI                : in    std_logic_vector(2 downto 0);
             ASlaveReadxSI                   : in    std_logic;
             ASlaveReadDataxDO               : out   std_logic_vector(31 downto 0);
             ASlaveWritexSI                  : in    std_logic;
             ASlaveWriteDataxDI              : in    std_logic_vector(31 downto 0);
             AMasterAddressxDO               : out   std_logic_vector(31 downto 0);
             AMasterByteEnablexDBO           : out   std_logic_vector(3 downto 0);
             AMasterWritexSO                 : out   std_logic;
             AMasterWriteDataxDO             : out   std_logic_vector(31 downto 0);
             AMasterWaitRequestxSI           : in    std_logic;
             AMasterBurstCountxSO            : out   std_logic_vector(4 downto 0);
             FifoOutputDataxDI               : in    std_logic_vector(31 downto 0);
             FifoUsedxDI                     : in    std_logic_vector(4 downto 0);
             FifoFullxSI                     : in    std_logic;
             FifoReadReqxSO, FifoAsyncClrxSO : out   std_logic;
             SCL                             : inout std_logic;
             SDA                             : inout std_logic);
    end component AvalonInterfaces;

    component fifo
        port(aclr    : IN  std_logic := '0';
             data    : IN  std_logic_vector(15 DOWNTO 0);
             rdclk   : IN  std_logic;
             rdreq   : IN  std_logic;
             wrclk   : IN  std_logic;
             wrreq   : IN  std_logic;
             q       : OUT std_logic_vector(31 DOWNTO 0);
             rdempty : OUT std_logic;
             rdusedw : OUT std_logic_vector(4 DOWNTO 0);
             wrfull  : OUT std_logic);
    end component fifo;

    component CameraController
        generic(CAM_ROW_SIZE   : integer := 480;
                CAM_PIXEL_SIZE : integer := 12;
                RGB_PIXEL_SIZE : integer := 18);
        port(CameraPIXCLKxCI, RSTxRBI     : in  std_logic;
             CameraDataxDI                : in  std_logic_vector(CAM_PIXEL_SIZE - 1 downto 0);
             CameraLVALxSI, CameraFVALxSI : in  std_logic;
             RGBPixelxDO                  : out std_logic_vector(RGB_PIXEL_SIZE - 1 downto 0);
             RGBPixelValidxSO             : out std_logic);
    end component CameraController;

    signal RGBPixelxD                                : std_logic_vector(17 downto 0);
    signal RGBPixelFormattedxD                       : std_logic_vector(15 downto 0);
    signal RGBPixelValidxS                           : std_logic;
    signal FifoOutputDataxD                          : std_logic_vector(31 downto 0);
    signal FifoUsedxD                                : std_logic_vector(4 downto 0);
    signal FifoReadReqxS, FifoFullxS, FifoAsyncClrxS : std_logic;
begin
    AvalonInterfaces_inst : component AvalonInterfaces
        port map(CLKxCI                => CPUCLKxCI,
                 RSTxRBI               => RSTxRBI,
                 ASlaveChipSelectxSI   => ASlaveChipSelectxSI,
                 ASlaveAddressxDI      => ASlaveAddressxDI,
                 ASlaveReadxSI         => ASlaveReadxSI,
                 ASlaveReadDataxDO     => ASlaveReadDataxDO,
                 ASlaveWritexSI        => ASlaveWritexSI,
                 ASlaveWriteDataxDI    => ASlaveWriteDataxDI,
                 AMasterAddressxDO     => AMasterAddressxDO,
                 AMasterByteEnablexDBO => AMasterByteEnablexDBO,
                 AMasterWritexSO       => AMasterWritexSO,
                 AMasterWriteDataxDO   => AMasterWriteDataxDO,
                 AMasterWaitRequestxSI => AMasterWaitRequestxSI,
                 AMasterBurstCountxSO  => AMasterBurstCountxSO,
                 FifoOutputDataxDI     => FifoOutputDataxD,
                 FifoUsedxDI           => FifoUsedxD,
                 FifoFullxSI           => FifoFullxS,
                 FifoReadReqxSO        => FifoReadReqxS,
                 FifoAsyncClrxSO       => FifoAsyncClrxS,
                 SCL                   => CameraSCLxSI,
                 SDA                   => CameraSDATAxSI);

    RGBPixelFormattedxD <= RGBPixelxD(17 downto 13) & RGBPixelxD(11 downto 6) & RGBPixelxD(5 downto 1);
    fifo_inst : fifo
        port map(aclr    => FifoAsyncClrxS,
                 data    => RGBPixelFormattedxD,
                 rdclk   => CPUCLKxCI,
                 rdreq   => FifoReadReqxS,
                 wrclk   => CameraPIXCLKxCI,
                 wrreq   => RGBPixelValidxS,
                 q       => FifoOutputDataxD,
                 rdusedw => FifoUsedxD,
                 wrfull  => FifoFullxS);

    CameraController_inst : CameraController
        port map(CameraPIXCLKxCI  => CameraPIXCLKxCI,
                 RSTxRBI          => RSTxRBI,
                 CameraDataxDI    => CameraDataxDI,
                 CameraLVALxSI    => CameraLVALxSI,
                 CameraFVALxSI    => CameraFVALxSI,
                 RGBPixelxDO      => RGBPixelxD,
                 RGBPixelValidxSO => RGBPixelValidxS);

end architecture RTL;
