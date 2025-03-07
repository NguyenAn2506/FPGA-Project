library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use ieee.math_complex.all;
library std;
use std.textio.all;
library work;
use work.fft_len.all;
use work.icpx.all;
use work.fft_support_pkg.all;
-------------------------------------------------------------------------------
entity fft_engine_wrapper_tb is
end fft_engine_wrapper_tb;
-------------------------------------------------------------------------------
architecture beh1 of fft_engine_wrapper_tb is
    type T_OUT_DATA is array (0 to FFT_LEN-1) of icpx_number;
    signal dptr : integer range 0 to 15;
    signal din, sout0, sout1 : icpx_number;
    signal saddr, saddr_rev : unsigned(LOG2_FFT_LEN-2 downto 0);
    signal end_of_data, end_sim : boolean := false;
    component fft_engine_wrapper is
        port (
            rst_n : in std_logic;
            clk : in std_logic;
            din_re : in SIGNED(15 downto 0);
            din_im : in SIGNED(15 downto 0);
            valid : out std_logic;
            saddr : out unsigned(2 downto 0);
            saddr_rev : out unsigned(2 downto 0);
            sout0_re : out SIGNED(15 downto 0);
            sout0_im : out SIGNED(15 downto 0);
            sout1_re : out SIGNED(15 downto 0);
            sout1_im : out SIGNED(15 downto 0));
    end component fft_engine_wrapper;
    -- component ports
    signal rst_n : std_logic := '0';
    signal valid : std_logic;
    -- clock
    signal Clk : std_logic := '1';

    begin -- beh1
        fft_engine_wrapper_1: entity work.fft_engine_wrapper
        port map (
            rst_n => rst_n,
            clk => clk,
            din_re => din.re,
            din_im => din.im,
            valid => valid,
            saddr => saddr,
            saddr_rev => saddr_rev,
            sout0_re => sout0.re,
            sout0_im => sout0.im,
            sout1_re => sout1.re,
            sout1_im => sout1.im);
        Clk <= not Clk after 10 ns when end_sim = false else '0';
    -- waveform generation
    WaveGen_Proc : process
        file data_in : text open read_mode is "data_in.txt";
        variable input_line : line;
        file data_out : text open write_mode is "data_out.txt";
        variable output_line : line;
        variable tre, tim : real;
        constant sep : string := " ";
        variable vout : T_OUT_DATA;
    begin
        -- insert signal assignments here
        wait until Clk = '1';
        wait for 15 ns;
        wait until clk = '0';
        wait until clk = '1';
        rst_n <= '1';
        dptr <= 0;
        l1 : while not end_sim loop
        if not endfile(data_in) then
            readline(data_in, input_line);
            read(input_line, tre);
            read(input_line, tim);
        else
            end_of_data <= true;
        end if;
            din <= cplx2icpx(complex'(tre, tim));
        if dptr < 15 then
            dptr <= dptr + 1;
        else
            dptr <= 0;
        end if;
        -- Copy the data produced by the core to the output buffer
        vout(to_integer(saddr_rev)) := sout0;
        vout(to_integer('1' & saddr_rev)) := sout1;
        -- If the full set of data is calculated, write the output buffer
        if saddr = FFT_LEN/2-1 then
            write(output_line, string'("FFT RESULT BEGIN"));
            writeline(data_out, output_line);
        for i in 0 to FFT_LEN-1 loop
            write(output_line, integer'image(to_integer(vout(i).re)));
            write(output_line, sep);
            write(output_line, integer'image(to_integer(vout(i).im)));
            writeline(data_out, output_line);
        end loop; -- i
        write(output_line, string'("FFT RESULT END"));
        writeline(data_out, output_line);
        exit l1 when end_of_data;
        end if;
        wait until clk = '0';
        wait until clk = '1';
        end loop l1;
    end_sim <= true;
    end process WaveGen_Proc;
end beh1;