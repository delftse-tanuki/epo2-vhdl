library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_control is
    port (
        clk                : in std_logic;
        reset              : in std_logic;
        ask_next_direction : in std_logic;

        next_direction : out std_logic_vector(1 downto 0);
        new_direction  : out std_logic;
        stop_station   : out std_logic
    );
end entity uart_control;

architecture behavioural of uart_control is
    constant STRAIGT_DIRECTION   : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION      : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION     : std_logic_vector(7 downto 0) := "00000010";
    constant BACKWARDS_DIRECTION : std_logic_vector(7 downto 0) := "00000011";

    signal data_in, data_out : std_logic_vector(7 downto 0);
begin
    next_direction <= "00";

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                data_in <= (others => '0');
            elsif (ask_next_direction = '1') then
                if (data_out = STRAIGT_DIRECTION) then
                    next_direction <= "00";
                elsif (data_out = LEFT_DIRECTION) then
                    next_direction <= "01";
                elsif (data_out = RIGHT_DIRECTION) then
                    next_direction <= "10";
                elsif (data_out = BACKWARDS_DIRECTION) then
                    next_direction <= "11";
                end if;
            end if;
        end if;
    end process;

    new_direction <= '0';
    stop_station  <= '0';
end architecture;