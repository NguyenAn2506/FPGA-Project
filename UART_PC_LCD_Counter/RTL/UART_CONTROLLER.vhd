library ieee;
use ieee.std_logic_1164.all;

entity UART_CONTROLLER is
    generic(DBIT    : INTEGER := 8;
            SB_TICK : INTEGER := 16;
            DVSR    : INTEGER := 163; --326 cho 100MHz
            DVSR_BIT: INTEGER := 9;
            FIFO_W  : INTEGER := 2);
    PORT(   CKHT    : IN STD_LOGIC;
            RST     : IN STD_LOGIC;
            UART_RX : IN STD_LOGIC;
            UART_TX : OUT STD_LOGIC;
            FIFO_UART_RX_ENA_RD : IN STD_LOGIC;
            FIFO_UART_RX_DATA_RD: OUT STD_LOGIC_VECTOR(7 downto 0);
            FIFO_UART_RX_EMPTY  : OUT STD_LOGIC;
            FIFO_UART_TX_ENA_WR : IN STD_LOGIC;
            FIFO_UART_TX_DATA_WR: IN STD_LOGIC_VECTOR(7 downto 0);
            FIFO_UART_TX_FULL   : OUT STD_LOGIC);
END UART_CONTROLLER;

architecture Behavioral of UART_CONTROLLER is
    SIGNAL S_TICK           : STD_LOGIC;
    SIGNAL UART_RX_FIFO_IN  : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL UART_RX_DONE_TICK: STD_LOGIC;

    SIGNAL UART_TX_FIFO_OUT : STD_LOGIC_VECTOR(7 downto 0);
    SIGNAL UART_TX_DONE_TICK: STD_LOGIC;

    SIGNAL UART_TX_FIFO_NOT_EMPTY   : STD_LOGIC;
    SIGNAL FIFO_UART_TX_EMPTY   : STD_LOGIC;

    begin
        BAUD_GEN_UNIT: ENTITY WORK.MOD_M_COUNTER(ARCH)
        GENERIC MAP(M   => DVSR,
                    N   => DVSR_BIT)
        PORT MAP(   CKHT    => CKHT,
                    RST     => RST,
                    TICK    => S_TICK);
        
        UART_RX_UNIT: ENTITY WORK.UART_CONTROLLER_RX(ARCH)
        GENERIC MAP(DBIT    => DBIT,
                    SB_TICK => SB_TICK)
        PORT MAP(   CKHT    => CKHT,
                    RST     => RST,
                    S_TICK  => S_TICK,
                    UART_RX_DATA        => UART_RX_FIFO_IN,
                    UART_RX_DONE_TICK   => UART_RX_DONE_TICK);

        FIFO_RX_UNIT: ENTITY WORK.FIFO_RX(ARCH)
        GENERIC MAP(B => DBIT,
                    W => FIFO_W)
        PORT MAP(   CKHT    => CKHT,
                    RST     => RST,
                    DATA_WR => UART_RX_FIFO_IN,
                    WR      => UART_RX_DONE_TICK,
                    RD      => FIFO_UART_RX_ENA_RD,
                    DATA_RD => FIFO_UART_RX_DATA_RD,
                    EMPTY   => FIFO_UART_RX_EMPTY);
        
        UART_TX_UNIT: ENTITY WORK.UART_CONTROLLER_TX(ARCH)
        GENERIC MAP(DBIT    => DBIT,
                    SB_TICK => SB_TICK)
        PORT MAP(   CKHT    => CKHT,
                    RST     => RST,
                    S_TICK  => S_TICK,
                    UART_TX => UART_TX,
                    UART_TX_DATA => UART_TX_FIFO_OUT,
                    UART_TX_DONE_TICK   => UART_TX_DONE_TICK,
                    UART_TX_FIFO_NOT_EMPTY  => UART_TX_FIFO_NOT_EMPTY);

        UART_TX_FIFO_NOT_EMPTY  <= NOT FIFO_UART_TX_EMPTY;
        FIFO_TX_UNIT: ENTITY WORK.FIFO_TX(ARCH)
        GENERIC MAP(B => DBIT,
                    W => FIFO_W)
        PORT MAP(   CKHT    => CKHT,
                    RST     => RST,
                    RD      => UART_TX_DONE_TICK,
                    DATA_RD => UART_TX_FIFO_OUT,
                    EMPTY   => FIFO_UART_TX_EMPTY,
                    WR      => FIFO_UART_TX_ENA_WR,
                    DATA_WR => FIFO_UART_TX_DATA_WR,
                    FULL    => FIFO_UART_TX_FULL);
END Behavioral;

    
        