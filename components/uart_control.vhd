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
        stop_station   : out std_logic;
        led0           : out std_logic
    );
end entity uart_control;

architecture behavioural of uart_control is
    constant STRAIGHT_DIRECTION   : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION      : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION     : std_logic_vector(7 downto 0) := "00000010";
    constant BACKWARDS_DIRECTION : std_logic_vector(7 downto 0) := "00000011";

    component uart is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            data_in  : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0);
        );
    end component uart;

    signal data_in, data_out : std_logic_vector(7 downto 0);
begin
    uart_inst : uart
    port map(
        clk   => clk,
        reset => reset,

        data_in  => data_in,
        data_out => data_out
    );

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                data_in <= (others => '0');
            elsif (ask_next_direction = '1') then
                if (data_out = STRAIGHT_DIRECTION) then
                    next_direction <= "00";
                    led0           <= '0';
                elsif (data_out = LEFT_DIRECTION) then
                    next_direction <= "01";
                    led0           <= '0';
                elsif (data_out = RIGHT_DIRECTION) then
                    next_direction <= "10";
                    led0           <= '0';
                elsif (data_out = BACKWARDS_DIRECTION) then
                    next_direction <= "11";
                    led0           <= '1';
                else
                    next_direction <= "00";
                    led0           <= '0';
                end if;
            end if;
        end if;
    end process;

    new_direction <= '0';
    stop_station  <= '0';
end architecture;