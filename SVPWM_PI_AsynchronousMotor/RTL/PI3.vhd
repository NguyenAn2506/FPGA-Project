LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;
LIBRARY lpm;
USE lpm.LPM_COMPONENTS.ALL;
ENTITY PI_speed2 IS
port(
	CLK:IN STD_LOGIC:='0';
	CLK40:IN STD_LOGIC:='0';
	CMD,Kp,Ki:IN STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
	FEED  :IN STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
	DAURA:out  STD_LOGIC_VECTOR(11 downto 0):=(others=>'0')
	);
END PI_speed2;
ARCHITECTURE PI_arch2 OF PI_speed2 IS
SIGNAL  Info_speed	: STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  e1,Un, error, error1, error_gain, error_x_gain		: STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  mula1,mulb1 :  STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  mulr1		: STD_LOGIC_VECTOR(23 downto 0):=(others=>'0');
SIGNAL  adda1,addb1,addr1,addr  : STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  ui			: STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  CNT:       STD_LOGIC_VECTOR(11 downto 0):=(others=>'0');
SIGNAL  overflow, cout : STD_LOGIC;

BEGIN
mull: lpm_mult
generic map(LPM_WIDTHA=>12,LPM_WIDTHB=>12,LPM_WIDTHS=>12,LPM_WIDTHP=>24,
			LPM_REPRESENTATION=>"SIGNED",LPM_PIPELINE=>1)
port map(dataa=> mula1,datab=> mulb1,clock=> clk,result=> mulr1);
adder1: lpm_add_sub
generic map(lpm_width=>12,LPM_REPRESENTATION=>"SIGNED",lpm_pipeline=>1)
port map(dataa=>adda1,datab=>addb1,clock=> clk,result=>addr, overflow => overflow, cout => cout);

error_gain <= X"040"; --64
process (clk,addr)
BEGIN
  if clk'event and clk='1' then
     if overflow='1' then
        if cout='1' then 
           addr1 <= X"800";
        else
           addr1 <= X"7FF";
        end if;
     else 
        addr1 <= addr;
     end if;      
  end if;   
END PROCESS;          

GEN:block
BEGIN
PROCESS(CLK)
BEGIN
IF CLK40'EVENT and CLK40='1' THEN
	CNT<=CNT+1;
	IF CNT=X"000" THEN
			mula1<=  e1;
		mulb1<=  Ki;
	ELSIF CNT=X"002" THEN
		adda1<=  mulr1(22 downto 11);
		addb1<=  ui;
	ELSIF CNT=X"004" THEN
		ui<=  addr1;
		adda1<=  CMD;
		addb1<=  -feed;
	ELSIF CNT=X"006" THEN
		error1<=  addr1;
	elsif cnt=X"008" THEN
		error<=error1;
	ELSIF CNT=X"00A" THEN
	        mula1<=   error_gain;
		mulb1<=   error;  -- error
	ELSIF CNT=X"00C" THEN
	        error_x_gain <= mulr1(23) & mulr1(10 downto 0);		        
	ELSIF CNT=X"00E" THEN
		e1<=   error_x_gain;
		mula1<=   error_x_gain;
		mulb1<=   Kp;
	ELSIF CNT=X"010" THEN
	       	adda1<=   mulr1(22 downto 11);
		addb1<=   ui;
	ELSIF CNT=X"012" THEN
	        daura <= addr1;
		CNT<=   X"000";
		
	END IF;
END IF;
END PROCESS;
END BLOCK GEN;
END PI_arch2;
