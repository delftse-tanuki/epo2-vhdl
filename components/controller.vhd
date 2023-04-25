library IEEE;
use ieee.std_logic_1164.all;

entity controller is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        sensor_data : in std_logic_vector (2 downto 0);

        motor_l_reset     : out std_logic;
        motor_l_direction : out std_logic;

        motor_r_reset     : out std_logic;
        motor_r_direction : out std_logic
    );
end entity controller;

architecture behavioural of controller is

    signal motor_left_reset, motor_right_reset : std_logic := '0';
    signal motor_left_direction, motor_right_direction : std_logic := '0';

begin

    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                motor_left_reset  <= '1';
                motor_right_reset <= '1';
            elsif (sensor_data = "000") then
                motor_left_reset      <= '0';
                motor_right_reset     <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            elsif (sensor_data = "001") then
                motor_left_reset  <= '1';
                motor_right_reset <= '0';
                motor_right_direction <= '0';
            elsif (sensor_data = "010") then
                motor_left_reset  <= '0';
                motor_right_reset <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            elsif (sensor_data = "011") then
                motor_left_reset  <= '0';
                motor_right_reset <= '0';
                motor_left_direction  <= '0';
                motor_right_direction <= '0';
            elsif (sensor_data = "100") then
                motor_left_reset  <= '0';
                motor_right_reset <= '1';
                motor_left_direction  <= '1';
            elsif (sensor_data = "101") then
                motor_left_reset  <= '0';
                motor_right_reset <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            elsif (sensor_data = "110") then
                motor_left_reset  <= '0';
                motor_right_reset <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '1';
            elsif (sensor_data = "111") then
                motor_left_reset  <= '0';
                motor_right_reset <= '0';
                motor_left_direction  <= '1';
                motor_right_direction <= '0';
            end if;
        end if;
    end process;

    motor_l_reset <= motor_left_reset;
    motor_r_reset <= motor_right_reset;

    motor_l_direction <= motor_left_direction;
    motor_r_direction <= motor_right_direction;

end architecture behavioural;