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

        tx : out std_logic;
        rx : in std_logic
    );
end entity uart_control;

architecture behavioural of uart_control is
    constant STRAIGHT_DIRECTION : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION     : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION    : std_logic_vector(7 downto 0) := "00000010";
    constant STOP               : std_logic_vector(7 downto 0) := "00000011";

    component uart is
        generic (
            FREQ_SCALE : integer := 1
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            data_in  : in std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0);

            buffer_empty : out std_logic;
            data_ready   : out std_logic;

            read  : in std_logic;
            write : in std_logic;

            tx : out std_logic;
            rx : in std_logic
        );
    end component uart;

    type state_type is (asked, recieved, executed);

    signal data_in, data_out : std_logic_vector(7 downto 0);
    signal data_ready, write : std_logic;
    signal state, next_state : state_type := recieved;
begin
    uart_inst : uart
    port map(
        clk   => clk,
        reset => reset,

        data_in  => data_in,
        data_out => data_out,

        data_ready   => data_ready,
        buffer_empty => open,

        read  => data_ready,
        write => write,

        tx => tx,
        rx => rx
    );

    process (state, data_ready, data_out, ask_next_direction)
    begin
        case state is
            when asked =>
                write <= '0';
                if (data_ready = '1') then
                    next_state <= recieved;
                end if;
            when recieved =>
                if (data_out = STRAIGHT_DIRECTION) then
                    next_direction <= "00";
                elsif (data_out = LEFT_DIRECTION) then
                    next_direction <= "01";
                elsif (data_out = RIGHT_DIRECTION) then
                    next_direction <= "10";
                elsif (data_out = STOP) then
                    if (reset = '1') then
                        stop_station <= '0';
                    else
                        stop_station <= '1';
                    end if;
                else
                    next_direction <= "00";
                end if;
                next_state <= executed;
            when executed =>
                if (ask_next_direction = '1') then
                    write      <= '1';
                    next_state <= asked;
                end if;
        end case;
    end process;

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state        <= recieved;
                stop_station <= '0';
            else
                state <= next_state;
            end if;
        end if;
    end process;

    new_direction <= '1' when (state = recieved) else '0';
    data_in       <= "00100000";
end architecture;