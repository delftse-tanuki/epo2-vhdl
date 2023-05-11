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
    component uart is
        generic (
            FREQ_SCALE : integer := 1 -- RoverSim integration (Don't change)
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            rx : in std_logic;
            tx : out std_logic;

            data_in      : in std_logic_vector (7 downto 0);
            buffer_empty : out std_logic;
            write        : in std_logic;

            data_out   : out std_logic_vector (7 downto 0);
            data_ready : out std_logic;
            read       : in std_logic
        );
    end component uart;
    constant STRAIGT_DIRECTION   : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION      : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION     : std_logic_vector(7 downto 0) := "00000010";
    constant BACKWARDS_DIRECTION : std_logic_vector(7 downto 0) := "00000011";

    signal data_out, data_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal rx, tx              : std_logic;
    signal buffer_empty, write : std_logic;
    signal data_ready, read    : std_logic;

begin
    next_direction <= "00";

    comp1 : uart
    port map(
        clk   => clk,
        reset => reset,

        rx => rx,
        tx => tx,

        data_in      => data_in,
        buffer_empty => buffer_empty,
        write        => write,

        data_out   => data_out,
        data_ready => data_ready,
        read       => read
    );

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                next_direction <= "00";
            elsif (data_in = STRAIGT_DIRECTION) then
                next_direction <= "00";
            elsif (data_in = LEFT_DIRECTION) then
                next_direction <= "01";
            elsif (data_in = RIGHT_DIRECTION) then
                next_direction <= "10";
            elsif (data_in = BACKWARDS_DIRECTION) then
                next_direction <= "11";
            end if;
        end if;
    end process;
end architecture;