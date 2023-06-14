library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_control is
    port (
        clk                : in std_logic;
        reset              : in std_logic;
        ask_next_direction : in std_logic;
        mine_detected      : in std_logic;

        next_direction : out std_logic_vector(1 downto 0);
        led1           : out std_logic;

        tx : out std_logic;
        rx : in std_logic
    );
end entity uart_control;

architecture behavioural of uart_control is
    constant STRAIGHT_DIRECTION : std_logic_vector(7 downto 0) := "00000000";
    constant LEFT_DIRECTION     : std_logic_vector(7 downto 0) := "00000001";
    constant RIGHT_DIRECTION    : std_logic_vector(7 downto 0) := "00000010";
    constant START_STOP         : std_logic_vector(7 downto 0) := "00000011";

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

    signal data_in, data_out                     : std_logic_vector(7 downto 0);
    signal data_ready, write, written, read_data : std_logic;
begin
    uart_inst : uart
    port map(
        clk   => clk,
        reset => reset,

        data_in  => data_in,
        data_out => data_out,

        data_ready   => data_ready,
        buffer_empty => open,

        read  => read_data,
        write => write,

        tx => tx,
        rx => rx
    );

    process (clk, reset, ask_next_direction, write, written)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                write   <= '0';
                written <= '0';
                led1    <= '0';
            elsif (write = '1') then
                write   <= '0';
                written <= '1';
                led1    <= '0';
            elsif ((ask_next_direction = '1' or mine_detected) and written = '0') then
                write <= '1';
                led1  <= '0';
            elsif (ask_next_direction = '0' and mine_detected) then
                written <= '0';
                led1    <= '0';
            else
                led1 <= '1';
            end if;
        else null;
        end if;
    end process;

    process (clk, reset, data_ready, read_data, data_out)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                next_direction <= "00";
                read_data      <= '0';
            elsif (data_ready = '1') then
                if (data_out = STRAIGHT_DIRECTION) then
                    next_direction <= "00";
                elsif (data_out = LEFT_DIRECTION) then
                    next_direction <= "01";
                elsif (data_out = RIGHT_DIRECTION) then
                    next_direction <= "10";
                elsif (data_out = START_STOP) then
                    next_direction <= "11";
                else
                    next_direction <= "00";
                end if;
                read_data <= '1';
            elsif (read_data = '1') then
                read_data <= '0';
            else null;
            end if;
        else null;
        end if;
    end process;

    process (ask_next_direction, mine_detected)
    begin
        if (ask_next_direction = '1') then
            data_in <= "00000001";
        elsif (mine_detected = '1') then
            data_in <= "00000010";
        else
            data_in <= "00000000";
        end if;
    end process;

end architecture;