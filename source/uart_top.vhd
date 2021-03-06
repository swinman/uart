
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    PORT (
        CLOCK_i         : in  std_logic;
        RESET_ni        : in  std_logic;

        RS232_RXD_i     : in  std_logic;
        RS232_TXD_o     : out std_logic;

        RS232_DTR_i     : in  std_logic;
        RS232_RTS_i     : in  std_logic;
        RS232_DCD_o     : out std_logic;
        RS232_DSR_o     : out std_logic;
        RS232_CTS_o     : out std_logic;

        LED_CNTR        : OUT std_logic;
        LED_LEFT        : OUT std_logic;
        LED_BOT         : OUT std_logic;
        LED_RITE        : OUT std_logic;
        LED_TOP         : OUT std_logic
    );
end uart_top;

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


architecture RTL of uart_top is

    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------

    component LOOPBACK is
        generic (
                --BAUD_RATE           : positive := 115200;
                BAUD_RATE           : positive := 57600;
                -- Input Clock frequency in Hz
                CLOCK_FREQUENCY     : positive := 12000000
            );
        port (
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

    signal count_pr, count_nx : UNSIGNED (31 DOWNTO 0);
    signal led_pr, led_nx : std_logic;

    constant USE_PLL    : natural := 1;
    constant CK_FREQ    : natural := 48000000;

begin

    no_pll_gen:     -- without the PLL
    if USE_PLL /= 1 generate
        clock <= CLOCK_i;
    end generate;

    use_pll_gen:    -- with the PLL
    if USE_PLL = 1 generate
        pll_inst : pll_12x48
        port map (
                i_clk => CLOCK_i,
                o_clk => clock );
    end generate;

    ----------------------------------------------------------------------------
    -- Loopback instantiation
    ----------------------------------------------------------------------------

    LOOPBACK_inst1 : LOOPBACK
    generic map ( BAUD_RATE           => 57600,
                  CLOCK_FREQUENCY     => CK_FREQ )
    port map    (
            -- General
            CLOCK       => clock,
            RESET       => not reset,
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
            reset_sync      <= RESET_ni OR '1';
            reset           <= reset_sync;
            RS232_TXD_o     <= tx;
        end if;
    end process;

    RS232_DCD_o <= '0';
    RS232_DSR_o <= '1';
    RS232_CTS_o <= '1';

    counter_process:
    process( reset, clock )
    begin
        if( reset = '0' ) then
            count_pr <= (OTHERS => '0');
            led_pr <= '0';
        elsif( clock'EVENT and clock = '1' ) then
            count_pr <= count_nx;
            led_pr <= led_nx;
        end if;
    end process;

    led_nx <= not led_pr when count_pr = ( count_pr'range => '0' ) else
              led_pr;

    count_nx <= (OTHERS => '0') when
                count_pr = to_unsigned(CK_FREQ, count_pr'length) else
                count_pr + 1;

    LED_BOT <= not tx;
    LED_TOP <= not rx_sync;

    LED_RITE <= led_pr;
    LED_LEFT <= '0' when count_nx < to_unsigned(CK_FREQ/4, count_nx'length) else
                '1';
    LED_CNTR <= LED_RITE XOR LED_LEFT;


end RTL;
