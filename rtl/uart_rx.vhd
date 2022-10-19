-- author: Furkan Cayci, 2018
-- description: uart receive interface

library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKFREQ    : integer := 125E6;
        BAUDRATE   : integer := 115200;
        DATA_WIDTH : integer := 8;
        PARITY     : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH : integer := 1
    );
    port (
        clk : in  std_logic;
        -- external interface signals
        rxd : in  std_logic;
        -- axi stream interface
        m_axis_tready : in  std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        m_axis_tvalid : out std_logic
    );
end uart_rx;

architecture rtl of uart_rx is
    signal tvalid : std_logic := '0';
    signal tdata  : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    constant M : integer := CLKFREQ / BAUDRATE; -- clock cycles per bit
begin

    m_axis_tvalid <= tvalid;
    m_axis_tdata <= tdata;

    main: process(clk) is
        type state_type is (st_idle, st_data, st_parity, st_stop);
        variable state : state_type := st_idle;
        variable rxbuf : std_logic_vector(DATA_WIDTH-1 downto 0) := (others=>'0');
        variable bitcount : integer range 0 to DATA_WIDTH-1 := 0;
        variable clkcount : integer range 0 to M-1 := 0;
        variable par : std_logic := '0';
    begin
        if rising_edge(clk) then
            if m_axis_tready = '1' then
                tvalid <= '0';
            end if;

            case state is
                when st_idle =>
                    if rxd = '0' then
                        if clkcount = M/2 - 1 then
                            clkcount := 0;
                            state := st_data;
                        else
                            clkcount := clkcount + 1;
                        end if;
                    else
                        clkcount := 0;
                    end if;

                when st_data =>
                    if clkcount = M-1 then
                        clkcount := 0;
                        rxbuf := rxd & rxbuf(DATA_WIDTH-1 downto 1);
                        par := par xor rxd;
                        if bitcount = DATA_WIDTH-1 then
                            bitcount := 0;
                            if PARITY = "NONE" then
                                state := st_stop;
                            else
                                state := st_parity;
                            end if;
                        else
                            bitcount := bitcount + 1;
                        end if;
                    else
                        clkcount := clkcount + 1;
                    end if;

                when st_parity =>
                    if clkcount = M-1 then
                        clkcount := 0;
                        par := par xor rxd;
                        if PARITY = "ODD" then
                            if par /= '1' then
                                -- raise parity error
                                report "parity error" severity error;
                                report "The value of 'p' is " & std_ulogic'image(par);
                            end if;
                        else
                            if par /= '0' then
                                -- raise parity error
                                report "parity error" severity error;
                                report "The value of 'p' is " & std_ulogic'image(par);
                            end if;
                        end if;
                        state := st_stop;
                        par := '0';
                    else
                        clkcount := clkcount + 1;
                    end if;

                when st_stop =>
                    if clkcount = M-1 then
                        clkcount := 0;
                        state := st_idle;
                        tvalid <= '1';
                        tdata <= rxbuf;
                    else
                        clkcount := clkcount + 1;
                    end if;

            end case;
         end if;
    end process;

end rtl;
