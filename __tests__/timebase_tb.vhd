library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timebase_tb is end;

architecture structural of timebase_tb is

    component timebase is
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            count_out : out std_logic_vector (19 downto 0)
        );
    end component timebase;

    signal clk       : std_logic;
    signal reset     : std_logic;
    signal count_out : std_logic_vector(19 downto 0);

begin
    clk <= '1' after 0 ns,
        '0' after 10 ns when clk /= '0' else '1' after 10 ns;

    reset <= '0';

    LB1 : timebase port map(
        clk       => clk,
        reset     => reset,
        count_out => count_out
    );

end architecture structural;