library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionDecode is
    Port ( clk: in std_logic;
           instruction: in std_logic_vector(15 downto 0);
           write_data: in std_logic_vector(15 downto 0);
           regwrite: in std_logic;
           regdst: in std_logic;
           extop: in std_logic;
           wa: in std_logic_vector(2 downto 0);
           rd1: out std_logic_vector(15 downto 0); --rs
           rd2: out std_logic_vector(15 downto 0); --rt
           ext_imm: out std_logic_vector(15 downto 0);
           func: out std_logic_vector(2 downto 0);
           sha: out std_logic
           );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg: reg_array := (others => (others => '0'));

signal ra1_rs: std_logic_vector(2 downto 0);
signal ra2_rt: std_logic_vector(2 downto 0);
signal rd: std_logic_vector(2 downto 0);

signal imm: std_logic_vector(6 downto 0);

begin

ra1_rs <= instruction(12 downto 10);
ra2_rt <= instruction(9 downto 7);
rd <= instruction(6 downto 4);

imm <= instruction(6 downto 0);

regfile: process(clk)
begin
    if rising_edge(clk) then
        if regwrite='1' then
            reg(conv_integer(wa))<=write_data;
        end if;
    end if;
end process regfile;

rd1 <= reg(conv_integer(ra1_rs));
rd2 <= reg(conv_integer(ra2_rt));

ext_imm <= "000000000"&imm when extop='0' else (15 downto 7 => imm(6))&imm; 

func <= instruction(2 downto 0);
sha <= instruction(3);

end Behavioral;
