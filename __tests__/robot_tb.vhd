library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity robot_tb is
end robot_tb;

architecture structural of robot_tb is

    component robot is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            sensor_l_in : in std_logic;
            sensor_m_in : in std_logic;
            sensor_r_in : in std_logic;

            motor_l_pwm : out std_logic;
            motor_r_pwm : out std_logic
        );
    end component;

    signal clk, reset                            : std_logic;
    signal sensor_l_in, sensor_m_in, sensor_r_in : std_logic;
    signal sensors                               : std_logic_vector(2 downto 0);
    signal motor_l_pwm, motor_r_pwm              : std_logic;

begin

    lbl0 : robot port map(
        clk   => clk,
        reset => reset,

        sensor_l_in => sensor_l_in,
        sensor_m_in => sensor_m_in,
        sensor_r_in => sensor_r_in,

        motor_l_pwm => motor_l_pwm,
        motor_r_pwm => motor_r_pwm
    );

    -- 20 ns - 50 MHz
    clk <= '0' after 0 ns,
        '1' after 10 ns when clk /= '1' else '0' after 10 ns;

    reset <= '1' after 0 ns,
        '0' after 40 ms;

    sensors <= "000" after 0 ns, --bbb
        "001" after 70 ms, --bbr
        "010" after 110 ms, --brb
        "011" after 150 ms, --brr
        "100" after 190 ms, --rbb
        "101" after 230 ms, --rbr
        "110" after 270 ms, --rrb
        "111" after 310 ms; --rrr

    sensor_l_in <= sensors(2);
    sensor_m_in <= sensors(1);
    sensor_r_in <= sensors(0);

end structural;