library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CameraController_tb is
end entity CameraController_tb;

architecture RTL of CameraController_tb is
    constant RGB_PIXEL_SIZE : integer := 6;

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

    signal CLKxC                                    : std_logic                                     := '0';
    signal RSTxRB                                   : std_logic                                     := '0';
    signal CameraDataxD                             : std_logic_vector(1 downto 0)                  := (others => '0');
    signal CameraLVALxS, CameraFVALxS, PixelValidxS : std_logic                                     := '0';
    signal RGBPixelxD                               : std_logic_vector(RGB_PIXEL_SIZE - 1 downto 0) := (others => '0');
    signal StopxS                                   : std_logic                                     := '0';

    constant CLK_PERIOD : time := 40 ns;
begin
    DUV : CameraController
        generic map(CAM_ROW_SIZE   => 4,
                    CAM_PIXEL_SIZE => 2,
                    RGB_PIXEL_SIZE => RGB_PIXEL_SIZE)
        port map(CameraPIXCLKxCI  => CLKxC,
                 RSTxRBI          => RSTxRB,
                 CameraDataxDI    => CameraDataxD,
                 CameraLVALxSI    => CameraLVALxS,
                 CameraFVALxSI    => CameraFVALxS,
                 RGBPixelxDO      => RGBPixelxD,
                 RGBPixelValidxSO => PixelValidxS);

    CGEN : process
    begin
        CLKxC <= '0';
        wait for CLK_PERIOD / 2;
        CLKxC <= '1';
        wait for CLK_PERIOD / 2;

        if StopxS = '1' then
            wait;
        end if;
    end process CGEN;

    RSTGEN : process
    begin
        RSTxRB <= '0';
        wait for 2 * CLK_PERIOD;
        RSTxRB <= '1';
        wait;
    end process RSTGEN;

    CAM : process
    begin
        wait for 21 * CLK_PERIOD / 4;
        CameraFVALxS <= '1';

        -- ROW 1
        wait for 2 * CLK_PERIOD;
        CameraLVALxS <= '1';
        CameraDataxD <= "01";           -- G1, 1
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- R, 1
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- G1, 2
        wait for CLK_PERIOD;
        CameraDataxD <= "01";           -- R, 2

        -- ROW 2
        wait for CLK_PERIOD;
        CameraDataxD <= "01";           -- B, 1
        wait for CLK_PERIOD;
        CameraDataxD <= "10";           -- G2, 1
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- B, 2
        wait for CLK_PERIOD;
        CameraDataxD <= "10";           -- G2, 2

        -- ROW 3
        wait for CLK_PERIOD;
        CameraLVALxS <= '1';
        CameraDataxD <= "01";           -- G1, 3
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- R, 3
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- G1, 4
        wait for CLK_PERIOD;
        CameraDataxD <= "01";           -- R, 4

        -- ROW 4
        wait for CLK_PERIOD;
        CameraDataxD <= "01";           -- B, 3
        wait for CLK_PERIOD;
        CameraDataxD <= "10";           -- G2, 3
        wait for CLK_PERIOD;
        CameraDataxD <= "11";           -- B, 4
        wait for CLK_PERIOD;
        CameraDataxD <= "10";           -- G2, 4

        wait for CLK_PERIOD;
        CameraLVALxS <= '0';
        wait for 2 * CLK_PERIOD;
        CameraFVALxS <= '0';
        wait for 21 * CLK_PERIOD / 4;
        StopxS <= '1';
        wait;
    end process CAM;

    TEST : process
    begin
        wait until rising_edge(CLKxC) and PixelValidxS = '1';
        assert RGBPixelxD = "110101" report "Wrong pixel value!" severity error;

        wait until rising_edge(CLKxC) and PixelValidxS = '1';
        assert RGBPixelxD = "011011" report "Wrong pixel value!" severity error;

        wait until rising_edge(CLKxC) and PixelValidxS = '1';
        assert RGBPixelxD = "110101" report "Wrong pixel value!" severity error;

        wait until rising_edge(CLKxC) and PixelValidxS = '1';
        assert RGBPixelxD = "011011" report "Wrong pixel value!" severity error;

        if StopxS = '1' then
            wait;
        end if;
    end process;

end architecture;
