
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
    PORT (
        CLOCK_i         : in  std_logic;
        RESET_i         : in  std_logic;

        RS232_RXD_i     : in  std_logic;
        RS232_TXD_o     : out std_logic;

        RS232_DTR_i     : in  std_logic;
        RS232_RTS_i     : in  std_logic;
        RS232_DCD_o     : out std_logic;
        RS232_DSR_o     : out std_logic;
        RS232_CTS_o     : out std_logic;

        LED0            : OUT std_logic
    );
end TOP;

-- ABBR  Name, Typical purpose
-- DTR : Data Terminal Ready, Indicates presence of DTE to DCE
-- DCD : Data Carrier Detect, DCE is connected to the telephone line
-- DSR : Data Set Ready, DCE is ready to receive commands or data
-- RI  : Ring Indicator, DCE has detected an incoming ring on the telephone line
-- RTS : Request To Send, DTE requests the DCE prepare to receive data
-- CTS : Clear To Send, Indicates DCE is ready to accept data
-- TxD : Transmitted Data, Carries data from DTE to DCE
-- RxD : Received Data, Carries data from DCE to DTE
-- GND : Common Ground
-- PG  : Protective Ground


architecture RTL of TOP is

    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------

    component LOOPBACK is
        port
        (
            -- General
            CLOCK                   :   in      std_logic;
            RESET                   :   in      std_logic;
            RX                      :   in      std_logic;
            TX                      :   out     std_logic
        );
    end component LOOPBACK;

    component pll_12x48 IS
        port ( i_clk : in std_logic;
                o_clk : out std_logic );
    end component pll_12x48;

    ----------------------------------------------------------------------------
    -- Signals
    ----------------------------------------------------------------------------

    signal clock, tx, rx, rx_sync, reset, reset_sync : std_logic;
    signal count : UNSIGNED (15 DOWNTO 0);

    signal led_pr, led_nx : std_logic;

begin


    pll_inst : pll_12x48
    port map (
            i_clk => CLOCK_i,
            o_clk => clock );

    ----------------------------------------------------------------------------
    -- Loopback instantiation
    ----------------------------------------------------------------------------

    LOOPBACK_inst1 : LOOPBACK
    port map    (
            -- General
            CLOCK       => clock,
            RESET       => reset,
            RX          => rx,
            TX          => tx );

    ----------------------------------------------------------------------------
    -- Deglitch inputs
    ----------------------------------------------------------------------------

    DEGLITCH : process (clock)
    begin
        if rising_edge(clock) then
            rx_sync         <= RS232_RXD_i;
            rx              <= rx_sync;
            reset_sync      <= RESET_i;
            reset           <= reset_sync;
            RS232_TXD_o     <= tx;
        end if;
    end process;

    RS232_DCD_o <= '0';
    RS232_DSR_o <= '1';
    RS232_CTS_o <= '1';

    counter_process:
    process( RESET_i, clock )
    begin
        if( RESET_i = '0' ) then
            count <= (OTHERS => '0');
            led_pr <= '0';
        elsif( clock'EVENT and clock = '1' ) then
            count <= count + 1;
            led_pr <= led_nx;
        end if;
    end process;

    led_flash_process:
    process( count )
    begin
        if( count = (count'range => '0') ) then
            led_nx <= NOT led_pr;
        ELSE
            led_nx <= led_pr;
        end if;
    end process;

    LED0 <= led_pr;

end RTL;
