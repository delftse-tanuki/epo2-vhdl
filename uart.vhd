library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart is
    port (
        clk : in std_logic;
        rst : in std_logic;

        rx  : in std_logic; -- input from uart
        tx  : out std_logic; -- output to uart

        data_in : in std_logic_vector(7 downto 0); -- input from processor
        buffer_empty : out std_logic; -- flag '1' if buffer is empty
        write : in std_logic; -- flag '1' to write to buffer
        
        data_out : out std_logic_vector(7 downto 0); -- output to processor
        data_ready : out std_logic; -- flag '1' if new data in rx buffer
        read : in std_logic -- flag '1' to read from rx buffer
    );
end entity uart;