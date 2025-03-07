LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;  -- Thay ??i sang ieee.numeric_std ?? thay th? cho std_logic_arith và std_logic_unsigned
-------------------------------------------------------------------------

ENTITY microdata IS
PORT(
    mic_in,kd,ki,kp             : IN SIGNED(15 DOWNTO 0);
    fld_a, fld_b, fld_c         : IN UNSIGNED(3 DOWNTO 0);
    alu_op                      : IN UNSIGNED(1 DOWNTO 0);
    ldr_in, ldkd, ldki, ldkp, ldr_out : IN STD_LOGIC;
    selr_in                     : IN UNSIGNED(2 DOWNTO 0);
    ldrf                        : IN STD_LOGIC;
    zero, neg, cy               : OUT STD_LOGIC;
    z_out                       : OUT SIGNED(15 DOWNTO 0);
    clk                         : IN STD_LOGIC;
    control_con                 : IN STD_LOGIC
);
END microdata;
--------------------------------------------------------

ARCHITECTURE behavioral OF microdata IS
    TYPE reg_fileT IS ARRAY(0 TO 8) OF SIGNED(15 DOWNTO 0);
    SIGNAL RF                 : reg_fileT;
    SIGNAL r_in, k_d, k_i, k_p : SIGNED(15 DOWNTO 0);
BEGIN

    PROCESS (clk)
    VARIABLE A, B, C           : SIGNED(15 DOWNTO 0);
    VARIABLE alu_out           : SIGNED(15 DOWNTO 0);
    VARIABLE zzero, nneg, ccy  : STD_LOGIC;
    CONSTANT z : SIGNED(15 DOWNTO 0) := (OTHERS => '0');
    
    ---------------------------------------------------------
    PROCEDURE alu (
        zzero, nneg, ccy        : OUT STD_LOGIC;
        alu_out                 : OUT SIGNED(15 DOWNTO 0);
        a, b                    : IN SIGNED(15 DOWNTO 0);
        alu_op                  : IN UNSIGNED(1 DOWNTO 0)
    ) IS
        VARIABLE alu_out_reg     : SIGNED(16 DOWNTO 0);
        VARIABLE alu_out_or      : SIGNED(31 DOWNTO 0);
    BEGIN
        CASE alu_op IS
            WHEN "00" => -- add
                alu_out_reg := ("0" & a) + ("0" & b); 
                alu_out := alu_out_reg(15 DOWNTO 0);
                ccy := alu_out_reg(16);
                IF alu_out_reg(15 DOWNTO 0) = z THEN
                    zzero := '1';
                ELSE
                    zzero := '0';
                END IF;

            WHEN "01" => -- subtract
                alu_out := a - b;

            WHEN "10" => -- multiply
                alu_out_or := a * b;
                alu_out := alu_out_or(30 DOWNTO 15);

            WHEN "11" => -- increment
                alu_out := a + 1;

            WHEN OTHERS =>
                NULL;
        END CASE;
    END alu;
    ------------------------------------------------------------------

    BEGIN
        -- L?y d? li?u t? các thanh ghi
        A := RF(TO_INTEGER(fld_a));
        B := RF(TO_INTEGER(fld_b));

        -- N?u control_con = '0', th?c hi?n tính toán v?i ALU
        IF control_con = '0' THEN
            alu(zzero, nneg, ccy, alu_out, A, B, alu_op);
            zero <= zzero;
            neg <= nneg;
            cy <= ccy;
        END IF;

        -- Ch?n ??u ra C d?a trên giá tr? selr_in
        CASE selr_in IS
            WHEN "000" => C := alu_out;
            WHEN "001" => C := r_in;
            WHEN "010" => C := k_d;
            WHEN "011" => C := k_i;
            WHEN "100" => C := k_p;
            WHEN OTHERS => NULL;
        END CASE;

        -- X? lý các tín hi?u theo s? ki?n xung nh?p
        IF clk'EVENT AND clk = '1' THEN
            IF ldr_in = '1' THEN
                r_in <= mic_in;
            END IF;

            IF ldkd = '1' THEN
                k_d <= kd;
            END IF;

            IF ldki = '1' THEN
                k_i <= ki;
            END IF;

            IF ldkp = '1' THEN
                k_p <= kp;
            END IF;

            IF ldr_out = '1' THEN
                z_out <= alu_out;
            END IF;

            IF ldrf = '1' THEN
                RF(TO_INTEGER(fld_c)) <= C;
            END IF;
        END IF;
    END PROCESS;
END behavioral;

