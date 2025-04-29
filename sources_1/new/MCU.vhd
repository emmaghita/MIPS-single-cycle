library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

entity MCU is
    Port (opcode: in std_logic_vector(2 downto 0);
          regdst: out std_logic;
          extop: out std_logic;
          alusrc: out std_logic;
          branch: out std_logic;
          jump: out std_logic;
          aluop: out std_logic_vector(2 downto 0);
          memwrite: out std_logic;
          memtoreg: out std_logic;
          regwrite: out std_logic);
end MCU;

architecture Behavioral of MCU is

begin

decode: process(opcode)
begin
    --default
    regdst<='0';
    extop<='0';
    alusrc<='0';
    branch<='0';
    jump<='0';
    aluop<="000";
    memwrite<='0';
    memtoreg<='0';
    regwrite<='0';
    
    case opcode is
        when "000" => --R type instructions
            regdst<='1';
            regwrite<='1';
            aluop<="111";
        when "001" => --addi
            alusrc<='1';
            extop<='1';
            regwrite<='1';
            aluop<="000"; --adding
         when "010" => --lw
            extop<='1';
            alusrc<='1';
            memtoreg<='1';
            regwrite<='1';
            aluop<="000"; --adding
         when "011" => --sw
            extop<='1';
            alusrc<='1';
            memwrite<='1';
            aluop<="000"; --adding
         when "100" => --beq
            extop<='1';
            branch<='1';
            aluop<="001"; --subtract
         when "101" => --andi
            extop<='0';
            alusrc<='1';
            regwrite<='1';
            aluop<="011"; --and
         when "110" => --ori
            extop<='0';
            alusrc<='1';
            regwrite<='1';
            aluop<="010";
         when "111" => --j
            jump<='1';
         when others => 
            null;
end case;
         
end process decode;

end Behavioral;
