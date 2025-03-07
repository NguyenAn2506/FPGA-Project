library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_complex.all;
library work;
use work.fft_len.all;
use work.icpx.all;
use work.fft_support_pkg.all;

entity fft_engine_wrapper is
  --generic (
  --  LOG2_FFT_LEN : integer := 4);       -- Defines order of FFT
  port (
    -- System interface
    rst_n     : in  std_logic;
    clk       : in  std_logic;
    -- Input memory interface
    din_re    : in  signed(15 downto 0);  -- data input
    din_im    : in  signed(15 downto 0);  -- data input
    valid     : inout std_logic;
    saddr     : inout unsigned(2 downto 0);
    saddr_rev : inout unsigned(2 downto 0);
    sout0_re  : inout signed(15 downto 0);  -- spectrum output
    sout0_im  : inout signed(15 downto 0);  -- spectrum output
    sout1_re  : inout signed(15 downto 0);  -- spectrum output
    sout1_im  : inout signed(15 downto 0)   -- spectrum output
    );

end fft_engine_wrapper;

architecture structure of fft_engine_wrapper is
  constant LOG2_FFT_LEN : integer := 4;
  component fft_engine is
    generic (
      LOG2_FFT_LEN : integer);
    port (
      rst_n     : in  std_logic;
      clk       : in  std_logic;
      din       : in  icpx_number;
      valid     : out std_logic;
      saddr     : out unsigned(LOG2_FFT_LEN-2 downto 0);
      saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);
      sout0     : out icpx_number;
      sout1     : out icpx_number);
  end component fft_engine;

  component I1025_EW is
    port (
      DOUT  : out std_logic;
      PADIO : in  std_logic;
      R_EN  : in  std_logic);
  end component I1025_EW;

  component I1025_NS is
    port (
      DOUT  : out std_logic;
      PADIO : in  std_logic;
      R_EN  : in  std_logic);
  end component I1025_NS;

  component D8I1025_EW is
    port (
      DIN   : in  std_logic;
      PADIO : inout std_logic;
      EN    : in  std_logic);
  end component D8I1025_EW;

  component D8I1025_NS is
    port (
      DIN   : in  std_logic;
      PADIO : inout std_logic;
      EN    : in  std_logic);
  end component D8I1025_NS;

  signal din   : icpx_number;
  signal sout0 : icpx_number;
  signal sout1 : icpx_number;

  signal rst_n_from_pad   : std_logic := '0';
  signal clk_from_pad     : std_logic;
  signal din_re_from_pad  : signed(15 downto 0);
  signal din_im_from_pad  : signed(15 downto 0);
  signal valid_to_pad     : std_logic;
  signal saddr_to_pad     : unsigned(2 downto 0);
  signal saddr_rev_to_pad : unsigned(2 downto 0);
  signal sout0_re_to_pad  : signed(15 downto 0);
  signal sout0_im_to_pad  : signed(15 downto 0);
  signal sout1_im_to_pad  : signed(15 downto 0);
  signal sout1_re_to_pad  : signed(15 downto 0);
  
begin  -- architecture structure
  rst_n_io : I1025_NS
    port map (
      DOUT  => rst_n_from_pad,
      PADIO => rst_n,
      R_EN  => '1');

  clk_io : I1025_NS
    port map (
      DOUT  => clk_from_pad,
      PADIO => clk,
      R_EN  => '1');

  valid_io : D8I1025_NS
    port map (
      DIN   => valid_to_pad,
      PADIO => valid,
      EN    => '1');

  io2_gen : for i in 0 to 2 generate
    saddr_io : D8I1025_NS
      port map (
        DIN   => saddr_to_pad(i),
        PADIO => saddr(i),
        EN    => '1');
    saddr_rev_io : D8I1025_NS
      port map (
        DIN   => saddr_rev_to_pad(i),
        PADIO => saddr_rev(i),
        EN    => '1');
  end generate io2_gen;

  io_gen : for i in 0 to 15 generate
    din_re_io : I1025_EW
      port map (
        DOUT  => din_re_from_pad(i),
        PADIO => din_re(i),
        R_EN  => '1');
    din_im_io : I1025_EW
      port map (
        DOUT  => din_im_from_pad(i),
        PADIO => din_im(i),
        R_EN  => '1');
    sout0_re_io : D8I1025_EW
      port map (
        DIN   => sout0_re_to_pad(i),
        PADIO => sout0_re(i),
        EN    => '1');
    sout0_im_io : D8I1025_EW
      port map (
        DIN   => sout0_im_to_pad(i),
        PADIO => sout0_im(i),
        EN    => '1');
    sout1_re_io : D8I1025_NS
      port map (
        DIN   => sout1_re_to_pad(i),
        PADIO => sout1_re(i),
        EN    => '1');
    sout1_im_io : D8I1025_NS
      port map (
        DIN   => sout1_im_to_pad(i),
        PADIO => sout1_im(i),
        EN    => '1');
  end generate io_gen;

  fft_engine_1 : fft_engine
    generic map (
      LOG2_FFT_LEN => LOG2_FFT_LEN)
    port map (
      rst_n     => rst_n_from_pad,
      clk       => clk_from_pad,
      din       => din,
      valid     => valid_to_pad,
      saddr     => saddr_to_pad,
      saddr_rev => saddr_rev_to_pad,
      sout0     => sout0,
      sout1     => sout1);

  din.Re <= din_re_from_pad;
  din.Im <= din_im_from_pad;

  sout0_re_to_pad <= sout0.Re;
  sout0_im_to_pad <= sout0.Im;

  sout1_re_to_pad <= sout1.Re;
  sout1_im_to_pad <= sout1.Im;
end architecture structure;

