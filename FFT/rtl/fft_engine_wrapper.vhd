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
-- LOG2_FFT_LEN : integer := 4); -- Defines order of FFT
port (
-- System interface
    rst_n : in std_logic;
    clk : in std_logic;
    -- Input memory interface
    din_re : in SIGNED(15 downto 0); -- data input
    din_im : in SIGNED(15 downto 0); -- data input
    valid : out std_logic;
    saddr : out unsigned(2 downto 0);
    saddr_rev : out unsigned(2 downto 0);
    sout0_re : out SIGNED(15 downto 0); -- spectrum output
    sout0_im : out SIGNED(15 downto 0); -- spectrum output
    sout1_re : out SIGNED(15 downto 0); -- spectrum output
    sout1_im : out SIGNED(15 downto 0) -- spectrum output
);
end fft_engine_wrapper;

architecture structure of fft_engine_wrapper is
constant LOG2_FFT_LEN : integer := 4;
component fft_engine is
generic (
    LOG2_FFT_LEN : integer);
    port (
        rst_n : in std_logic;
        clk : in std_logic;
        din : in icpx_number;
        valid : out std_logic;
        saddr : out unsigned(LOG2_FFT_LEN-2 downto 0);
        saddr_rev : out unsigned(LOG2_FFT_LEN-2 downto 0);
        sout0 : out icpx_number;
        sout1 : out icpx_number);
end component fft_engine;

signal din : icpx_number;
signal sout0 : icpx_number;
signal sout1 : icpx_number;
begin -- architecture structure
fft_engine_1: entity work.fft_engine
generic map (
    LOG2_FFT_LEN => LOG2_FFT_LEN)
    port map (
        rst_n => rst_n,
        clk => clk,
        din => din,
        valid => valid,
        saddr => saddr,
        saddr_rev => saddr_rev,
        sout0 => sout0,
        sout1 => sout1);
        din.Re <= din_re;
        din.Im <= din_im;
        sout0_re <= sout0.Re;
        sout0_im <= sout0.Im;
        sout1_re <= sout1.Re;
        sout1_im <= sout1.Im;
end architecture structure;