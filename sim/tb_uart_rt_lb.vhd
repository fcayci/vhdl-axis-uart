-- author: Furkan Cayci, 2018
-- description: uart rx-tx loopback testbench
--    rx and tx lines are connected together
--    data is sent to s_axis_tdata incrementally
--    should pop out from m_axis_tdata

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_rt_lb is
end tb_uart_rt_lb;

architecture rtl of tb_uart_rt_lb is

    constant CLKFREQ    : integer := 125E6; -- 125 Mhz clock
    constant BAUDRATE   : integer := 115200;
    constant DATA_WIDTH : integer := 8;
    constant PARITY     : string  := "EVEN";
    constant STOP_WIDTH : integer := 1;
    constant M : integer := CLKFREQ / BAUDRATE;

    constant clk_period : time := 8 ns;
    constant bit_time   : time := M * clk_period;
    constant data       : std_logic_vector(DATA_WIDTH-1 downto 0) := x"A5";
    constant n_of_tests : integer := 40;

    signal clk  : std_logic := '0';
    signal txrx : std_logic;
    signal m_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_axis_tready : std_logic := '0';
    signal m_axis_tvalid : std_logic;
    signal s_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tready : std_logic;

begin

    -- connect rx/tx lines together in loopback mode
    uut : entity work.uart
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map(clk=>clk, rxd=>txrx, txd=>txrx,
                 m_axis_tvalid=>m_axis_tvalid, m_axis_tdata=>m_axis_tdata, m_axis_tready=>m_axis_tready,
                 s_axis_tvalid=>s_axis_tvalid, s_axis_tdata=>s_axis_tdata, s_axis_tready=>s_axis_tready);

    clk_generate:
    process
    begin
        for i in 0 to n_of_tests * 11 * M loop
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
        end loop;
        wait;
    end process;

    stimulus:
    process
    begin
        m_axis_tready <= '1';
        wait for 204 ns;
        for i in 0 to n_of_tests loop
            s_axis_tdata <= std_logic_vector(unsigned(data) + i);
            s_axis_tvalid <= '1';
            wait until s_axis_tready = '0';
            s_axis_tvalid <= '0';

            wait until m_axis_tvalid = '1';
            m_axis_tready <= '1';

            assert s_axis_tdata = m_axis_tdata
                report "received data does not match transmitted data" severity error;
            wait for clk_period;
        end loop;

        assert false report "completed test" severity note;

        wait;
    end process;
end rtl;
