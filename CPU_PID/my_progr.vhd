LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;  -- Ch? s? d?ng th? vi?n này

entity my_progr is
  port(
    x_in, kd, ki, kp  : in signed(15 downto 0);
    clk               : in std_logic;
    clk_op            : in std_logic;
    yn                : out signed(15 downto 0)
  );
end my_progr;

ARCHITECTURE structural OF my_progr IS
  signal u, y         : signed(15 downto 0);
  signal err          : signed(15 downto 0);
  signal go           : std_logic;
  signal pl_go        : std_logic;

  component micro IS
    PORT(
      start : in std_logic;
      mic_in, kd, ki, kp : in signed(15 downto 0);
      z_out : out signed(15 downto 0);
      done  : out std_logic;
      clk   : in std_logic
    );
  END component;

  component plant is
    port(
      x_in  : in signed(15 downto 0);
      u_in  : in signed(15 downto 0);
      go    : in std_logic;
      clk   : in std_logic; 
      clk_op : in std_logic;
      err   : out signed(15 downto 0);
      yn    : out signed(15 downto 0);
      pl_go : out std_logic
    );
  end component;

begin
  a1: micro
    port map(
      pl_go, err, kd, ki, kp, u, go, clk_op
    );

  a2: plant
    port map(
      x_in, u, go, clk, clk_op, err, yn, pl_go
    );
end structural;

