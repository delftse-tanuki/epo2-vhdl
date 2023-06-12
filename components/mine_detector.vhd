library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mine_detector is
    port (
        clk           : in std_logic;
        reset         : in std_logic;
        sensor_in     : in std_logic;
        mine_detected : out std_logic;
        ledm          : out std_logic
    );
end entity mine_detector;

architecture behavioural of mine_detector is

    signal count                : unsigned (13 downto 0) := (others => '0');
    signal new_count            : unsigned (13 downto 0) := (others => '0');
    type fsm_state is (reset_state, sensor_in_low, sensor_in_high, mine_detected_state);
    signal state, next_state    : fsm_state;
    signal mine_detected_i      : std_logic;


begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                    state <= reset_state;
            else
                    state <= next_state;
            end if;
        if(mine_detected_i = '1') then
            ledm <= '1';
        else ledm <= '0';
        end if;
    end if;

end process;
    
process(state, sensor_in)
begin
    case state is 
        when reset_state =>
        count <= (others => '0');
        mine_detected_i <= '0';
        if (sensor_in = '0') then
            next_state <= sensor_in_low;
        else next_state <= reset_state;
        end if;

        when sensor_in_low =>
        count <= count + 1;
        mine_detected_i <= '0';
        if (sensor_in = '1') then
            next_state <= sensor_in_high;
        else next_state <= sensor_in_low;
        end if;

        when sensor_in_high => 
        count <= count + 1;
        mine_detected_i <= '0';
        if (sensor_in = '0') then
        if (to_integer(count) <= 5000) then
            next_state <= mine_detected_state;
        else next_state <= reset_state;
        end if;
        else next_state <= sensor_in_high;
        end if;
        
        when mine_detected_state =>
        count <= count;
        mine_detected_i <= '1';
        next_state <= reset_state;
    end case;
end process;

mine_detected <= mine_detected_i;
end architecture behavioural;