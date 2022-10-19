-- author: Furkan Cayci, 2018
-- description: uart axis loopback testbench
--    axis lines are connected together
--    data is sent to rx
--    should pop out from tx

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_axis_lb is
end tb_uart_axis_lb;

architecture rtl of tb_uart_axis_lb is

    constant CLKFREQ     : integer := 125E6; -- 125 Mhz clock
    constant BAUDRATE    : integer := 115200;
    constant DATA_WIDTH  : integer := 8;
    constant PARITY      : string  := "ODD";

    constant STOP_WIDTH  : integer := 1;
    constant M           : integer := CLKFREQ / BAUDRATE;

    constant clk_period  : time := 8 ns;
    constant bit_time    : time := M * clk_period;
    constant reset_time  : time := 204 ns;
    constant n_of_tests  : integer := 20;

    signal data          : unsigned(DATA_WIDTH-1 downto 0) := x"0A";
    signal clk           : std_logic;
    signal txd, rxd      : std_logic;
    signal axis_tdata    : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal axis_tready   : std_logic;
    signal axis_tvalid   : std_logic;

begin

    -- connect axis lines together in loopback mode
    uut : entity work.uart(rtl)
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map(clk=>clk, rxd=>rxd, txd=>txd,
                 m_axis_tvalid=>axis_tvalid, m_axis_tdata=>axis_tdata, m_axis_tready=>axis_tready,
                 s_axis_tvalid=>axis_tvalid, s_axis_tdata=>axis_tdata, s_axis_tready=>axis_tready);

    -- generate clock
    clk_generate:
    process
    begin
        for i in 0 to n_of_tests * 13 * M loop
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
        end loop;
        wait;
    end process;

    -- send stimuli
    stimulus:
    process
    begin
        rxd <= '1';
        wait for reset_time;

        -- send 20 bytes
        for j in 0 to n_of_tests loop
            rxd <= '0'; -- start bit
            wait for bit_time;

            for i in 0 to DATA_WIDTH-1 loop
                rxd <= data(i); -- data bits
                wait for bit_time;
            end loop;

            if PARITY /= "NONE" then
                -- checksum
                if PARITY = "ODD" then
                    rxd <= (xor data) xor '1';
                else
                    rxd <= (xor data) xor '0';
                end if;
                wait for bit_time;
            end if;

            -- increment data
            data <= data + 1;

            rxd <= '1'; -- stop bit
            wait for 2*bit_time;
        end loop;

        -- complete the simulation
        assert false report "completed test" severity note;

        wait;
    end process;

end rtl;
