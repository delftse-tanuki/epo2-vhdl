library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mine_tb is
end mine_tb;

architecture structural of mine_tb is

    component robot is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            sensor_l_in : in std_logic;
            sensor_m_in : in std_logic;
            sensor_r_in : in std_logic;

            sensor_mine : in std_logic;

            motor_l_pwm : out std_logic;
            motor_r_pwm : out std_logic;

            rx   : in std_logic;
            tx   : out std_logic;
            led0 : out std_logic;
            led1 : out std_logic;
            led2 : out std_logic;
            ledm : out std_logic
        );
    end component;

    signal clk, reset                            : std_logic;
    signal sensor_l_in, sensor_m_in, sensor_r_in : std_logic;
    signal sensors                               : std_logic_vector(2 downto 0);
    signal motor_l_pwm, motor_r_pwm              : std_logic;
    signal sensor_mine                           : std_logic;
    signal rx, tx                                : std_logic;
    signal led0, led1, led2, ledm                : std_logic;

begin

    lbl0 : robot port map(
        clk   => clk,
        reset => reset,

        sensor_l_in => sensor_l_in,
        sensor_m_in => sensor_m_in,
        sensor_r_in => sensor_r_in,

        sensor_mine => sensor_mine,

        motor_l_pwm => motor_l_pwm,
        motor_r_pwm => motor_r_pwm,

        rx => rx,
        tx => tx,

        led0 => led0,
        led1 => led1,
        led2 => led2,
        ledm => ledm

        
    );

    -- 20 ns - 50 MHz
    clk <= '0' after 0 ns,
        '1' after 10 ns when clk /= '1' else '0' after 10 ns;

    reset <= '1' after 0 ns,
        '0' after 40 ns;

    sensors <= "000" after 0 ns, 
        "010" after 200 ns;
    
    sensor_mine <= '0' after 0 ns,
        '1' after 100 us when sensor_mine /= '1' else '0' after 100 us;
        

    sensor_l_in <= sensors(2);
    sensor_m_in <= sensors(1);
    sensor_r_in <= sensors(0);

end structural;