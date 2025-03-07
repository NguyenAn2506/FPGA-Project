LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- Ch? s? d?ng numeric_std
library lpm;
use lpm.lpm_components.all;

entity plant is
  port(
    x_in     : in signed(15 downto 0);
    u_in     : in signed(15 downto 0);
    go       : in std_logic;
    clk      : in std_logic; 
    clk_op   : in std_logic; 
    err      : buffer signed(15 downto 0);
    yn       : buffer signed(15 downto 0);  
    pl_go    : out std_logic
  );
end plant;

ARCHITECTURE structural OF plant IS
  signal u_ant              : signed(15 downto 0);  
  signal mula1, mulb1      : signed(15 downto 0);  
  signal mulr1             : signed(31 downto 0);  
  signal adda1, addb1      : signed(15 downto 0);  
  signal addr1             : signed(15 downto 0);  
  constant fi               : signed(15 downto 0) := "0110011001100110"; 
  constant teta             : signed(15 downto 0) := "0100000000000000";
  signal cnt                : unsigned(11 downto 0);  
  signal aux                : signed(15 downto 0);

  -- Tín hi?u trung gian ?? l?u giá tr? chuy?n ??i
  signal mulr1_vector       : std_logic_vector(31 downto 0);
  signal addr1_vector       : std_logic_vector(15 downto 0);
  
begin
  mull: lpm_mult
    generic map(
      LPM_WIDTHA => 16,
      LPM_WIDTHB => 16,
      LPM_WIDTHS => 16,
      LPM_WIDTHP => 32,
      LPM_REPRESENTATION => "signed",
      LPM_PIPELINE => 1
    )
    port map(
      dataa => std_logic_vector(mula1),          -- Chuy?n ??i sang std_logic_vector
      datab => std_logic_vector(mulb1),          -- Chuy?n ??i sang std_logic_vector
      clock => clk,
      result => mulr1_vector                       -- Gán tín hi?u trung gian
    );

  adder1: lpm_add_sub
    generic map(
      lpm_width => 16,
      LPM_REPRESENTATION => "signed",
      lpm_pipeline => 1
    )
    port map(
      dataa => std_logic_vector(adda1),           -- Chuy?n ??i sang std_logic_vector
      datab => std_logic_vector(addb1),           -- Chuy?n ??i sang std_logic_vector
      clock => clk,
      result => addr1_vector                       -- Gán tín hi?u trung gian
    );

  GEN: block
  begin
    process (clk_op, go)
    begin
      if (clk_op'event and clk_op = '1') then 
        if go = '0' then 
          cnt <= cnt + 1;
        else 
          cnt <= (others => '0');  -- Reset cnt
        end if;

        case cnt is
          when "000000000000" =>  -- cnt = 0
            mula1 <= u_ant;
            mulb1 <= teta;
          when "000000000001" =>  -- cnt = 1
            adda1 <= mulr1(30 downto 15);
          when "000000000010" =>  -- cnt = 2
            mula1 <= yn;
            mulb1 <= fi;
          when "000000000011" =>  -- cnt = 3
            addb1 <= mulr1(30 downto 15);
          when "000000000100" =>  -- cnt = 4
            aux <= addr1;
            u_ant <= u_in;
          when "000000000101" =>  -- cnt = 5
            adda1 <= x_in;
            addb1 <= -aux;  
          when "000000000110" =>  -- cnt = 6
            err <= addr1;                             -- Chuy?n ??i addr1_vector sang signed n?u c?n
            yn <= aux;
            pl_go <= '1'; 
          when "000000000111" =>  -- cnt = 7
            pl_go <= '0';
            if go = '0' then 
              cnt <= "000000001000";  -- chuy?n sang cnt = 8
            else 
              cnt <= (others => '0');  -- reset cnt
            end if;
          when others => null;  -- Không làm gì v?i các giá tr? khác
        end case;
      end if;
    end process;
  end block GEN;
end structural;

