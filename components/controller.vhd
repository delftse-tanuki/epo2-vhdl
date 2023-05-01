library IEEE;
use ieee.std_logic_1164.all;

entity controller is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        sensor_data     : in std_logic_vector (2 downto 0);
        next_direction  : in std_logic_vector (1 downto 0); -- 00 = straight, 01 = left, 10 = right, 11 = backwards
        stop_checkpoint : in std_logic;

        motor_l_reset     : out std_logic;
        motor_l_direction : out std_logic; -- 1 = forward, 0 = backwards

        motor_r_reset     : out std_logic;
        motor_r_direction : out std_logic -- 0 = forward, 1 = backwards
    );
end entity controller;

architecture behavioural of controller is

    signal motor_left_reset, motor_right_reset         : std_logic := '0';
    signal motor_left_direction, motor_right_direction : std_logic := '0';
    signal turning, double_turning, skip, checkpoint   : std_logic := '0';

begin

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                motor_left_reset  <= '1';
                motor_right_reset <= '1';
                turning           <= '0';
                double_turning    <= '0';
                skip              <= '1';
                checkpoint        <= '0';
            elsif (double_turning = '1') then
                if (sensor_data = "100") then
                    turning        <= '1';
                    double_turning <= '0';
                end if;
            elsif (turning = '1') then
                if (sensor_data = "011" or sensor_data = "110") then
                    turning <= '0';
                end if;
            elsif (sensor_data = "000") then
                -- Checkpoint
                if (skip = '1') then
                    checkpoint <= '1';
                elsif (stop_checkpoint = '1') then
                    motor_left_reset  <= '1';
                    motor_right_reset <= '1';
                elsif (next_direction = "00") then
                    -- Straight
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '1';
                    motor_right_direction <= '0';
                elsif (next_direction = "01") then
                    -- Left
                    motor_left_reset      <= '1';
                    motor_right_reset     <= '0';
                    motor_right_direction <= '0';
                    turning               <= '1';
                elsif (next_direction = "10") then
                    -- Right
                    motor_left_reset     <= '0';
                    motor_right_reset    <= '1';
                    motor_left_direction <= '1';
                    turning              <= '1';
                elsif (next_direction = "11") then
                    -- Backwards
                    motor_left_reset      <= '0';
                    motor_right_reset     <= '0';
                    motor_left_direction  <= '0';
                    motor_right_direction <= '0';
                    double_turning        <= '1';
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
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            end if;
            if (checkpoint = '1' and sensor_data = "010") then
                checkpoint <= '0';
                skip       <= '0';
            end if;
        end if;
    end process;

    motor_l_reset <= motor_left_reset;
    motor_r_reset <= motor_right_reset;

    motor_l_direction <= motor_left_direction;
    motor_r_direction <= motor_right_direction;

end architecture behavioural;