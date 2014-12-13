library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity CameraController is
    generic(
        CAM_ROW_SIZE   : integer := 480;
        CAM_PIXEL_SIZE : integer := 12;
        RGB_PIXEL_SIZE : integer := 18);
    port(
        signal CameraPIXCLKxCI, RSTxRBI     : in  std_logic;
        signal CameraDataxDI                : in  std_logic_vector(CAM_PIXEL_SIZE - 1 downto 0);
        signal CameraLVALxSI, CameraFVALxSI : in  std_logic;
        signal RGBPixelxDO                  : out std_logic_vector(RGB_PIXEL_SIZE - 1 downto 0);
        signal RGBPixelValidxSO             : out std_logic);
end entity CameraController;

architecture RTL of CameraController is
    subtype rgb_color_t is std_logic_vector(RGB_PIXEL_SIZE / 3 - 1 downto 0);
    type rgb_color_buffer_t is array (CAM_ROW_SIZE downto 0) of rgb_color_t;
    signal RGBColorBufferxDP, RGBColorBufferxDN : rgb_color_buffer_t;
    constant ZERO_COLOR_BUFFER                  : rgb_color_buffer_t := (others => (others => '0'));

    signal AcquireEnxS : std_logic;

    constant PIXEL_COUNTER_WIDTH : integer  := integer(ceil(log2(real(CAM_ROW_SIZE)))) + 1;
    constant PIXEL_COUNTER_MAX   : unsigned := to_unsigned(CAM_ROW_SIZE, PIXEL_COUNTER_WIDTH);

    signal RowIsEvenxSP, RowIsEvenxSN       : std_logic;
    signal PixelCounterxDP, PixelCounterxDN : unsigned(PIXEL_COUNTER_WIDTH - 1 downto 0);

    signal GreenSumxD                 : unsigned(RGB_PIXEL_SIZE / 3 downto 0);
    signal GreenMeanxDP, GreenMeanxDN : unsigned(RGB_PIXEL_SIZE / 3 - 1 downto 0);
begin
    AcquireEnxS <= CameraFVALxSI and CameraLVALxSI;

    p_dffs : process(CameraPIXCLKxCI, RSTxRBI) is
    begin
        if RSTxRBI = '0' then
            PixelCounterxDP   <= PIXEL_COUNTER_MAX;
            RGBColorBufferxDP <= ZERO_COLOR_BUFFER;
            RowIsEvenxSP      <= '1';
            GreenMeanxDP      <= (others => '0');

        elsif falling_edge(CameraPIXCLKxCI) then
            if AcquireEnxS = '1' then
                PixelCounterxDP   <= PixelCounterxDN;
                RGBColorBufferxDP <= RGBColorBufferxDN;
                GreenMeanxDP      <= GreenMeanxDN;
            end if;

            RowIsEvenxSP <= RowIsEvenxSN;

        end if;
    end process p_dffs;

    p_next_counter_logic : process(PixelCounterxDP, AcquireEnxS) is
    begin
        PixelCounterxDN <= PixelCounterxDP - 1;

        if PixelCounterxDP = 0 then
            PixelCounterxDN <= PIXEL_COUNTER_MAX - 1;
        end if;

        if AcquireEnxS = '0' then
            PixelCounterxDN <= PIXEL_COUNTER_MAX;
        end if;
    end process p_next_counter_logic;

    RowIsEvenxSN <= '1' when AcquireEnxS = '0'
        else not RowIsEvenxSP when PixelCounterxDP = 0
        else RowIsEvenxSP;

    with AcquireEnxS select RGBColorBufferxDN(0) <=
        RGBColorBufferxDP(0) when '0',
        CameraDataxDI(CAM_PIXEL_SIZE - 1 downto CAM_PIXEL_SIZE - RGB_PIXEL_SIZE / 3) when others;

    with AcquireEnxS select RGBColorBufferxDN(CAM_ROW_SIZE downto 1) <=
        RGBColorBufferxDP(CAM_ROW_SIZE downto 1) when '0',
        RGBColorBufferxDP(CAM_ROW_SIZE - 1 downto 0) when others;

    RGBPixelValidxSO <= not (RowIsEvenxSP or PixelCounterxDP(0));

    GreenSumxD   <= resize(unsigned(RGBColorBufferxDP(CAM_ROW_SIZE)), GreenSumxD'length) + unsigned('0' & CameraDataxDI(CAM_PIXEL_SIZE - 1 downto CAM_PIXEL_SIZE - RGB_PIXEL_SIZE / 3));
    GreenMeanxDN <= GreenSumxD(RGB_PIXEL_SIZE / 3 downto 1);

    RGBPixelxDO <= RGBColorBufferxDP(CAM_ROW_SIZE - 1) & std_logic_vector(GreenMeanxDP) & RGBColorBufferxDP(1);

end architecture RTL;

