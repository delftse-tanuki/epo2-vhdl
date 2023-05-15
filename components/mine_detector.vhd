library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mine_detector is
    port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        sensor_in               : in std_logic;
        mine_detected           : out std_logic
    );
end entity mine_detector;

architecture behavioural of mine_detector is

    signal count                : unsigned (13 downto 0) := (others => '0');
    signal new_count            : unsigned (13 downto 0) := (others => '0');
    signal mine_detected_temp   : std_logic;

begin

    process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1' or sensor_in = '1') then
                count <= (others => '0');
            else
                count <= new_count;
                mine_detected <= mine_detected_temp;
            end if;
        end if;
    end process;

    process (count)
    begin
        if(count =< 5000) then
            mine_detected_temp <= '1';
        else
            mine_detected_temp <= '0';
        end if;
        new_count <= count + 1;
    end process;