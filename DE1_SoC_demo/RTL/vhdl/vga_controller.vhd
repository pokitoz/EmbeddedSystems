library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
    port(

        -- 25 MHz pixel clock
        pixel_clk          : in  std_logic;
        rst_n              : in  std_logic;

        -- Tell DMA to start prefetching
        dma_start_fetching : out std_logic;

        -- Tell system of vsync
        vsync              : out std_logic;

        -- FIFO Signals
        fifo_empty         : in  std_logic;
        fifo_read          : out std_logic;
        fifo_data          : in  std_logic_vector(7 downto 0);

        -- Output to VGA DAC
        vga_r              : out std_logic_vector(7 downto 0);
        vga_g              : out std_logic_vector(7 downto 0);
        vga_b              : out std_logic_vector(7 downto 0);
        vga_clk            : out std_logic;
        vga_sync_n         : out std_logic;
        vga_blank_n        : out std_logic;

        -- Direct Output to VGA Connector
        vga_vs             : out std_logic;
        vga_hs             : out std_logic
    );
end entity vga_controller;

architecture rtl of vga_controller is
    signal h_pos : integer;
    signal v_pos : integer;

    signal enable : std_logic;
    signal videoh : std_logic;
    signal videov : std_logic;

begin
    process(pixel_clk, rst_n) is
    begin
        if rst_n = '0' then
            vga_r <= X"00";
            vga_g <= X"00";
            vga_b <= X"00";
        elsif rising_edge(pixel_clk) then
            if (enable = '1' and fifo_empty = '0') then
                vga_r <= fifo_data(7 downto 5) & "00000";
                vga_g <= fifo_data(4 downto 2) & "00000";
                vga_b <= fifo_data(1 downto 0) & "000000";
            else
                vga_r <= X"00";
                vga_g <= X"00";
                vga_b <= X"00";
            end if;
        end if;
    end process;

    process(pixel_clk, rst_n) is
    begin
        if rst_n = '0' then
            fifo_read <= '0';
        elsif rising_edge(pixel_clk) then
		  
				fifo_read <= '0';
            
				if(v_pos < 480) then
					if(h_pos < 639 or h_pos = 799) then
						fifo_read <= '1';
					end if;
				end if;
				
				if(v_pos = 524 and h_pos >= 798) then
					fifo_read <= '1';
				end if;
        end if;
    end process;

    process(h_pos, v_pos)
    begin
        videov <= '1';
        videoh <= '1';

        if (h_pos >= 640) then
            videoh <= '0';
        end if;
        if (v_pos >= 480) then
            videov <= '0';
        end if;
    end process;

    process(pixel_clk, rst_n)
    begin
        if (rst_n = '0') then
            v_pos  <= 0;
            h_pos  <= 0;
            vga_hs <= '0';
            vga_vs <= '0';
            vsync  <= '0';

        elsif (rising_edge(pixel_clk)) then

            -- Each clock cycle increases h_pos.
            -- If hpos is at the end of the line increase vpos
            if (h_pos < 799) then
                h_pos <= h_pos + 1;
            else
                -- Restart h_pos when end of line
                h_pos <= 0;
                if (v_pos < 524) then
                    v_pos <= v_pos + 1;
                else
                    v_pos <= 0;
                end if;
            end if;

            ------ Generate HSYNC
            IF (659 <= h_pos and h_pos <= 755) then
                vga_hs <= '0';
            else
                vga_hs <= '1';
            end if;

            ------ Generate VSYNC
            if (493 <= v_pos and v_pos <= 494) then
                vga_vs             <= '0';
					 dma_start_fetching <= '1';
            else
                vga_vs             <= '1';
					 dma_start_fetching <= '0';
            end if;
            
            ------ VSYNC irq
            if (481 <= v_pos and v_pos <= 482) then
                vsync              <= '1';
            else
                vsync              <= '0';
            end if;

        end if;
    end process;
    enable      <= '1' when ((videoh = '1' and videov = '1') or (h_pos=799 and v_pos=524)) else '0';
    vga_clk     <= pixel_clk;
    vga_blank_n <= '1';
    vga_sync_n  <= '1';

end rtl;