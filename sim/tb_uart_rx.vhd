-- author: Furkan Cayci, 2018
-- description: uart rx testbench

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_rx is
end tb_uart_rx;

architecture rtl of tb_uart_rx is
    component uart_rx is
    generic (
        CLKFREQ    : integer := 125E6;
        BAUDRATE   : integer := 115200;
        DATA_WIDTH : integer := 8;
        PARITY     : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH : integer := 1
    );
    port (
        clk     : in  std_logic;
        -- external interface signals
        rxd     : in  std_logic;
        -- axi stream interface
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tvalid : out std_logic
    );
    end component;

    constant CLKFREQ    : integer := 125E6; -- 125 Mhz clock
    constant BAUDRATE   : integer := 115200;
    constant DATA_WIDTH : integer := 8;
    constant PARITY     : string  := "NONE";
    constant STOP_WIDTH : integer := 1;
    constant M : integer := CLKFREQ / BAUDRATE;

    constant clk_period : time := 8 ns;
    constant bit_time   : time := M * clk_period;
    constant data       : std_logic_vector(DATA_WIDTH-1 downto 0) := x"A5";

    signal clk : std_logic := '0';
    signal rxd : std_logic := '0';
    signal m_axis_tdata  : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal m_axis_tready : std_logic := '0';
    signal m_axis_tvalid : std_logic;

begin

    uut_rx: uart_rx
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map (clk=>clk, rxd=>rxd, m_axis_tready=>m_axis_tready,
                  m_axis_tdata=>m_axis_tdata, m_axis_tvalid=>m_axis_tvalid);

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
        m_axis_tready <= '0';
        rxd <= '1';
        wait for 204 ns;

        rxd <= '0'; -- start bit
        wait for bit_time;

        for i in 0 to DATA_WIDTH-1 loop
            rxd <= data(i); -- data bits
            wait for bit_time;
        end loop;

        if PARITY /= "NONE" then
            rxd <= '0'; -- checksum
            wait for bit_time;
        end if;

        rxd <= '1'; -- stop bit

        wait until m_axis_tvalid = '1';
        m_axis_tready <= '1';

        assert m_axis_tdata = data
            report "data does not match" severity error;

        -- complete the simulation
        assert false report "successfully completed the test" severity note;

        wait;
    end process;
end rtl;