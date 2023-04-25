library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity motorcontrol is
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        direction : in std_logic;
        count_in  : in std_logic_vector (19 downto 0);
        pwm       : out std_logic
    );
end entity motorcontrol;

architecture behavioural of motorcontrol is

    signal pwm_out : std_logic;

begin
    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                pwm_out <= '0';
            elsif (direction = '0') then
                -- 1 ms
                if (to_integer(unsigned(count_in)) < 50000) then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;
            else
                -- 2 ms
                if (to_integer(unsigned(count_in)) < 100000) then
                    pwm_out <= '1';
                else
                    pwm_out <= '0';
                end if;
            end if;
        end if;
    end process;

    process (pwm_out)
    begin
        pwm <= pwm_out;
    end process;

end architecture behavioural;