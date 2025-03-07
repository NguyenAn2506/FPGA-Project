LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- S? d?ng ieee.numeric_std thay vì std_logic_arith và std_logic_unsigned

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
            -- Ki?m tra tín hi?u start
            IF (strt = '1') THEN
               err_out <= x_in - y_in;  -- Phép tr? gi?a hai tín hi?u signed
               er_go <= '1' after 5ns, '0' after 11 ns;  -- Trì hoãn tín hi?u (ch? dùng cho mô ph?ng)
            END IF;
        END IF;
    end process;

end structural;
