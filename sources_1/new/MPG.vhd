library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port (
        clk        : in std_logic;
        btn_enable : in std_logic;
        btn_reset  : in std_logic;
        enable     : out std_logic;
        reset      : out std_logic
    );
end MPG;

architecture Behavioral of MPG is

    signal cnt_en  : std_logic_vector(15 downto 0) := x"0000";
    signal cnt_rst : std_logic_vector(15 downto 0) := x"0000";

    signal en_dff1  : std_logic;
    signal rst_dff1 : std_logic;

    signal d1_en, d2_en, d3_en : std_logic;
    signal d1_rst, d2_rst, d3_rst : std_logic;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            cnt_en <= cnt_en + 1;
        end if;
    end process;

    en_dff1 <= '1' when cnt_en = x"FFFF" else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            cnt_rst <= cnt_rst + 1;
        end if;
    end process;

    rst_dff1 <= '1' when cnt_rst = x"FFFF" else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if en_dff1 = '1' then
                d1_en <= btn_enable;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            d2_en <= d1_en;
            d3_en <= d2_en;
        end if;
    end process;

    enable <= d2_en and not d3_en;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst_dff1 = '1' then
                d1_rst <= btn_reset;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            d2_rst <= d1_rst;
            d3_rst <= d2_rst;
        end if;
    end process;

    reset <= d2_rst and not d3_rst;

end Behavioral;
