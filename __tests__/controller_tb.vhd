library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity controller_tb is end;

architecture structural of controller_tb is

    component controller is
        port (
            clk   : in std_logic;
            reset : in std_logic;
    
            sensor_data : in std_logic_vector (2 downto 0);
    
            count_in    : in std_logic_vector (19 downto 0);
            count_reset : out std_logic;
    
            motor_l_reset     : out std_logic;
            motor_l_direction : out std_logic;
    
            motor_r_reset     : out std_logic;
            motor_r_direction : out std_logic
        );
    end component controller;

    component timebase is
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            count_out : out std_logic_vector (19 downto 0)
        );
    end component timebase;

    signal clk       : std_logic;
    signal reset     : std_logic;

    signal sensor_data : std_logic_vector (2 downto 0);

    signal count_in    : std_logic_vector (19 downto 0);
    signal count_reset : std_logic;

    signal motor_l_reset     : std_logic;
    signal motor_l_direction : std_logic;

    signal motor_r_reset     : std_logic;
    signal motor_r_direction : std_logic;

begin
    clk <= '1' after 0 ns,
        '0' after 10 ns when clk /= '0' else '1' after 10 ns;

    reset <=    '0' after 0 ns,
                '1' after 240 ms;

    sensor_data <=  "000" after 0 ns,
                    "001" after 30 ms,
                    "010" after 60 ms,
                    "011" after 90 ms,
                    "100" after 120 ms,
                    "101" after 150 ms,
                    "110" after 180 ms,
                    "111" after 210 ms;

    LB1 : timebase port map(
        clk       => clk,
        reset     => reset,
        count_out => count_in
    );

    LB2 : controller port map(
        clk   => clk,
        reset => reset,

        sensor_data => sensor_data,

        count_in    => count_in,
        count_reset => count_reset,

        motor_l_reset     => motor_l_reset,
        motor_l_direction => motor_l_direction,

        motor_r_reset     => motor_r_reset,
        motor_r_direction => motor_r_direction
    );

end architecture structural;