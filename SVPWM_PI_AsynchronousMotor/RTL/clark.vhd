LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
LIBRARY lpm;
USE lpm.LPM_COMPONENTS.ALL;

ENTITY CLARK is
port (
CLK,clk80n : IN STD_LOGIC:='0';
V1,V2,V3: IN STD_LOGIC_VECTOR(11 DOWNTO 0):=(OTHERs =>'0');
Va,Vb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0):=(OTHERs =>'0'));
end entity;
architecture a of CLARK is 
signal A1 : std_logic_vector(11 downto 0) :=X"555";--2/3*2048
signal A2 : std_logic_vector(11 downto 0) :=X"2AB";--  2/3*1/2*2048
signal A3 : std_logic_vector(11 downto 0) :=X"49E"; --SQRT(3)/2*2/3*2048


signal Adda, Addb, Addr, Mula, Mulb,Va1,Vb1 :STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
signal mulr :std_logic_vector( 23 downto 0):=(others =>'0');
signal CNT	: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others =>'0');
BEGIN
mull: lpm_mult
generic map(LPM_WIDTHA=>12,LPM_WIDTHB=>12,LPM_WIDTHS=>12,LPM_WIDTHP=>24,LPM_REPRESENTATION=>"SIGNED",LPM_PIPELINE=>1)
port map(dataa=> mula,datab=> mulb,clock=> clk,result=> mulr);
adder1: lpm_add_sub
generic map(lpm_width=>12,LPM_REPRESENTATION=>"SIGNED",lpm_pipeline=>1)
port map(dataa=>adda,datab=>addb,clock=> clk,result=>addr);

GEN: block
begin
process (CLK)
begin
if clk80n'event and clk80n ='1' then
	cnt <= cnt+1;
   	if cnt<=x"00" then
		adda<= V3;
		addb<= V2;
	elsif cnt<= x"02" then
		mula<= addr;
		mulb<= -A2;
	elsif cnt<= x"04" then
		adda<= mulr(22 downto 11);
		mula<= V1;
		mulb <= A1;
	elsif cnt<= x"06" then
		addb<=mulr(22 downto 11);
	elsif cnt<= x"08" then
		Va1<=addr;
		mula<= V2;
		MULB<= A3;
	elsif cnt<= x"0A" then
		adda<=mulr(22 downto 11);
		mula<= V3;
		mulb<=-a3;
	elsif cnt<= x"0C" then
		addb<=mulr(22 downto 11);
	elsif cnt<= x"0E" then
		Vb1<=addr;
	
	ELSIF CNT = x"10" THEN --S23
		Va<=Va1;
		Vb<=Vb1;
		CNT<=X"00";
	END IF;
END IF;
     end process;
end block GEN;
END ARCHITECTURE;

