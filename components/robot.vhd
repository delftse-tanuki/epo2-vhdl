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
        motor_r_pwm : out std_logic
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

            sensor_data     : in std_logic_vector(2 downto 0);
            next_direction  : in std_logic_vector(1 downto 0);
            stop_checkpoint : in std_logic;
            new_direction   : in std_logic;

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

    signal sensor_data                      : std_logic_vector(2 downto 0);
    signal count_out                        : std_logic_vector(19 downto 0);
    signal motor_l_reset, motor_l_direction : std_logic;
    signal motor_r_reset, motor_r_direction : std_logic;
    type direction_state is (forward_1, right_1, left_1, left_2, right_2, backward_1, forward_2, forward_3, backward_2);
    signal state, next_state                               : direction_state;


begin

    process(state)
    begin
        case state is 
            when forward_1 =>
            new_direction <= "00";
            next_state <= right_1;

            when right_1 =>
            new_direction <= "10";
            next_state <= left_1;

            when left_1 => 
            new_direction <= "01";
            next_state <= left_2;

            when left_2 =>
            new_direction <= "01";
            next_state <= right_2;

            when right_2 =>
            new_direction <= "10";
            next_state <= backward;

            when backward =>
            new_direction <= "11";
            next_state <= forward_2;

            when forward_2 =>
            new_direction <= "00";
            next_state <= forward_3;

            when forward_3 =>
            new_direction <= "00";
            next_state <= forward_4;

            when forward_4 =>
            new_direction <= "00";
            next_state <= backward_2;

            when backward_2 =>
            new_direction <= "11";
            next_state <= forward_1
        end case;
    end process;

    process(reset, ask_next_direction) --update de state als the main controller een nieuwe value voor direction wil.
    begin
        if (reset = '1') then
            state <= forward_1;
        elsif (ask_next_direction = '1') then
            state <= next_state;
        end if;
    end process;

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

        sensor_data     => sensor_data,
        next_direction  => "01",
        stop_checkpoint => '0',
        new_direction   => '0',

        motor_l_reset     => motor_l_reset,
        motor_l_direction => motor_l_direction,

        motor_r_reset     => motor_r_reset,
        motor_r_direction => motor_r_direction,

        ask_next_direction => open
    );

    comp3 : timebase
    port map(
        clk       => clk,
        reset     => reset,
        count_out => count_out
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