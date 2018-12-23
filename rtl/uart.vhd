-- author: Furkan Cayci, 2018
-- description: uart top module with axi stream interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
        CLKFREQ    : integer := 125E6; -- 125 Mhz clock
        BAUDRATE   : integer := 115200;
        DATA_WIDTH : integer := 8;
        PARITY     : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH : integer := 1
    );
    port (
        clk     : in  std_logic;
        -- external interface signals
        rxd     : in  std_logic;
        txd     : out std_logic;
        -- internal interface signals
        -- master axi stream interface
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tvalid : out std_logic;
        -- slave axi stream interface
        s_axis_tvalid : in  std_logic;
        s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axis_tready : out std_logic
    );
end uart;

architecture rtl of uart is
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

    component uart_tx is
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
        txd     : out std_logic;
        -- axi stream interface
        s_axis_tvalid : in  std_logic;
        s_axis_tdata  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axis_tready : out std_logic
    );
    end component;

begin

    urx : uart_rx
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map (clk=>clk, rxd=>rxd, m_axis_tready=>m_axis_tready,
                  m_axis_tdata=>m_axis_tdata, m_axis_tvalid=>m_axis_tvalid);

    utx : uart_tx
        generic map (CLKFREQ=>CLKFREQ, BAUDRATE=>BAUDRATE,
                     DATA_WIDTH=>DATA_WIDTH, PARITY=>PARITY, STOP_WIDTH=>STOP_WIDTH)
        port map (clk=>clk, txd=>txd, s_axis_tvalid=>s_axis_tvalid,
                  s_axis_tdata=>s_axis_tdata, s_axis_tready=>s_axis_tready);

end rtl;