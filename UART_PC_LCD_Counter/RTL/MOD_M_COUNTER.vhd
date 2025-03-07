library ieee;
use ieee.std_logic_1164.all;

entity MOD_M_COUNTER is
    generic (   N   : INTEGER   := 4;
                M   : INTEGER   := 10);
    PORT(   CKHT    : IN STD_LOGIC;
            RST     : IN STD_LOGIC;
            TICK    : OUT STD_LOGIC);
END MOD_M_COUNTER;

ARCHITECTURE ARCH OF MOD_M_COUNTER is
    SIGNAL R_REG    : UNSIGNED(N-1 downto 0);
    SIGNAL R_NEXT   : UNSIGNED(N-1 downto 0);
    BEGIN 
        PROCESS(CKHT, RST)
        begin
            IF RST = '1' THEN R_REG <= (OTHERS => '0');
            ELSIF FALLING_EDGE(CKHT) THEN 
                R_REG <= R_NEXT;
            END IF;
        END PROCESS;

        R_NEXT  <= (OTHERS => '0') WHEN R_REG = (M-1) ELSE R_REG + 1;
        TICK    <= '1' WHEN R_REG = (M-1) ELSE '0';
END ARCH;

