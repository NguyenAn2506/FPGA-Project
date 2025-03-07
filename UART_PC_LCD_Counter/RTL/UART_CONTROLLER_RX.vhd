library ieee;
use ieee.std_logic_1164.all;

ENTITY UART_CONTROLLER_RX is 
    GENERIC(DBIT    : INTEGER := 8;
            SB_TICK : INTEGER := 16);
    PORT(   CKHT    : IN STD_LOGIC;
            RST     : IN STD_LOGIC;
            UART_RX : IN STD_LOGIC;
            S_TICK  : IN STD_lOGIC;
            UART_RX_DONE_TICK   : OUT STD_LOGIC;
            UART_RX_DATA        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END UART_CONTROLLER_RX;

architecture ARCH OF UART_CONTROLLER_RX is
    TYPE STATE_TYPE IS (IDLE, START, DATA, STOP);
    SIGNAL STATE_REG        : STATE_TYPE;
    SIGNAL STATE_NEXT       ; STATE_TYPE;
    SIGNAL S_REG, S_NEXT    : UNSIGNED (3 DOWNTO 0);
    SIGNAL N_REG, N_NEXT    : UNSIGNED (2 DOWNTO 0);
    SIGNAL B_REG, B_NEXT    : STD_LOGIC_VECTOR (7 DOWNTO 0);
    BEGIN 
        PROCESS(CKHT, RST)
        begin
            IF RST = '1' THEN   STATE_REG   <= IDLE;
                                S_REG       <= (OTHERS => '0');  
                                N_REG       <= (OTHERS => '0');  
                                B_REG       <= (OTHERS => '0');  
            ELSIF FALLING_EDGE(CKHT) THEN   STATE_REG   <= STATE_NEXT;
                                            S_REG       <= S_NEXT;
                                            N_REG       <= N_NEXT;
                                            B_REG       <= B_NEXT;
            END IF;
        END PROCESS;

        PROCESS(STATE_REG, S-REG, N_REG, B_REG, S_TICK, UART_RX)
        begin
            STATE_NEXT  <= STATE_REG;
            S_NEXT      <= S_REG;
            N_NEXT      <= N_REG;
            B_NEXT      <= B_REG;
            UART_RX_DONE_TICK   <= '0';
            case( STATE_REG ) is
                when IDLE =>
                    IF UART_RX = '0' THEN   STATE_NEXT <= START;
                                            S_NEXT  <= (OTHERS => '0');
                    END IF;
                    
                WHEN START => 
                    IF (S_TICK = '1') THEN
                        IF S_REG = 7 THEN   STATE_NEXT  <= DATA;
                                            S_NEXT      <= (OTHERS => '0');
                                            N_NEXT      <= (OTHERS => '0');
                        ELSE    S_NEXT <= S_REG + 1;
                        END IF;
                    END IF;
                
                WHEN STOP =>
                    IF (S_TICK = '1') THEN
                        IF(S_REG = (SB_TICK - 1)) THEN
                            STATE_NEXT  <= IDLE;
                            UART_RX_DONE_TICK   <= '1';
                        ELSE    S_NEXT      <= S_REG +1;
                        END IF;
                    END IF;
            end case ;
        END PROCESS;
        UART_RX_DATA    <= B_REG;
END ARCH;

