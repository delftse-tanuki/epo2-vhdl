library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity three_bit_registry is
    port (
        clk     : in std_logic;
        reg_in  : in std_logic_vector(2 downto 0);
        reg_out : out std_logic_vector(2 downto 0)
    );
end entity three_bit_registry;

architecture arch of three_bit_registry is
begin

    process (clk)
    begin
        if (rising_edge(clk)) then
            reg_out <= reg_in;
        end if;
    end process;

end architecture arch;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity inputbuffer is
    port (
        clk : in std_logic;

        sensor_l_in : in std_logic;
        sensor_m_in : in std_logic;
        sensor_r_in : in std_logic;

        sensor_out  : out std_logic_vector(2 downto 0)
    );
end entity inputbuffer;

architecture behavioural of inputbuffer is

    component three_bit_registry is
        port (
            clk     : in std_logic;
            reg_in  : in std_logic_vector(2 downto 0);
            reg_out : out std_logic_vector(2 downto 0)
        );
    end component three_bit_registry;

    signal sensor_in, reg1_out, reg2_out : std_logic_vector(2 downto 0) := (others => '0');

begin

    sensor_in <= sensor_l_in & sensor_m_in & sensor_r_in;

    reg1: three_bit_registry port map(
        clk     => clk,
        reg_in  => sensor_in,
        reg_out => reg1_out
    );

    reg2: three_bit_registry port map(
        clk     => clk,
        reg_in  => reg1_out,
        reg_out => reg2_out
    );

    sensor_out <= reg2_out;

end architecture behavioural;