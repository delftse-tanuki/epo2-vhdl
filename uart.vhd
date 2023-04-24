-- This file is provided to the students of the EPO-2 project.
-- This file is only meant to be used, not edited.

-- uart.vhdl
--
-- complete uart
library IEEE;
use IEEE.std_logic_1164.all;

entity uart is
    generic (
        FREQ_SCALE : integer := 1 -- RoverSim integration (Don't change)
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        rx : in std_logic;
        tx : out std_logic;

        data_in      : in std_logic_vector (7 downto 0);
        buffer_empty : out std_logic;
        write        : in std_logic;

        data_out   : out std_logic_vector (7 downto 0);
        data_ready : out std_logic;
        read       : in std_logic
    );
end entity uart;
architecture structural of uart is

    component uart_rx is
        generic (
            CLKS_PER_SAMPLE : integer;
            OVERSAMPLING    : integer range 1 to 16
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            rx : in std_logic;

            read       : in std_logic;
            data_ready : out std_logic;
            data_out   : out std_logic_vector (7 downto 0)
        );
    end component uart_rx;

    component uart_tx is
        generic (
            CLKS_PER_SAMPLE : integer;
            OVERSAMPLING    : integer range 1 to 16
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            write        : in std_logic;
            data_in      : in std_logic_vector (7 downto 0);
            buffer_empty : out std_logic;

            tx : out std_logic
        );
    end component uart_tx;

    constant CLKS_PER_SAMPLE_1    : integer := 325;
    constant CLKS_PER_SAMPLE_5000 : integer := 13; -- old value: 13

    constant OVERSAMPLING : integer := 16;

begin

    assert (FREQ_SCALE = 1) or (FREQ_SCALE = 5000)
    report "FREQ_SCALE must be 1 or 5000" severity failure;

    --------------------------------------
    -- For use with real-time frequency --
    --------------------------------------
    HIGH_FREQ : if FREQ_SCALE = 1 generate

        uart_rx_map_1 :
        uart_rx generic map(
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_1,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map(
            clk        => clk,
            reset      => reset,
            rx         => rx,
            read       => read,
            data_ready => data_ready,
            data_out   => data_out
        );

        uart_tx_map_1 :
        uart_tx generic map(
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_1,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map(
            clk          => clk,
            reset        => reset,
            write        => write,
            data_in      => data_in,
            buffer_empty => buffer_empty,
            tx           => tx
        );

    end generate;

    ----------------------------------------------
    -- For use with matlab simulation frequency --
    ----------------------------------------------
    LOW_FREQ : if FREQ_SCALE = 5000 generate

        uart_rx_map_5000 :
        uart_rx generic map(
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_5000,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map(
            clk        => clk,
            reset      => reset,
            rx         => rx,
            read       => read,
            data_ready => data_ready,
            data_out   => data_out
        );

        uart_tx_map_5000 :
        uart_tx generic map(
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_5000,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map(
            clk          => clk,
            reset        => reset,
            write        => write,
            data_in      => data_in,
            buffer_empty => buffer_empty,
            tx           => tx
        );

    end generate;

end architecture structural;

-- uart_rx.vhdl
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKS_PER_SAMPLE : integer;
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        rx : in std_logic;

        read       : in std_logic;
        data_ready : out std_logic;
        data_out   : out std_logic_vector (7 downto 0)
    );
end entity uart_rx;
architecture structural of uart_rx is

    component uart_buffer is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            write : in std_logic;
            read  : in std_logic;

            data_in    : in std_logic_vector (7 downto 0);
            data_out   : out std_logic_vector (7 downto 0);
            data_ready : out std_logic
        );
    end component uart_buffer;

    component uart_clk is
        generic (
            CLKS_PER_SAMPLE : integer;
            OVERSAMPLING    : integer range 1 to 16
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            sample_clk   : out std_logic;
            sample_count : out std_logic_vector (3 downto 0);

            baud_clk : out std_logic
        );
    end component uart_clk;

    component sync_buffer is
        port (
            clk      : in std_logic;
            data_in  : in std_logic;
            data_out : out std_logic
        );
    end component sync_buffer;

    component oversampler is
        generic (
            OVERSAMPLING : integer range 1 to 16
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            rx : in std_logic;

            sample_clk : in std_logic;
            rx_sampled : out std_logic
        );
    end component oversampler;

    component rx_fsm is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            rx                : in std_logic;
            oversampler_reset : out std_logic;
            rx_sampled        : in std_logic;

            uart_clk_reset : out std_logic;
            baud_clk       : in std_logic;

            rx_data             : out std_logic_vector (7 downto 0);
            output_buffer_write : out std_logic
        );
    end component rx_fsm;

    signal rx_data             : std_logic_vector (7 downto 0);
    signal output_buffer_write : std_logic;

    signal uart_clk_reset, sample_clk, baud_clk : std_logic;

    signal rx_sync, oversampler_reset, rx_sampled : std_logic;
begin

    uart_buffer_map :
    uart_buffer port map(
        clk   => clk,
        reset => reset,

        write => output_buffer_write,
        read  => read,

        data_in    => rx_data,
        data_out   => data_out,
        data_ready => data_ready
    );

    uart_clk_map :
    uart_clk generic map(
        CLKS_PER_SAMPLE => CLKS_PER_SAMPLE,
        OVERSAMPLING    => OVERSAMPLING
    )
    port map(
        clk   => clk,
        reset => uart_clk_reset,

        sample_clk => sample_clk,
        --sample_count    =>

        baud_clk => baud_clk
    );

    sync_buffer_map :
    -- sync asynchronous rx signal
    sync_buffer port map(
        clk      => clk,
        data_in  => rx,
        data_out => rx_sync
    );

    oversampler_map :
    oversampler generic map(
        OVERSAMPLING => OVERSAMPLING
    )
    port map(
        clk   => clk,
        reset => oversampler_reset,

        rx => rx_sync,

        sample_clk => sample_clk,
        rx_sampled => rx_sampled
    );

    rx_fsm_map :
    rx_fsm port map(
        clk   => clk,
        reset => reset,

        rx                => rx_sync,
        oversampler_reset => oversampler_reset,
        rx_sampled        => rx_sampled,

        uart_clk_reset => uart_clk_reset,
        baud_clk       => baud_clk,

        rx_data             => rx_data,
        output_buffer_write => output_buffer_write
    );

end architecture structural;

-- uart_tx.vhdl
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_tx is
    generic (
        CLKS_PER_SAMPLE : integer;
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        write        : in std_logic;
        data_in      : in std_logic_vector (7 downto 0);
        buffer_empty : out std_logic;

        tx : out std_logic
    );
end entity uart_tx;
architecture structural of uart_tx is

    component uart_buffer is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            write : in std_logic;
            read  : in std_logic;

            data_in    : in std_logic_vector (7 downto 0);
            data_out   : out std_logic_vector (7 downto 0);
            data_ready : out std_logic
        );
    end component uart_buffer;

    component uart_clk is
        generic (
            CLKS_PER_SAMPLE : integer;
            OVERSAMPLING    : integer range 1 to 16
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;

            sample_clk   : out std_logic;
            sample_count : out std_logic_vector (3 downto 0);

            baud_clk : out std_logic
        );
    end component uart_clk;

    component tx_fsm is
        port (
            clk   : in std_logic;
            reset : in std_logic;

            tx : out std_logic;

            uart_clk_reset : out std_logic;
            baud_clk       : in std_logic;

            tx_buffer : in std_logic_vector (7 downto 0);

            input_buffer_empty : in std_logic;
            input_buffer_read  : out std_logic
        );
    end component tx_fsm;

    signal buffer_data_out                     : std_logic_vector (7 downto 0);
    signal buffer_data_read, buffer_data_ready : std_logic;
    signal buffer_data_empty                   : std_logic;

    signal uart_clk_reset, baud_clk : std_logic;

begin

    buffer_data_empty <= not buffer_data_ready;
    buffer_empty      <= buffer_data_empty;

    uart_buffer_map :
    uart_buffer port map(
        clk   => clk,
        reset => reset,

        write => write,
        read  => buffer_data_read,

        data_in    => data_in,
        data_out   => buffer_data_out,
        data_ready => buffer_data_ready
    );

    uart_clk_map :
    uart_clk generic map(
        CLKS_PER_SAMPLE => CLKS_PER_SAMPLE,
        OVERSAMPLING    => OVERSAMPLING
    )
    port map(
        clk   => clk,
        reset => uart_clk_reset,
        baud_clk => baud_clk
    );

    tx_fsm_map :
    tx_fsm port map(
        clk   => clk,
        reset => reset,

        tx => tx,

        uart_clk_reset => uart_clk_reset,
        baud_clk       => baud_clk,

        tx_buffer => buffer_data_out,

        input_buffer_empty => buffer_data_empty,
        input_buffer_read  => buffer_data_read
    );
end architecture structural;

-- uart_buffer.vhdl
--
-- generic uart buffer, for buffering rx-buf and tx-buf data
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_buffer is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        write : in std_logic;
        read  : in std_logic;

        data_in    : in std_logic_vector (7 downto 0);
        data_out   : out std_logic_vector (7 downto 0);
        data_ready : out std_logic
    );
end entity uart_buffer;

architecture behavioural of uart_buffer is

    signal data_buf, new_data_buf : std_logic_vector (7 downto 0);
    signal ready, new_ready       : std_logic;

begin

    reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_buf <= (others => '0');
                ready    <= '0';
            else
                data_buf <= new_data_buf;
                ready    <= new_ready;
            end if;
        end if;
    end process;

    comb : process (write, read, data_in, data_buf, ready)
    begin
        if write = '1' then
            new_data_buf <= data_in;
            new_ready    <= '1';
        elsif read = '1' then
            new_data_buf <= data_buf;
            new_ready    <= '0';
        else
            new_data_buf <= data_buf;
            new_ready    <= ready;
        end if;
    end process;

    data_out   <= data_buf;
    data_ready <= ready;

end architecture behavioural;

-- sync_buffer.vhdl
--
-- Synchronization buffer for RX signal
library IEEE;
use IEEE.std_logic_1164.all;

entity sync_buffer is
    port (
        clk      : in std_logic;
        data_in  : in std_logic;
        data_out : out std_logic
    );
end entity sync_buffer;

architecture behavioural of sync_buffer is

    signal data_buffered1, data_buffered2 : std_logic;

begin

    reg : process (clk)
    begin
        if (rising_edge (clk)) then
            data_buffered1 <= data_in;
            data_buffered2 <= data_buffered1;
        end if;
    end process;

    conc : data_out <= data_buffered2;

end architecture behavioural;

-- oversampler.vhdl
--
-- Oversamples input and returns majority value
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity oversampler is
    generic (
        OVERSAMPLING : integer range 1 to 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        rx : in std_logic;

        sample_clk : in std_logic;
        rx_sampled : out std_logic
    );
end entity oversampler;
architecture behavioural of oversampler is

    signal count, new_count : unsigned (3 downto 0);

begin

    reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= to_unsigned(0, count'length);
            else
                count <= new_count;
            end if;
        end if;
    end process;

    comb : process (count, rx, sample_clk)
    begin
        if count >= OVERSAMPLING/2 then
            rx_sampled <= '1';
        else
            rx_sampled <= '0';
        end if;

        if sample_clk = '1' and rx = '1' and count /= to_unsigned(OVERSAMPLING - 1, count'length) then
            new_count <= count + 1;
        else
            new_count <= count;
        end if;
    end process;

end architecture behavioural;

-- rx_fsm.vhdl
--
-- uart receiver
library IEEE;
use IEEE.std_logic_1164.all;

entity rx_fsm is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        rx                : in std_logic;
        oversampler_reset : out std_logic;
        rx_sampled        : in std_logic;

        uart_clk_reset : out std_logic;
        baud_clk       : in std_logic;

        rx_data             : out std_logic_vector (7 downto 0);
        output_buffer_write : out std_logic
    );
end entity rx_fsm;
architecture behavioural of rx_fsm is

    type state_type is (break_state, idle_state, start_state,
        store_state, next_bit_state, copy_data_state, stop_state);

    signal state, new_state       : state_type;
    signal data, new_data         : std_logic_vector (7 downto 0);
    signal bitcount, new_bitcount : integer range 0 to 7;

begin

    rx_data <= data;

    reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= idle_state;
                data     <= (others => '0');
                bitcount <= 0;
            else
                state    <= new_state;
                data     <= new_data;
                bitcount <= new_bitcount;
            end if;
        end if;
    end process;

    comb : process (state, bitcount, rx, baud_clk)
    begin
        case state is
            when break_state => -- break while rx=0 after reset
                oversampler_reset   <= '1';
                uart_clk_reset      <= '1';
                output_buffer_write <= '0';

                new_bitcount <= 0;
                new_data     <= (others => '0');

                if rx = '1' then
                    new_state <= idle_state;
                else
                    new_state <= break_state;
                end if;

            when idle_state => -- idle while rx=1
                oversampler_reset   <= '1';
                uart_clk_reset      <= '1';
                output_buffer_write <= '0';

                new_bitcount <= 0;
                new_data     <= (others => '0');

                if rx = '0' then
                    new_state <= start_state;
                else
                    new_state <= idle_state;
                end if;

            when start_state => -- start bit, wait for 1 baud period
                oversampler_reset   <= '0';
                uart_clk_reset      <= '0';
                output_buffer_write <= '0';

                new_bitcount <= 0;
                new_data     <= (others => '0');

                if baud_clk = '1' then
                    if rx_sampled = '0' then
                        new_state <= store_state;
                    else
                        new_state <= break_state;
                    end if;
                else
                    new_state <= start_state;
                end if;

            when store_state => -- store bit
                oversampler_reset   <= '0';
                uart_clk_reset      <= '0';
                output_buffer_write <= '0';

                new_bitcount <= bitcount;

                if baud_clk = '1' then
                    new_data  <= rx_sampled & data(7 downto 1);
                    new_state <= next_bit_state;
                else
                    new_data  <= data;
                    new_state <= store_state;
                end if;

            when next_bit_state => -- increment bit counter
                oversampler_reset   <= '1';
                uart_clk_reset      <= '0';
                output_buffer_write <= '0';

                new_data <= data;

                if bitcount = 7 then
                    new_bitcount <= 0;
                    new_state    <= copy_data_state;
                else
                    new_bitcount <= bitcount + 1;
                    new_state    <= store_state;
                end if;

            when copy_data_state => -- copy data to output buffer
                oversampler_reset   <= '0';
                uart_clk_reset      <= '0';
                output_buffer_write <= '1';

                new_bitcount <= 0;
                new_data     <= data;
                new_state    <= stop_state;

            when stop_state => -- wait for stop bit to pass
                oversampler_reset   <= '0';
                uart_clk_reset      <= '0';
                output_buffer_write <= '0';

                new_bitcount <= 0;
                new_data     <= data;

                if baud_clk = '1' then
                    new_state <= idle_state;
                else
                    new_state <= stop_state;
                end if;

        end case;
    end process;

end architecture behavioural;

-- tx_fsm.vhdl
--
-- TX fsm implementation
library IEEE;
use IEEE.std_logic_1164.all;

entity tx_fsm is
    port (
        clk   : in std_logic;
        reset : in std_logic;

        tx : out std_logic;

        uart_clk_reset : out std_logic;
        baud_clk       : in std_logic;

        tx_buffer : in std_logic_vector (7 downto 0);

        input_buffer_empty : in std_logic;
        input_buffer_read  : out std_logic
    );
end entity tx_fsm;

architecture behavioural of tx_fsm is

    type state_type is (idle_state, start_state,
        write_bit_state, next_bit_state, stop_state);

    signal state, new_state       : state_type;
    signal bitcount, new_bitcount : integer range 0 to 7;

begin

    reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= idle_state;
                bitcount <= 0;
            else
                state    <= new_state;
                bitcount <= new_bitcount;
            end if;
        end if;
    end process;

    comb : process (state, bitcount, baud_clk, tx_buffer, input_buffer_empty)
    begin
        case state is
            when idle_state =>
                tx                <= '1';
                uart_clk_reset    <= '1';
                input_buffer_read <= '0';

                new_bitcount <= 0;
                if input_buffer_empty = '0' then
                    new_state <= start_state;
                else
                    new_state <= idle_state;
                end if;

            when start_state =>
                tx                <= '0';
                uart_clk_reset    <= '0';
                input_buffer_read <= '1';

                new_bitcount <= 0;
                if baud_clk = '1' then
                    new_state <= write_bit_state;
                else
                    new_state <= start_state;
                end if;

            when write_bit_state =>
                tx                <= tx_buffer(bitcount);
                uart_clk_reset    <= '0';
                input_buffer_read <= '0';

                new_bitcount <= bitcount;
                if baud_clk = '1' then
                    new_state <= next_bit_state;
                else
                    new_state <= write_bit_state;
                end if;

            when next_bit_state =>
                tx                <= tx_buffer(bitcount);
                uart_clk_reset    <= '0';
                input_buffer_read <= '0';

                if bitcount = 7 then
                    new_bitcount <= 0;
                    new_state    <= stop_state;
                else
                    new_bitcount <= bitcount + 1;
                    new_state    <= write_bit_state;
                end if;

            when stop_state =>
                tx                <= '1';
                uart_clk_reset    <= '0';
                input_buffer_read <= '0';

                new_bitcount <= 0;
                if baud_clk = '1' then
                    new_state <= idle_state;
                else
                    new_state <= stop_state;
                end if;
        end case;
    end process;

end architecture behavioural;

-- uart_clk.vhdl
--
-- Generates oversampling and baudrate clocks
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_clk is
    generic (
        CLKS_PER_SAMPLE : integer; -- = BAUD_PERIOD/(CLK_PERIOD*OVERSAMPLING)
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        sample_clk   : out std_logic;
        sample_count : out std_logic_vector (3 downto 0);

        baud_clk : out std_logic
    );
end entity uart_clk;
architecture behavioural of uart_clk is

    signal clk_cnt, new_clk_cnt       : unsigned (15 downto 0);
    signal sample_cnt, new_sample_cnt : unsigned (3 downto 0);

begin

    reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_cnt    <= to_unsigned(0, clk_cnt'length);
                sample_cnt <= to_unsigned(0, sample_cnt'length);
            else
                clk_cnt    <= new_clk_cnt;
                sample_cnt <= new_sample_cnt;
            end if;
        end if;
    end process;

    comb : process (clk_cnt, sample_cnt)
    begin
        if clk_cnt = to_unsigned(CLKS_PER_SAMPLE - 1, clk_cnt'length) then
            new_clk_cnt <= to_unsigned(0, clk_cnt'length);
            sample_clk  <= '1';

            if sample_cnt = to_unsigned(OVERSAMPLING - 1, sample_cnt'length) then
                new_sample_cnt <= to_unsigned(0, sample_cnt'length);
                baud_clk       <= '1';
            else
                new_sample_cnt <= sample_cnt + 1;
                baud_clk       <= '0';
            end if;
        else
            new_clk_cnt    <= clk_cnt + 1;
            new_sample_cnt <= sample_cnt;
            sample_clk     <= '0';
            baud_clk       <= '0';
        end if;
    end process;

    sample_count <= std_logic_vector(sample_cnt);

end architecture behavioural;
