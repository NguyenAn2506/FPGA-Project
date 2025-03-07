LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY lpm;
USE lpm.LPM_COMPONENTS.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_signed.all;

ENTITY park IS
PORT (
	CLK,clk80n : IN STD_LOGIC:='0';
	Va,Vb : IN STD_LOGIC_VECTOR(11 downto 0):=(others =>'0');
	ADDRESS : IN STD_LOGIC_VECTOR(11 downto 0):=(others =>'0');
	Vd,Vq : OUT STD_LOGIC_VECTOR(11 downto 0):=(others =>'0'));

END park;
ARCHITECTURE biendoi OF park IS
	signal sin_addr, cos_addr 	: STD_LOGIC_vector(11 downto 0):=(others =>'0');
	signal sin_teta, cos_teta  	: STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
    	signal PO_SIN,PO_COS,NT_SIN: STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
	signal CNT	: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others =>'0');
	signal Adda, Addb, Addr, Mula, Mulb :STD_LOGIC_VECTOR (11 downto 0):=(others =>'0');
	signal Mulr	: STD_LOGIC_vector(23 downto 0):=(others =>'0');
	signal Vd1,Vq1: STD_LOGIC_vector(11 downto 0):=(others =>'0');
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
GEN: block
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
	ELSIF CNT =X"04" THEN
		mula<= Va;
		mulb<= PO_COS;
	ELSIF CNT =X"06" THEN
		adda<= mulr(22 downto 11);
		mula<= VB;
		mulb<= PO_SIN;
	ELSIF CNT =X"08" THEN
		addb<=mulr(22 downto 11);
	ELSIF CNT =X"0A" THEN
		Vd1<=addr;
		mula<=Va;
		mulb<= NT_SIN;
	ELSIF CNT =X"0C" THEN
		adda<= mulr(22 downto 11);
		mula<= VB;
		mulb<= PO_COS;
	ELSIF CNT =X"0E" THEN
		addb<=mulr(22 downto 11);
	ELSIF CNT =X"10" THEN
		Vq1<=addr;
	ELSIF CNT = x"12" THEN --S23
		Vq<=Vq1;
		Vd<=VD1;
		CNT<=X"00";
END IF;
END IF;
     end process;
end block GEN;
END ARCHITECTURE;

