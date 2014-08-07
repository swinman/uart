-------------------------------------------------------------------------------
-------- pll_12x48 : ----------------------------------------------------------
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------------------------------------------------------
ENTITY pll_12x48 IS
  PORT( i_clk   : IN STD_LOGIC;
        o_clk   : OUT STD_LOGIC );
END ENTITY;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
ARCHITECTURE pll_ver_altera OF pll_12x48 IS

  COMPONENT pll_altera_12x48
    PORT (  inclk0  : IN STD_LOGIC;
            c0	    : OUT STD_LOGIC;
            locked  : OUT STD_LOGIC );
  END COMPONENT;

  SIGNAL pll_lock   : STD_LOGIC;
  SIGNAL pll_out    : STD_LOGIC;

BEGIN

  pll_altera_inst : pll_altera_12x48
      PORT MAP (
        inclk0	    => i_clk,
        c0	    => pll_out,
        locked	    => pll_lock );

  o_clk <= i_clk WHEN pll_lock = '0' ELSE pll_out;


END ARCHITECTURE pll_ver_altera;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
ARCHITECTURE pll_ver_lattcie OF pll_12x48 IS

  COMPONENT SB_PLL40_CORE IS
    GENERIC ( DIVR      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              DIVF      : STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
              DIVQ      : STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
              FILTER_RANGE  : STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
              FEEDBACK_PATH     : STRING;
              DELAY_ADJUSTMENT_MODE_FEEDBACK : STRING;
              FDA_FEEDBACK      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              DELAY_ADJUSTMENT_MODE_RELATIVE : STRING;
              FDA_RELATIVE      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              SHIFTREG_DIV_MODE : STD_LOGIC_VECTOR ( 1 DOWNTO 0 );
              PLLOUT_SELECT     : STRING;
              ENABLE_ICEGATE    : STD_LOGIC );
    PORT ( REFERENCECLK     : IN    STD_LOGIC;
           PLLOUTCORE       :   OUT STD_LOGIC;
           PLLOUTGLOBAL     :   OUT STD_LOGIC;
           EXTFEEDBACK      : INOUT STD_LOGIC;
           DYNAMICDELAY     : INOUT STD_LOGIC;
           BYPASS           : IN    STD_LOGIC;
           LATCHINPUTVALUE  : INOUT STD_LOGIC;
           LOCK             :   OUT STD_LOGIC;
           --SDI              : INOUT STD_LOGIC;
           --SDO              : INOUT STD_LOGIC;
           --SCLK             : INOUT STD_LOGIC;
           RESETB           : IN    STD_LOGIC );
  END COMPONENT;

  COMPONENT SB_PLL40_PAD IS
    GENERIC ( DIVR      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              DIVF      : STD_LOGIC_VECTOR ( 7 DOWNTO 0 );
              DIVQ      : STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
              FILTER_RANGE  : STD_LOGIC_VECTOR ( 2 DOWNTO 0 );
              FEEDBACK_PATH     : STRING;
              DELAY_ADJUSTMENT_MODE_FEEDBACK : STRING;
              FDA_FEEDBACK      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              DELAY_ADJUSTMENT_MODE_RELATIVE        : STRING;
              FDA_RELATIVE      : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
              SHIFTREG_DIV_MODE : STD_LOGIC_VECTOR ( 1 DOWNTO 0 );
              PLLOUT_SELECT     : STRING;
              ENABLE_ICEGATE    : STD_LOGIC );
    PORT ( PACKAGEPIN       : IN    STD_LOGIC;
           PLLOUTCORE       :   OUT STD_LOGIC;
           PLLOUTGLOBAL     :   OUT STD_LOGIC;
           EXTFEEDBACK      : INOUT STD_LOGIC;
           DYNAMICDELAY     : INOUT STD_LOGIC;
           BYPASS           : IN    STD_LOGIC;
           LATCHINPUTVALUE  : INOUT STD_LOGIC;
           LOCK             :   OUT STD_LOGIC;
           --SDI              : INOUT STD_LOGIC;
           --SDO              : INOUT STD_LOGIC;
           --SCLK             : INOUT STD_LOGIC;
           RESETB           : IN    STD_LOGIC );
  END COMPONENT;

  COMPONENT SB_GB
    PORT (  USER_SIGNAL_TO_GLOBAL_BUFFER  : IN  STD_LOGIC;
            GLOBAL_BUFFER_OUTPUT          : OUT STD_LOGIC );
  END COMPONENT;

  -- signals from pll
  SIGNAL pll_glob_out   : STD_LOGIC;
  SIGNAL pll_bypass     : STD_LOGIC;
  SIGNAL pll_lock       : STD_LOGIC;

BEGIN

  pll_bypass <= NOT pll_lock;

  pll_lattice_inst : SB_PLL40_CORE
  --pll_lattice_inst : SB_PLL40_PAD
    GENERIC MAP (
      DIVR          => "0000",
      DIVF          => "01111111",
      DIVQ          => "100",
      FILTER_RANGE  => "001",
      FEEDBACK_PATH => "SIMPLE",
      DELAY_ADJUSTMENT_MODE_FEEDBACK => "FIXED",
      FDA_FEEDBACK => "0000",
      DELAY_ADJUSTMENT_MODE_RELATIVE => "FIXED",
      FDA_RELATIVE => "0000",
      SHIFTREG_DIV_MODE => "00",
      PLLOUT_SELECT => "GENCLK",
      ENABLE_ICEGATE => '0' )
    PORT MAP ( PLLOUTGLOBAL     => pll_glob_out,
               REFERENCECLK     => i_clk,
               --PACKAGEPIN       => i_clk,
               LOCK             => pll_lock,
               BYPASS           => pll_bypass,
               RESETB           => '1' );

  lattice_glob_buf_inst : SB_GB
    PORT MAP (  USER_SIGNAL_TO_GLOBAL_BUFFER    => pll_glob_out,
                GLOBAL_BUFFER_OUTPUT            => o_clk );

END ARCHITECTURE pll_ver_lattcie;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- set the desired configuration    ( done at top_level )
--CONFIGURATION pll_config OF pll_12x48 IS
--  FOR pll_ver_lattcie
--  END FOR;
--END CONFIGURATION pll_config;

-- vim: shiftwidth=2
