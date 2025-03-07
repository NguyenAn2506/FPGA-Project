LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- Thay ??i sang ieee.numeric_std ?? thay th? cho std_logic_arith và std_logic_unsigned
--------------------------------------------------------------
ENTITY microctrl IS
  GENERIC(cssize : NATURAL := 17);
  PORT(
    start, zero, neg, cy        : IN STD_LOGIC;
    fld_a, fld_b, fld_c         : OUT UNSIGNED(3 DOWNTO 0);
    alu_op                      : OUT UNSIGNED(1 DOWNTO 0);
    ldr_in, ldkd, ldki, ldkp, ldr_out : OUT STD_LOGIC;
    selr_in                     : OUT UNSIGNED(2 DOWNTO 0);
    ldrf, done                  : OUT STD_LOGIC;
    clk                         : IN STD_LOGIC;
    control_con                 : OUT STD_LOGIC
  );
END microctrl;
---------------------------------------------------------------
ARCHITECTURE behav_microprogr OF microctrl IS
  SIGNAL csar    : NATURAL;
  SIGNAL uinstr  : UNSIGNED(25 DOWNTO 0);
  ALIAS mode     : STD_LOGIC IS uinstr(25);
  ALIAS condition : UNSIGNED(1 DOWNTO 0) IS uinstr(24 DOWNTO 23);
  ALIAS cond_val  : STD_LOGIC IS uinstr(22);
BEGIN

PROCESS (clk)
  VARIABLE index : UNSIGNED(21 DOWNTO 0);
BEGIN
  IF (clk'EVENT AND clk = '1') THEN
    IF (mode = '0') THEN 
      csar <= csar + 1;
    ELSE
      CASE condition IS
        WHEN "00" => 
          IF (start = cond_val) THEN
            index := uinstr(21 DOWNTO 0);
            csar <= TO_INTEGER(index);  -- S? d?ng TO_INTEGER thay cho CONV_INTEGER
          ELSE 
            csar <= csar + 1;
          END IF;
        WHEN "01" => 
          IF (zero = cond_val) THEN
            index := uinstr(21 DOWNTO 0);
            csar <= TO_INTEGER(index);
          ELSE 
            csar <= csar + 1;
          END IF;
        WHEN "10" => 
          IF (neg = cond_val) THEN
            index := uinstr(21 DOWNTO 0);
            csar <= TO_INTEGER(index);
          ELSE 
            csar <= csar + 1;
          END IF;
        WHEN "11" => 
          IF (cy = cond_val) THEN
            index := uinstr(21 DOWNTO 0);
            csar <= TO_INTEGER(index);
          ELSE 
            csar <= csar + 1;
          END IF;
        WHEN OTHERS => NULL;
      END CASE;
    END IF;
  END IF;
END PROCESS;
--------------------------------------------------------------------
PROCESS(csar)
  TYPE csarray IS ARRAY(0 TO cssize-1) OF UNSIGNED(25 DOWNTO 0);
  VARIABLE cs : csarray
---------------------------------------microprogram
:= (
    0  => "00100000000000010000000001", -- initialize registers in register file with 0
    1  => "10000000000000000000000001", -- waiting loop after start signal
    2  => "00000000000000011111000001", -- mic_in, kd, ki, kp stored in the input registers
    3  => "00000000001011110000000001", -- r7 <- r1   --- e(n-1) in r7
    4  => "00000000000000110000000101", -- r1 <- rin  --- e(n) in r1
    5  => "00000000000001010000010001", -- r2 <- kp   --- kp stored in r2
    6  => "01000010010001010000000001", -- r2 <- r2 * r1 --- kp * e(n) stored in r2
    7  => "00000000000001110000001101", -- r3 <- ki   --- ki stored in r3
    8  => "01001110011001110000000001", -- r3 <- r3 * r7 --- ki * e(n-1) stored in r3
    9  => "00000110110011010000000001", -- r6 <- r6 + r3 --- u(i) = u(i-1) + ki * e(n-1)
   10  => "00100010111010010000000001", -- r4 <- r1 - r7 --- e(n) - e(n-1) stored in r4
   11  => "00000000000010110000001001", -- r5 <- kd    --- kd stored in r5
   12  => "01001010100010110000000001", -- r5 <- r5 * r4 --- kd[e(n) - e(n-1)] in r5
   13  => "00000100110001010000000001", -- r2 <- r2 + r6 --- up + ui stored in r2
   14  => "00000100101001010000000001", -- r2 <- r2 + r5 --- up + ui + ud stored in r2
   15  => "00000100000001010000100010", -- rout <- r2  --- r2 in output register; done signal
   16  => "11100000000000000000000001"  -- jump to second instruction
);
-----------------------------------------------------------------------
BEGIN
  uinstr <= cs(csar);
  control_con <= uinstr(25);
  
  CASE uinstr(25) IS
    WHEN '0' => 
      alu_op <= uinstr(24 DOWNTO 23);
      fld_a  <= uinstr(22 DOWNTO 19);
      fld_b  <= uinstr(18 DOWNTO 15);
      fld_c  <= uinstr(14 DOWNTO 11);
      ldrf   <= uinstr(10); 
      ldr_in <= uinstr(9); 
      ldkd   <= uinstr(8);
      ldki   <= uinstr(7);
      ldkp   <= uinstr(6);
      ldr_out <= uinstr(5);
      selr_in <= uinstr(4 DOWNTO 2);
      
      IF (uinstr(1) = '1') THEN 
        done <= '1', '0' AFTER 20 ns; 
      END IF;
      
      IF (uinstr(0) = '1') THEN 
        done <= '0'; 
      END IF;

    WHEN '1' => 
      ldrf <= '0'; ldr_out <= '0'; ldr_in <= '0'; ldkd <= '0';
      ldki <= '0'; ldkp <= '0';

    WHEN OTHERS => NULL;
  END CASE;
END PROCESS;
END behav_microprogr;

