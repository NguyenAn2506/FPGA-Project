LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_signed.all;
USE IEEE.std_logic_signed.all;
USE IEEE.numeric_std.all;
LIBRARY lpm;
USE lpm.LPM_COMPONENTS.ALL;
USE ieee.std_logic_arith.all;

ENTITY CMPR IS
PORT (
    CLK,clk200n            : IN STD_LOGIC:='0';
    Vref1,Vref2,Vref3       : IN STD_LOGIC_VECTOR(11 downto 0):=(others =>'0');
    
    CMPR11,CMPR12,CMPR13    : OUT STD_LOGIC_VECTOR(23 DOWNTO 0):=(OTHERS =>'0')

    );
END entity;

architecture arch of CMPR IS
    signal Vref11,Vref21,Vref31,CMPR1,CMPR2,CMPR3         : STD_LOGIC_VECTOR(23 downto 0):=(others =>'0');
    signal TTA,TTB,TSUM,A,B,SAT,TAM                      : STD_LOGIC_VECTOR(23 downto 0):=(others =>'0');
    SIGNAL Taoni,TBoni,TConi,adda2,addb2,addr2,A2,B2,SAT2,sat3 : STD_LOGIC_VECTOR(23 downto 0):=(others =>'0');
    signal CNT                                            : STD_LOGIC_VECTOR (7 DOWNTO 0):=(others =>'0');
    signal Adda, Addb, Addr, Mula, Mulb                  : STD_LOGIC_VECTOR (23 downto 0):=(others =>'0');
    signal Mulr                                           : STD_LOGIC_VECTOR(47 downto 0):=(others =>'0');
    signal k                                              : STD_LOGIC_VECTOR( 23 DOWNTO 0):=(OTHERS =>'0');
    signal Tx,Ty,Tz,T1,T2,TAA,TBB,TAO,TBO,TCO           : STD_LOGIC_VECTOR( 23 DOWNTO 0):=(OTHERS =>'0');
    signal sect                                           : STD_LOGIC_VECTOR(2 downto 0):=(others =>'0');
    signal a1 : std_logic_vector(23 downto 0)            := X"00955C"; -- SQRT(3)/380;
    signal T : std_logic_vector(23 downto 0)             := X"000347"; -- 0.0001;
    signal PWMEA_1,PWMEA_2,PWMEB_1                       : STD_LOGIC:='0';
    signal PWMEB_2, PWMEC_1,PWMEC_2                     : STD_LOGIC:='0';
    signal CMPAA,CMPBB,CMPCC                             : STD_LOGIC_VECTOR(23 downto 0):=(others =>'0');

begin
    mull: lpm_mult
    generic map(LPM_WIDTHA=>24,LPM_WIDTHB=>24,LPM_WIDTHS=>24,LPM_WIDTHP=>48,LPM_REPRESENTATION=>"SIGNED",LPM_PIPELINE=>1)
    port map(dataa=> mula,datab=> mulb,clock=> CLK,result=> mulr);
    
    adder1: lpm_add_sub
    generic map(lpm_width=>24,LPM_REPRESENTATION=>"SIGNED",lpm_pipeline=>1)
    port map(dataa=>adda,datab=>addb,clock=> CLK,result=>addr);
    
    adder2: lpm_add_sub
    generic map(lpm_width=>24,LPM_REPRESENTATION=>"SIGNED",lpm_pipeline=>1)
    port map(dataa=>adda2,datab=>addb2,clock=> CLK,result=>addr2);

    m0 : lpm_divide----------divide component
    GENERIC MAP (LPM_WIDTHN=>24, LPM_WIDTHD =>24, LPM_PIPELINE=>1,LPM_NREPRESENTATION =>"SIGNED", LPM_DREPRESENTATION =>"SIGNED")
    port map (numer=>A,denom=>B,clock=> CLK,quotient=>sat); 

    m1 : lpm_divide----------divide component
    GENERIC MAP (LPM_WIDTHN=>24, LPM_WIDTHD =>24, LPM_PIPELINE=>1,LPM_NREPRESENTATION =>"SIGNED", LPM_DREPRESENTATION =>"SIGNED")
    port map (numer=>A2,denom=>B2,clock=> CLK,quotient=>sat2,remain=>sat3); 

    GEN : BLOCK
    BEGIN
        PROCESS (CLK,sect)
        BEGIN
            IF CLK200n'EVENT AND CLK200n='1' THEN
                CNT <= CNT + 1;
                IF CNT = x"00" THEN
                    sect <= not( Vref3(11)) & not (Vref2(11))& not(Vref1(11));
                    vref11 <= (OTHERS => '0');
                    vref21 <= (OTHERS => '0');
                    vref31 <= (OTHERS => '0');
                    IF Vref1(11) = '0' THEN
                        vref11 <= X"000" & Vref1;
                    ELSE 
                        vref11 <= X"FFF" & Vref1;
                    END IF;
                    IF Vref2(11) = '0' THEN
                        vref21 <= X"000" & Vref2;
                    ELSE 
                        vref21 <= X"FFF" & Vref2;
                    END IF;
                    IF Vref3(11) = '0' THEN
                        vref31 <= X"000" & Vref3;
                    ELSE 
                        vref31 <= X"FFF" & Vref3;
                    END IF;
                ELSIF CNT = x"02" THEN
                    mula <= a1;
                    mulb <= T;
                ELSIF CNT = x"04" THEN
                    mula <= mulr(46 downto 23);
                    k <= mulr(46 downto 23);
                    mulb <= Vref11;
                ELSIF CNT = x"06" THEN
                    Tx <= mulr(23 downto 0);
                    mula <= k;
                    mulb <= -Vref31;
                ELSIF CNT = x"08" THEN
                    Ty <= mulr(23 downto 0);
                    mula <= k;
                    mulb <= -Vref21;
                ELSIF cnt = x"0A" THEN
                    Tz <= mulr(23 downto 0);
                ELSIF cnt = x"0C" THEN
                    IF sect = "000" OR sect = "111" THEN
                        T1 <= X"000000";
                        T2 <= X"000000";
                    ELSIF sect = "001" THEN
                        T1 <= Tz;
                        T2 <= Ty;
                    ELSIF sect = "010" THEN
                        T1 <= Ty;
                        T2 <= -Tx;
                    ELSIF sect = "011" THEN
                        T1 <= -Tz;
                        T2 <= Tx;
                    ELSIF sect = "100" THEN
                        T1 <= -Tx;
                        T2 <= Tz;
                    ELSIF sect = "101" THEN
                        T1 <= Tx;
                        T2 <= -Ty;
                    ELSIF sect = "110" THEN
                        T1 <= -Ty;
                        T2 <= -Tz;
                    END IF;
                ELSIF cnt = x"0E" THEN
                    mula <= T;
                    mulb <= T1;
                ELSIF cnt = x"10" THEN
                    TTA <= mulr(23 downto 0);
                    mula <= T;
                    mulb <= T2;
                ELSIF cnt = x"12" THEN
                    TTB <= mulr(23 downto 0);
                    Tsum <= T1+T2;
                ELSIF cnt = x"14" THEN
                    IF TSUM < T THEN
                        TAA <= T1;            
                        TBB <= T2;
                    ELSE
                        A <= TTA;   
                        B <= Tsum;
                    END IF;
                ELSIF cnt = x"16" THEN
                    IF TSUM >= T THEN
                        TAA <= SAT(23 DOWNTO 0)+X"00003C";
                        A <= TTB;
                        B <= TSUM;
                    END IF;
                ELSIF cnt = x"18" THEN
                    IF TSUM > T THEN
                        TBB <= SAT(23 DOWNTO 0)+X"00003C";
                    END IF;
                ELSIF cnt = x"1A" THEN
                    adda2 <= T;
                    addb2 <= -(TAA);
                ELSIF cnt = x"1C" THEN
                    adda2 <= addr2;
                    addb2 <= -(TBB);
                ELSIF cnt = x"1E" THEN
                    A2 <= addr2;
                    B2 <= X"000002";
                ELSIF cnt = x"20" THEN
                    IF sat2 > X"000000" THEN
                        Taoni <= SAT2(23 DOWNTO 2)&Sat3(1 downto 0);
                        adda2 <= SAT2(23 DOWNTO 2)& sat3(1 downto 0);
		    ELSE 
                        Taoni <= SAT2(23 DOWNTO 0);
                        adda2 <= SAT2(23 DOWNTO 0) ;
                    END IF;
                    addb2 <= TAA;
                ELSIF cnt = x"22" THEN
                    TBoni <= addr2;
                    adda2 <= Tboni;
                    addb2 <= TBB;
                ELSIF cnt = x"24" THEN
                    TConi <= addr2;
                ELSIF cnt = x"26" THEN
                    TaO <= Taoni;
                    TbO <= TBoni;
                    TcO <= TConi;
                ELSIF cnt = x"28" THEN
                    CASE sect IS
                        WHEN "011" =>
                            CMPR1  <= TAO;
                            CMPR2  <= TBO;
                            CMPR3  <= TCO;                       
                        WHEN "001" =>
                            CMPR1  <= TBO;
                            CMPR2  <= TAO;
                            CMPR3  <= TCO;                            
                        WHEN "101" =>
                            CMPR1  <= TCO;
                            CMPR2  <= TAO;
                            CMPR3  <= TBO;                          
                        WHEN "100" =>
                            CMPR1  <= TCO;
                            CMPR2  <= TBO;
                            CMPR3  <= TAO;                           
                        WHEN "110" =>
                            CMPR1  <= TBO;
                            CMPR2  <= TCO;
                            CMPR3  <= TAO;                             
                        WHEN "010" =>
                            CMPR1  <= TAO;
                            CMPR2  <= TCO;
                            CMPR3  <= TBO;                          
                        WHEN OTHERS =>                      
                            CMPR1  <= CMPR1;
                            CMPR2  <= CMPR2;
                            CMPR3  <= CMPR3;  
                    END CASE;
                    CMPR11 <= CMPR1;
                    CMPR12 <= CMPR2;
                    CMPR13 <= CMPR3;
                    CNT <= x"00";
                END IF;
            END IF;
        END PROCESS;  
    END BLOCK gen;
END architecture;

