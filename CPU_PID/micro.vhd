LIBRARY work;
USE work.all;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- Ch? s? d?ng th? vi?n numeric_std

entity micro is
  port(
    start         : in std_logic;
    mic_in, kd, ki, kp : in signed(15 downto 0);
    z_out         : out signed(15 downto 0);
    done          : out std_logic;
    clk           : in std_logic
  );
end micro;

ARCHITECTURE structural OF micro IS
  component microdata IS
    PORT(
      mic_in, kd, ki, kp          : IN SIGNED(15 DOWNTO 0);
      fld_a, fld_b, fld_c        : IN UNSIGNED(3 DOWNTO 0);
      alu_op                     : IN UNSIGNED(1 DOWNTO 0);
      ldr_in, ldkd, ldki, ldkp, ldr_out: IN STD_LOGIC;
      selr_in                    : in unsigned(2 downto 0); 
      ldrf                       : IN STD_LOGIC;
      zero, neg, cy              : OUT STD_LOGIC;
      z_out                      : OUT SIGNED(15 DOWNTO 0);
      clk                        : IN STD_LOGIC;
      control_con                : in STD_LOGIC
    );
  END component;

  component microctrl IS
    PORT(
      start, zero, neg, cy    : IN STD_LOGIC;
      fld_a, fld_b, fld_c      : OUT UNSIGNED(3 DOWNTO 0);
      alu_op                   : OUT UNSIGNED(1 DOWNTO 0);
      ldr_in, ldkd, ldki, ldkp, ldr_out : OUT STD_LOGIC;
      selr_in                  : out unsigned(2 downto 0);  
      ldrf, done              : OUT STD_LOGIC;
      clk                      : IN STD_LOGIC;
      control_con              : out STD_LOGIC
    );
  END component;

---------------------------------------------------------------------------------------------------
-- system parameter --
  signal fld_a, fld_b, fld_c     : unsigned(3 downto 0);
  signal alu_op                  : unsigned(1 downto 0);
  signal zero, neg, cy           : std_logic; 
  signal ldr_in, ldkd, ldki, ldkp, ldr_out : std_logic;
  signal selr_in                 : unsigned(2 downto 0); 
  signal ldrf                    : std_logic;
  signal control_con             : std_logic;
---------------------------------------------------------------------------------------------------
-- Main Program
---------------------------------------------------------------------------------------------------
begin
    u1: microdata
      port map(
        mic_in, kd, ki, kp,
        fld_a, fld_b, fld_c, 
        alu_op, ldr_in, ldkd, ldki, ldkp, 
        ldr_out, selr_in, ldrf, zero, neg, cy, 
        z_out, clk, control_con
      );
    
    u2: microctrl
      port map(
        start, zero, neg, cy, 
        fld_a, fld_b, fld_c, 
        alu_op, ldr_in, ldkd, ldki, ldkp, 
        ldr_out, selr_in, ldrf, done, clk, control_con
      );
end structural;
