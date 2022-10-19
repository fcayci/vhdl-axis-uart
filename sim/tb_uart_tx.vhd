-- author: Furkan Cayci, 2018
-- description: uart tx testbench

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_tx is
end tb_uart_tx;

architecture rtl of tb_uart_tx is

    constant CLKFREQ     : integer := 125E6; -- 125 Mhz clock
    constant BAUDRATE    : integer := 115200;
    constant DATA_WIDTH  : integer := 8;
    constant PARITY      : string  := "ODD";
    constant STOP_WIDTH  : integer := 1;
    constant M           : integer := CLKFREQ / BAUDRATE;

    constant clk_period  : time := 8 ns;
    constant bit_time    : time := M * clk_period;
    constant data        : std_logic_vector(DATA_WIDTH-1 downto 0) := x"A5";
    constant parity_odd  : std_ulogic := '1'; -- A5 -> 10100101 -> parity: 1
    constant parity_even : std_ulogic := '0'; -- A5 -> 10100101 -> parity: 0

    signal clk           : std_logic := '0';
    signal txd           : std_logic;
    signal s_axis_tvalid : std_logic := '0';
    signal s_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_axis_tready : std_logic;

begin

    uut_tx: entity work.uart_tx
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map (clk=>clk, txd=>txd, s_axis_tvalid=>s_axis_tvalid,
                  s_axis_tdata=>s_axis_tdata, s_axis_tready=>s_axis_tready);

    clk_generate:
    process
    begin
        for i in 0 to 20 * M loop
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
        wait for 204 ns;
        s_axis_tdata <= data;
        s_axis_tvalid <= '1';
        wait until s_axis_tready = '0';
        s_axis_tvalid <= '0';

        -- check for start bit
        wait for bit_time/2;
        assert txd = '0'
            report "bad start value" severity error;
        -- check for data bits
        for i in data'range loop
            wait for bit_time;
            assert txd = data(i)
                report "bad data value" severity error;
        end loop;
        -- check for parity bit if it exists
        if PARITY /= "NONE" then
            wait for bit_time;
            -- checksum
            if PARITY = "ODD" then
                assert txd = parity_odd
                    report "bad odd partiy value" severity error;
            else
                assert txd = parity_even
                    report "bad even parity value" severity error;
            end if;
        end if;
        -- check for stop bit(s)
        for i in 0 to STOP_WIDTH-1 loop
            wait for bit_time;
            assert txd = '1'
                report "bad stop value" severity error;
        end loop;

        -- complete the simulation
        assert false report "successfully completed the test" severity note;

        wait;
    end process;
end rtl;
