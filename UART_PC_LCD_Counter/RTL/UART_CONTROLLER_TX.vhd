library ieee;
use ieee.std_logic_1164.all;


entity	UART_CONTROLLER_TX is
	generic(DBIT		: INTEGER := 8;
			SB_TICK 	: INTEGER := 16);
	PORT(	CKHT		: IN STD_LOGIC;
			RST			; IN STD_LOGIC;
			UART_TX_FIFO_NOT_EMPTY	: IN STD_LOGIC;
			S_TICK		: IN STD_LOGIC;
			UART_TX_DATA: 	STD_LOGIC_VECTOR(7 downto 0);
			UART_TX_DONE_TICK: OUT STD_LOGIC;
			UART_TX_DATA: OUT STD_LOGIC);
END UART_CONTROLLER_TX;

architecture ARCH OF UART_CONTROLLER_TX is
	TYPE STATE_TYPE IS (IDLE, START, DATA, STOP);
	SIGNAL STATE_REG, STATE_NEXT	: STATE_TYPE;
	SIGNAL S_REG, S_NEXT			; UNSIGNED (3 downto 0);
	SIGNAL N_REG, N_NEXT			; UNSIGNED (2 downto 0);
	SIGNAL B_REG, B_NEXT			; STD_LOGIC_VECTOR (7 downto 0);
	SIGNAL TX_REG, TX_NEXT			: STD_LOGIC;
	begin
		PROCESS(CKHT, RST)
		BEGIN 
			IF(RST = '1') THEN 	STATE_REG <= IDLE;
								S_REG 	<= (OTHERS => '0');
								N_REG	<= (OTHERS => '0');
								B-REG 	<= (OTHERS => '0');
								TX_REG 	<= '1';
			ELSIF FALLING_EDGE(CKHT) THEN 	STATE_REG 	<= STATE_NEXT;
											S_REG 		<= S_NEXT;
											N_REG 		<= N_NEXT;
											B_REG 		<= B_NEXT;
											TX_REG 		<= TX_NEXT;
			END IF;
		END PROCESS;
		
		PROCESS(STATE_REG, S_REG, N_REG, B_REG, S_TICK, TX_REG, UART_TX_FIFO_NOT_EMPTY, UART_TX_DATA)
		BEGIN
			STATE_NEXT 		<= STATE_REG;
			S_NEXT			<= S_REG;
			N_NEXT 			<= N_REG;
			B_NEXT			<= B_REG;
			TX_NEXT 		<= TX_REG;
			UART_TX_DONE_TICK	<= '0';
			
			CASE STATE_REG IS
				WHEN IDLE => TX_NEXT <= '1';
					IF UART_TX_FIFO_NOT_EMPTY = '1' THEN 	STATE_NEXT <= START;
															S_NEXT	<= (OTHERS => '0');
															B_NEXT	<= UART_TX_DATA;
					END IF;
				
				WHEN START => TX_NEXT <= '0';
					IF (S_TICK = '1') THEN 
						IF S_REG = 15 THEN 	STATE_NEXT <= DATA;
											S_NEXT	<= (OTHERS => '0');
											N_NEXT	<= (OTHERS => '0');
											S_NEXT 	<= S_REG + 1;
						END IF;
					END IF;
				
				WHEN DATA => TX_NEXT <= B_REG(0);
					IF (S_TICK = '1') THEN 
						IF S_REG = 15 THEN	S_NEXT <= (OTHERS => '0');
											B_NEXT <= '0' & B_REG(7 downto 1);
							IF N_REG = (DBIT - 1) THEN 	STATE_NEXT <= STOP;
							ELSE N_NEXT <= 	N_NEXT 	<= N_REG + 1;
							END IF;
						ELSE S_NEXT <= S_REG + 1;
						END IF;
					END IF;
					
				WHEN STOP => TX_NEXT <= '1';
					IF (S_TICK = '1') THEN 
						IF S_REG = (SB_TICK - 1) THEN 	STATE_NEXT <= IDLE;
														UART_TX_DONE_TICK <= '1';
						ELSE S_NEXT <= S_REG + 1;
						END IF;
					END IF;
			END CASE;
		END PROCESS;
		UART_TX <= TX_REG;
END ARCH;