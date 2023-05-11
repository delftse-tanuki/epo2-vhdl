library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_control is
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        input_bit : in std_logic_vector(7 downto 0);

        next_direction : out std_logic_vector(1 downto 0)
    );
end entity uart_control;

architecture behavioural of uart_control is
    constant STRAIGT_DIRECTION   : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION      : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION     : std_logic_vector(7 downto 0) := "00000010";
    constant BACKWARDS_DIRECTION : std_logic_vector(7 downto 0) := "00000011";

begin
    next_direction <= "00";

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                next_direction <= "00";
            elsif (input_bit = STRAIGT_DIRECTION) then
                next_direction <= "00";
            elsif (input_bit = LEFT_DIRECTION) then
                next_direction <= "01";
            elsif (input_bit = RIGHT_DIRECTION) then
                next_direction <= "10";
            elsif (input_bit = BACKWARDS_DIRECTION) then
                next_direction <= "11";
            end if;
        end if;
    end process;
end architecture;