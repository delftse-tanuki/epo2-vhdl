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

    type state_type is (sensor_in_high, sensor_in_low);

    signal count, new_count       : unsigned(13 downto 0);
    signal mine_detected_temp     : std_logic;
    signal mine_detected_i        : std_logic;
    signal sensor_in_rise_event   : std_logic;
    signal state_re, new_state_re : state_type;
begin

    process (state_re, sensor_in)
    begin
        case state_re is
            when sensor_in_low =>
                if (sensor_in = '1') then
                    sensor_in_rise_event <= '1';
                    new_state_re         <= sensor_in_high;
                else
                    new_state_re         <= sensor_in_low;
                    sensor_in_rise_event <= '0';
                end if;
            when sensor_in_high =>
                sensor_in_rise_event <= '0';
                if (sensor_in = '1') then
                    new_state_re <= sensor_in_high;
                else
                    new_state_re <= sensor_in_low;
                end if;
        end case;
    end process;

    process (clk, sensor_in_rise_event, mine_detected_temp)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                ledm            <= '0';
                count           <= (others => '0');
                mine_detected_i <= '0';
            else
                count <= new_count;
                ledm  <= mine_detected_i;
            end if;
        end if;
        if (sensor_in_rise_event = '1') then
            count           <= (others => '0');
            mine_detected_i <= mine_detected_temp;
        else null;
        end if;
    end process;

    process (count, mine_detected_temp)
    begin
        if (to_integer (count) >= 4900) then
            mine_detected_temp <= '1';
        elsif (mine_detected_temp = '1' and to_integer(count) < 200) then
            mine_detected_temp <= '1';
        else
            mine_detected_temp <= '0';
        end if;
        new_count <= count + 1;
    end process;

    process (clk)
    begin
        if (rising_edge(clk)) then
            state_re <= new_state_re;
        else null;
        end if;
    end process;

    mine_detected <= mine_detected_i;
end architecture behavioural;