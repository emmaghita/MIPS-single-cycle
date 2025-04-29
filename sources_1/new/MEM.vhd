library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( clk: in std_logic;
           alu_res: in std_logic_vector(15 downto 0);
           rd2_wd: in std_logic_vector(15 downto 0);
           memwrite: in std_logic;
           mem_data: out std_logic_vector(15 downto 0);
           alu_out: out std_logic_vector(15 downto 0));
end MEM;

architecture Behavioral of MEM is

type ram_type is array (0 to 65535) of std_logic_vector(15 downto 0);
signal ram: ram_type;

begin

--asynch read
mem_data <= ram(conv_integer(alu_res(7 downto 0)));

process(clk)
begin
    if rising_edge(clk) then
        if memwrite='1' then
            ram(conv_integer(alu_res(7 downto 0))) <= rd2_wd;
        end if;
    end if;
end process;

alu_out<=alu_res;

end Behavioral;
