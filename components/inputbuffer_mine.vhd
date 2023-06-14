library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity one_bit_registry is
    port (
        clk     : in std_logic;
        reg_in  : in std_logic;
        reg_out : out std_logic
    );
end entity one_bit_registry;

architecture arch of one_bit_registry is
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

entity m_inputbuffer is
    port (
        clk : in std_logic;

        sensor_in : in std_logic;

        sensor_out : out std_logic
    );
end entity m_inputbuffer;

architecture behavioural of m_inputbuffer is

    component one_bit_registry is
        port (
            clk     : in std_logic;
            reg_in  : in std_logic;
            reg_out : out std_logic
        );
    end component one_bit_registry;

    signal reg1_out : std_logic;

begin

    reg1 : one_bit_registry port map(
        clk     => clk,
        reg_in  => sensor_in,
        reg_out => reg1_out
    );

    reg2 : one_bit_registry port map(
        clk     => clk,
        reg_in  => reg1_out,
        reg_out => sensor_out
    );
end architecture behavioural;