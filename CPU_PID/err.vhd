LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- S? d?ng ieee.numeric_std thay v� std_logic_arith v� std_logic_unsigned

entity err is
  port(x_in    :in signed(15 downto 0);
       y_in    :in signed(15 downto 0);
       err_out :out signed(15 downto 0);
       er_go   :out std_logic; 
       strt    :in std_logic;
       clk     :in std_logic );
end err;

ARCHITECTURE structural OF err IS
 -- signal fld_a, fld_b, fld_c : unsigned(3 downto 0);
begin

    process(clk)
    begin
        -- Ki?m tra s? ki?n xung nh?p
        IF(clk'EVENT AND clk = '1') THEN
            -- Ki?m tra t�n hi?u start
            IF (strt = '1') THEN
               err_out <= x_in - y_in;  -- Ph�p tr? gi?a hai t�n hi?u signed
               er_go <= '1' after 5ns, '0' after 11 ns;  -- Tr� ho�n t�n hi?u (ch? d�ng cho m� ph?ng)
            END IF;
        END IF;
    end process;

end structural;
