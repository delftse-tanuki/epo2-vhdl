library IEEE;
use ieee.std_logic_1164.all;

entity controller is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        sensor_data    : in std_logic_vector (2 downto 0);
        next_direction : in std_logic_vector (1 downto 0); -- 00 = straight, 01 = left, 10 = right, 11 = start/stop

        motor_l_reset     : out std_logic;
        motor_l_direction : out std_logic; -- 1 = forward, 0 = backwards

        motor_r_reset     : out std_logic;
        motor_r_direction : out std_logic; -- 0 = forward, 1 = backwards

        ask_next_direction : out std_logic
    );
end entity controller;

architecture behavioural of controller is

    signal motor_left_reset, motor_right_reset, drive  : std_logic;
    signal motor_left_direction, motor_right_direction : std_logic;
    signal skip_checkpoint, checkpoint, backwards      : std_logic;

begin

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                motor_left_reset  <= '1';
                motor_right_reset <= '1';
                skip_checkpoint   <= '0';
                checkpoint        <= '0';
                drive             <= '0';
                backwards         <= '0';
            elsif (drive = '0') then
                motor_left_reset  <= '1';
                motor_right_reset <= '1';
                if (next_direction = "11") then
                    drive <= '1';
                end if;
            elsif (backwards = '1') then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '0';
                motor_right_direction <= '1';
                if (sensor_data = "000") then
                    backwards <= '0';
                end if;
            elsif (sensor_data = "000") then
                -- Checkpoint
                checkpoint <= '1';
                if (skip_checkpoint = '1') then
                    -- Skip checkpoint
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '1';
                    motor_right_direction <= '0';
                elsif (next_direction = "00") then
                    -- Straight
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '1';
                    motor_right_direction <= '0';
                elsif (next_direction = "01") then
                    -- Left
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '0';
                    motor_right_direction <= '0';
                elsif (next_direction = "10") then
                    -- Right
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '1';
                    motor_right_direction <= '1';
                end if;
            elsif (sensor_data = "001") then
                motor_left_reset      <= '1';
                motor_right_reset     <= '0';
                motor_right_direction <= '0';
            elsif (sensor_data = "010") then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            elsif (sensor_data = "011") then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '0';
                motor_right_direction <= '0';
            elsif (sensor_data = "100") then
                motor_left_reset     <= '0';
                motor_right_reset    <= '1';
                motor_left_direction <= '1';
            elsif (sensor_data = "101") then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            elsif (sensor_data = "110") then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '1';
            elsif (sensor_data = "111") then
                --Station
                if (next_direction = "11") then
                    motor_left_reset  <= '1';
                    motor_right_reset <= '1';
                else
                    -- Drive backwards and reset skip_checkpoint
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '0';
                    motor_right_direction <= '1';
                    backwards             <= '1';
                    ask_next_direction    <= '0';
                    skip_checkpoint       <= '0';
                end if;
            end if;
            if (checkpoint = '1' and sensor_data = "101") then
                checkpoint <= '0';
                if (skip_checkpoint = '1') then
                    skip_checkpoint    <= '0';
                    ask_next_direction <= '1';
                else
                    skip_checkpoint    <= '1';
                    ask_next_direction <= '0';
                end if;
            end if;
        end if;
    end process;

    motor_l_reset <= motor_left_reset;
    motor_r_reset <= motor_right_reset;

    motor_l_direction <= motor_left_direction;
    motor_r_direction <= motor_right_direction;

end architecture behavioural;