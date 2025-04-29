library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RegFile is
    Port ( clk: in std_logic;
           ra1: in std_logic_vector(3 downto 0);
           ra2: in std_logic_vector(3 downto 0);
           wa: in std_logic_vector(3 downto 0);
           wd: in std_logic_vector(15 downto 0);
           wen: in std_logic;
           rd1: out std_logic_vector(15 downto 0);
           rd2: out std_logic_vector(15 downto 0));
end RegFile;

architecture Behavioral of RegFile is

type reg_array is array (0 to 15) of std_logic_vector(15 downto 0);
signal reg: reg_array:=(0 => x"0001", 1 => x"0002", 2 => x"0003", 3 => x"0004",
                        4 => x"0005", 5 => x"0006", 6 => x"0007", 7 => x"0008",
                        others => (others => '0'));

begin
process(clk)
begin
    if rising_edge(clk) then
        if wen='1' then
            reg(conv_integer(wa))<=wd;
        end if;
    end if;
end process;

rd1 <= reg(conv_integer(ra1));
rd2 <= reg(conv_integer(ra2));

end Behavioral;
