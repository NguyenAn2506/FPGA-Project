LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY lpm;
USE lpm.LPM_COMPONENTS.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY sin_cos IS
PORT (
	CLK,CLK80n				: IN STD_LOGIC:='0';
	CMD_ID,CMD_IQ, ADDRESS				: IN STD_LOGIC_VECTOR(11 downto 0):=(others =>'0');
	Vref1,Vref2,Vref3				: OUT STD_LOGIC_VECTOR(11 downto 0):=(others =>'0')
	
 	);
END sin_cos;

ARCHITECTURE sin_cos_arch OF sin_cos IS
	signal sin_addr, cos_addr 					: STD_LOGIC_vector(11 downto 0):=(others =>'0');
	signal sin_teta, cos_teta  					: STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
    	signal PO_SIN,PO_COS,NT_SIN					: STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
	signal CNT					: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others =>'0');
	signal Adda, Addb, Addr, Mula, Mulb					: STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
	signal Mulr					: STD_LOGIC_vector(23 downto 0):=(others =>'0');
	signal CMD_Vbeta, CMD_Vbetaa, CMD_Valpha: STD_LOGIC_vector(11 downto 0):=(others =>'0');
	signal Vrefx, Vrefy, Vrefz					: STD_LOGIC_vector(11 downto 0):=(others =>'0');
	
BEGIN
 u1 : lpm_rom 
     GENERIC MAP(lpm_width => 12, lpm_widthad => 12, lpm_file => "sin_625.mif",
                 lpm_address_control => "REGISTERED", lpm_outdata => "UNREGISTERED")
     PORT MAP(ADDRESS => sin_addr, inclock => clk, q => sin_teta);
 u2 : lpm_rom 
     GENERIC MAP(lpm_width => 12, lpm_widthad => 12, lpm_file => "cos_625.mif",
                 lpm_address_control => "REGISTERED", lpm_outdata => "UNREGISTERED")
     PORT MAP(ADDRESS => cos_addr, inclock => clk, q => cos_teta);

mull: lpm_mult
generic map(LPM_WIDTHA=>12,LPM_WIDTHB=>12,LPM_WIDTHS=>12,LPM_WIDTHP=>24,LPM_REPRESENTATION=>"SIGNED",LPM_PIPELINE=>1)
port map(dataa=> mula,datab=> mulb,clock=> clk,result=> mulr);
adder1: lpm_add_sub
generic map(lpm_width=>12,LPM_REPRESENTATION=>"SIGNED",lpm_pipeline=>1)
port map(dataa=>adda,datab=>addb,clock=> clk,result=>addr);


-- Enter sin_addr and cos_addr and lpm will give the value at sin_teta and cos_teta


GEN : block
begin
process (CLK)
begin
if CLK80n'event and CLK80n='1' then
	CNT<=cnt+1;
	IF CNT = x"00" then
		sin_addr <= ADDRESS;
		cos_addr <= ADDRESS;
	ELSIF CNT=x"02" THEN
	IF sin_teta = x"000" THEN
		NT_SIN <= x"FFF";
		PO_SIN <= x"000";
	ELSE
			NT_SIN <= -sin_teta;
			PO_SIN <= sin_teta;
	END IF;
			PO_COS <= cos_teta;
	ELSIF CNT=x"04" THEN
		MULA <= CMD_ID;
		MULB <= PO_SIN;
	ELSIF CNT=x"06" THEN
		ADDA <= MULR(22 DOWNTO 11); --CMD_ID*POSIN
		MULA <= CMD_IQ;
		MULB <= PO_COS;
	ELSIF CNT=x"08" THEN
		ADDB <= MULR(22 DOWNTO 11); -- CMD_ID*POCOS
		MULA <= CMD_ID;
		MULB <= PO_COS;
	ELSIF CNT=x"0A" THEN
		ADDA <= MULR(22 DOWNTO 11); -- cmd_id*po_cos :B1 TÍNH VALPHA
		MULA <= CMD_IQ;
		MULB <= NT_SIN;
		CMD_Vbeta <= ADDR; -- cmd_id*posin+cmd_iq*po_cos
		Vrefx <= ADDR; -- cmd_Vbeta
		
	ELSIF CNT=x"0C" THEN
		ADDB <= MULR(22 DOWNTO 11); -- cmd_iq*nt_sin
		CMD_Vbetaa <= CMD_Vbeta(11)& CMD_Vbeta(11 downto 1); -- CMD_Vbeta/2 
	ELSIF CNT=x"0E" THEN
		CMD_Valpha <= ADDR; -- cmd_id*po_cos+cmd_iq*nt_sin
		MULA <= ADDR;       -- Cmd_Valpha
		MULB <= x"6ED"; 	-- sqrt(3)/2 (0.866*2048 (2048=2^11: 12 bits))
	ELSIF CNT=x"10" THEN
		ADDA <= -CMD_Vbetaa;
		ADDB <= MULR(22 DOWNTO 11); -- cmd_Valpha*sqrt(3)/2
	ELSIF CNT=x"12" THEN
		Vrefy <= ADDR; -- -CMD_Vbeta/2+cmd_Valpha*sqrt(3)/2
		ADDA <= -CMD_Vbetaa;
		ADDB <= -MULR(22 DOWNTO 11);
	ELSIF CNT=x"14" THEN
		Vrefz <= ADDR;
	ELSIF CNT = x"16" THEN --S23
		Vref1 <= Vrefx;
		Vref2 <= Vrefy;
		Vref3 <= Vrefz;
		CNT <= x"00";
	END IF;
END IF;
     end process;
end block GEN;
END sin_cos_arch;
