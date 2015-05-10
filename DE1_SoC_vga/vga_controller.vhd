LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
	port(

		-- 25 MHz pixel clock
		pixel_clk          : in  std_logic;
		rst_n              : in  std_logic;

		-- Start drawing frames
--		start              : in  std_logic;

		-- Stop and reset the controller to the default state
--		stop               : in  std_logic;

		-- Tell DMA to start prefetching
--		dma_start_fetching : out std_logic;

		-- Tell system of vsync
--		vsync              : out std_logic;

		-- FIFO Signals
--		fifo_empty         : in  std_logic;
--		fifo_read          : out std_logic;
--		fifo_data          : in  std_logic_vector(31 downto 0);

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

ARCHITECTURE MAIN OF vga_controller IS
	SIGNAL h_pos : INTEGER RANGE 0 TO 1688 := 0;
	SIGNAL v_pos : INTEGER RANGE 0 TO 1066 := 0;

	SIGNAL enable : STD_LOGIC_VECTOR(7 downto 0);
	signal videoh : std_logic;
	signal videov : std_logic;
BEGIN
	PROCESS(pixel_clk, rst_n)
	BEGIN
		IF (rst_n = '0') THEN
			vga_r <= (others => '0');
			vga_g <= (others => '0');
			vga_b <= (others => '0');

		ELSE
			IF (pixel_clk'EVENT AND pixel_clk = '1') THEN
				vga_r <= (others => '1') and enable;
				vga_g <= (others => '1') and enable;
				vga_b <= (others => '0') and enable;
			END IF;
		END IF;
	END PROCESS;

	PROCESS(h_pos, v_pos)
	BEGIN
		videov <= '1';
		videoh <= '1';

		IF (h_pos >= 640) THEN
			videoh <= '0';
		END IF;
		IF (v_pos >= 480) THEN
			videov <= '0';
		END IF;
	END PROCESS;

	enable <= (OTHERS => '1') WHEN videoh = '1' AND videov = '1' ELSE (OTHERS => '0');
	vga_clk <= pixel_clk;
	vga_blank_n <= '1';
	vga_sync_n <= '1';
	
	PROCESS(pixel_clk, rst_n)
	BEGIN
		IF (rst_n = '0') THEN
			v_pos  <= 0;
			h_pos  <= 0;
			vga_hs <= '0';
			vga_vs <= '0';

		ELSE
			IF (pixel_clk'EVENT AND pixel_clk = '1') THEN

				-- Each clock cycle increases h_pos.
				-- If hpos is at the end of the line increase vpos
				IF (h_pos < 799) THEN
					h_pos <= h_pos + 1;
				ELSE
					-- Restart h_pos whn end of line
					h_pos <= 0;
					IF (v_pos < 523) THEN
						v_pos <= v_pos + 1;
					ELSE
						v_pos <= 0;
					END IF;
				END IF;

				---- Generate HSYNC
				IF ((640 + 16) <= h_pos AND h_pos < (656 + 96)) THEN
					vga_hs <= '1';
				ELSE
					vga_hs <= '0';
				END IF;

				------ Generate VSYNC
				IF ((480 + 11) <= v_pos AND v_pos <= (493)) THEN
					vga_vs <= '1';
				ELSE
					vga_vs <= '0';
				END IF;

			END IF;
		END IF;
	END PROCESS;
END MAIN;