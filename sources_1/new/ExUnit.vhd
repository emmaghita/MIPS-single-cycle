library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExUnit is
    Port (pc_plus1: in std_logic_vector(15 downto 0);
          rd1: in std_logic_vector(15 downto 0);
          rd2: in std_logic_vector(15 downto 0);
          ext_imm: in std_logic_vector(15 downto 0);
          func: in std_logic_vector(2 downto 0);
          alu_src: in std_logic;
          sha: in std_logic;
          alu_op: in std_logic_vector(2 downto 0);
          branch_address: out std_logic_vector(15 downto 0);
          alu_res: out std_logic_vector(15 downto 0);
          zero: out std_logic);
end ExUnit;

architecture Behavioral of ExUnit is

signal alu_ctrl: std_logic_vector(2 downto 0);
signal operand2: std_logic_vector(15 downto 0);
signal alu_res_sig: std_logic_vector(15 downto 0);

begin

branch_address <= pc_plus1+ext_imm;

process(alu_op, func)
begin
    case alu_op is
        when "000" => alu_ctrl <= "000"; --add
        when "001" => alu_ctrl <= "001"; --sub
        when "010" => alu_ctrl <= "010"; --or
        when "011" => alu_ctrl <= "011"; --and
        when "111" =>
            case func is
                when "000" => alu_ctrl <= "000"; --add
                when "001" => alu_ctrl <= "001"; --sub
                when "010" => alu_ctrl <= "100"; --sll
                when "011" => alu_ctrl <= "101"; --srl
                when "100" => alu_ctrl <= "011"; --and
                when "101" => alu_ctrl <= "010"; --or
                when "110" => alu_ctrl <= "110"; --xor
                when "111" => alu_ctrl <= "111"; --sra
            end case;
        when others => alu_ctrl <= "000";
    end case;
end process;

operand2 <= rd2 when alu_src='0' else ext_imm;

process(rd1, operand2, sha, alu_ctrl)
begin
    case alu_ctrl is
        when "000" => alu_res_sig <= rd1+operand2;
        when "001" => alu_res_sig <= rd1-operand2;
        when "010" => alu_res_sig <= rd1 or operand2;
        when "011" => alu_res_sig <= rd1 and operand2;
        when "100" => 
            if sha='1' then alu_res_sig <= rd2(14 downto 0) & '0';
            else alu_res_sig<=rd2;
            end if;
        when "101" =>
            if sha='1' then alu_res_sig <= '0'&rd2(15 downto 1);
            else alu_res_sig<=rd2;
            end if;
        when "110" => alu_res_sig <= rd1 xor operand2;
        when "111" => 
            if sha='1' then alu_res_sig <= rd2(15) & rd2(15 downto 1);
            else alu_res_sig<=rd2;
            end if;
        when others => alu_res_sig <= (others => '0');
     end case;
end process;  
          
zero <= '1' when alu_res_sig=x"0000" else '0';
alu_res<=alu_res_sig;

end Behavioral;
