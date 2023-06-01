library IEEE;
use IEEE.std_logic_1164.all;

entity robot is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        sensor_l_in : in std_logic;
        sensor_m_in : in std_logic;
        sensor_r_in : in std_logic;

        motor_l_pwm : out std_logic;
        motor_r_pwm : out std_logic;

        rx   : in std_logic;
        tx   : out std_logic;
        led0 : out std_logic;
        led1 : out std_logic;
        led2 : out std_logic
    );
end entity robot;

architecture structural of robot is
    component inputbuffer is
        port (
            clk : in std_logic;

            sensor_l_in : in std_logic;
            sensor_m_in : in std_logic;
            sensor_r_in : in std_logic;

            sensor_out : out std_logic_vector(2 downto 0)
        );
    end component;

    component controller is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            sensor_data    : in std_logic_vector(2 downto 0);
            next_direction : in std_logic_vector(1 downto 0);
            stop_station   : in std_logic;
            new_direction  : in std_logic;

            motor_l_reset     : out std_logic;
            motor_l_direction : out std_logic;

            motor_r_reset     : out std_logic;
            motor_r_direction : out std_logic;

            ask_next_direction : out std_logic
        );
    end component;

    component timebase is
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            count_out : out std_logic_vector(19 downto 0)
        );
    end component timebase;

    component motorcontrol is
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            direction : in std_logic;
            count_in  : in std_logic_vector(19 downto 0);
            pwm       : out std_logic
        );
    end component motorcontrol;

    component uart_control is
        port (
            clk                : in std_logic;
            reset              : in std_logic;
            ask_next_direction : in std_logic;

            next_direction : out std_logic_vector(1 downto 0);
            new_direction  : out std_logic;
            stop_station   : out std_logic;

            led0 : out std_logic;
            led1 : out std_logic;
            led2 : out std_logic;

            tx : out std_logic;
            rx : in std_logic
        );
    end component uart_control;

    signal sensor_data                                     : std_logic_vector(2 downto 0);
    signal count_out                                       : std_logic_vector(19 downto 0);
    signal motor_l_reset, motor_l_direction                : std_logic;
    signal motor_r_reset, motor_r_direction                : std_logic;
    signal next_direction                                  : std_logic_vector(1 downto 0);
    signal new_direction, ask_next_direction, stop_station : std_logic;
begin

    comp1 : inputbuffer
    port map(
        clk => clk,

        sensor_l_in => sensor_l_in,
        sensor_m_in => sensor_m_in,
        sensor_r_in => sensor_r_in,

        sensor_out => sensor_data
    );

    comp2 : controller
    port map(
        clk   => clk,
        reset => reset,

        sensor_data    => sensor_data,
        next_direction => next_direction,
        stop_station   => stop_station,
        new_direction  => new_direction,

        motor_l_reset     => motor_l_reset,
        motor_l_direction => motor_l_direction,

        motor_r_reset     => motor_r_reset,
        motor_r_direction => motor_r_direction,

        ask_next_direction => ask_next_direction
    );

    comp3 : timebase
    port map(
        clk       => clk,
        reset     => reset,
        count_out => count_out
    );

    comp4 : uart_control
    port map(
        clk                => clk,
        reset              => reset,
        ask_next_direction => ask_next_direction,

        next_direction => next_direction,
        new_direction  => new_direction,
        stop_station   => stop_station,

        led0 => led0,
        led1 => led1,
        led2 => led2,

        tx => tx,
        rx => rx
    );

    motorcontrol_l : motorcontrol
    port map(
        clk       => clk,
        reset     => motor_l_reset,
        direction => motor_l_direction,
        count_in  => count_out,
        pwm       => motor_l_pwm
    );

    motorcontrol_r : motorcontrol
    port map(
        clk       => clk,
        reset     => motor_r_reset,
        direction => motor_r_direction,
        count_in  => count_out,
        pwm       => motor_r_pwm
    );
end architecture structural;