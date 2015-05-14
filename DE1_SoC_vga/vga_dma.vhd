library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_dma is
    port(
        clk                : in  std_logic;
        rst_n              : in  std_logic;

        -- signal from vga_controller
        dma_start_fetching : in  std_logic;

        -- FIFO signals
        fifo_clr           : out std_logic;
        fifo_data          : out std_logic_vector(31 downto 0);
        fifo_write         : out std_logic;
        fifo_full          : in  std_logic;

        -- Avalon 32-bit Master Interface (Read DMA)
        am_address         : out std_logic_vector(31 downto 0);
        am_byteenable      : out std_logic_vector(3 downto 0);
        am_read            : out std_logic;
        am_readdata        : in  std_logic_vector(31 downto 0);
        am_waitrequest     : in  std_logic
    );
end entity vga_dma;

architecture rtl of vga_dma is
    type state_type is (IDLE, READ_REQUEST, READ_DATA);
    signal state_reg, state_next     : state_type;
    signal counter_reg, counter_next : integer;

begin
    pr_fsm : process(am_readdata, am_waitrequest, counter_reg, dma_start_fetching, state_reg, fifo_full) is
    begin
        state_next   <= state_reg;
        counter_next <= counter_reg;

        am_address    <= (others => '0');
        am_read       <= '0';
        am_byteenable <= "1111";

        fifo_clr   <= '0';
        fifo_write <= '0';
        fifo_data  <= (others => '0');

        case state_reg is
            when IDLE =>
                if (dma_start_fetching = '1') then
                    state_next <= READ_REQUEST;
                    fifo_clr   <= '1';
                end if;
            when READ_REQUEST =>
                if (fifo_full = '0') then
                    am_address <= std_logic_vector(to_unsigned(counter_reg, 32));
                    am_read    <= '1';

                    if (am_waitrequest = '0') then
                        state_next <= READ_DATA;
                    end if;
                end if;
            when READ_DATA =>
                fifo_write <= '1';
                fifo_data  <= am_readdata;

                if (counter_reg < 153599) then -- 153599 = (640x480)/2 - 1
                    state_next   <= READ_REQUEST;
                    counter_next <= counter_reg + 1;
                else
                    state_next   <= IDLE;
                    counter_next <= 0;
                end if;
        end case;
    end process pr_fsm;

    pr_reg : process(clk, rst_n) is
    begin
        if rst_n = '0' then
            state_reg   <= IDLE;
            counter_reg <= 0;
        elsif rising_edge(clk) then
            state_reg   <= state_next;
            counter_reg <= counter_next;
        end if;
    end process pr_reg;

end architecture rtl;

