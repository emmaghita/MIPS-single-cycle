library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk: in std_logic;
           btn_enable: in std_logic;
           btn_reset: in std_logic;
           sw: in std_logic_vector(7 downto 0);
           led: out std_logic_vector(7 downto 0);
           dp: out std_logic;
           an: out std_logic_vector(3 downto 0);
           cat: out std_logic_vector(6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is port( clk: in std_logic;
                       btn_enable: in std_logic;
                       btn_reset: in std_logic;
                       enable: out std_logic;
                       reset: out std_logic);
end component MPG;

component SSD is port( clk: in std_logic;
                       digit0: in std_logic_vector(3 downto 0); --4 lsbs
                       digit1: in std_logic_vector(3 downto 0);
                       digit2: in std_logic_vector(3 downto 0);
                       digit3: in std_logic_vector(3 downto 0); --4 msbs
                       cathode: out std_logic_vector(6 downto 0);
                       anode: out std_logic_vector(3 downto 0));
end component SSD;

component InstructionFetch is port(clk: in std_logic;
                                   enable: in std_logic;
                                   reset: in std_logic; 
                                   branch_addr: in std_logic_vector(15 downto 0);
                                   jump_addr: in std_logic_vector(15 downto 0);
                                   jmp_ctr: in std_logic;
                                   pcsrc: in std_logic;
                                   instruction: out std_logic_vector(15 downto 0);
                                   next_addr: out std_logic_vector(15 downto 0));
end component InstructionFetch;
                               
component InstructionDecode is port(clk: in std_logic;
                                    instruction: in std_logic_vector(15 downto 0);
                                    write_data: in std_logic_vector(15 downto 0);
                                    regwrite: in std_logic;
                                    regdst: in std_logic;
                                    extop: in std_logic;
                                    rd1: out std_logic_vector(15 downto 0); --rs
                                    rd2: out std_logic_vector(15 downto 0); --rt
                                    ext_imm: out std_logic_vector(15 downto 0);
                                    func: out std_logic_vector(2 downto 0);
                                    sha: out std_logic);  
end component InstructionDecode;

component MCU is port(opcode: in std_logic_vector(2 downto 0);
                      regdst: out std_logic;
                      extop: out std_logic;
                      alusrc: out std_logic;
                      branch: out std_logic;
                      jump: out std_logic;
                      aluop: out std_logic_vector(2 downto 0);
                      memwrite: out std_logic;
                      memtoreg: out std_logic;
                      regwrite: out std_logic);                                                                
end component MCU; 

component ExUnit is port(pc_plus1: in std_logic_vector(15 downto 0);
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
end component ExUnit;

component MEM is port(clk: in std_logic;
                      alu_res: in std_logic_vector(15 downto 0);
                      rd2_wd: in std_logic_vector(15 downto 0);
                      memwrite: in std_logic;
                      mem_data: out std_logic_vector(15 downto 0);
                      alu_out: out std_logic_vector(15 downto 0));
end component MEM;                    
                    
  
--mcu signal
signal regdst_sig, extop_sig, alusrc_sig, branch_sig, jump_sig, memwrite_sig, memtoreg_sig, regwrite_sig: std_logic;
signal aluop_sig: std_logic_vector(2 downto 0);      
signal pcsrc_sig, zero_sig: std_logic;                
                                  
--signal count: std_logic_vector(7 downto 0):=x"0000";
signal en: std_logic;
signal rst: std_logic;
signal digits: std_logic_vector(15 downto 0);
signal instr: std_logic_vector(15 downto 0); 
signal pc_1: std_logic_vector(15 downto 0);
signal branch_addr_sig: std_logic_vector(15 downto 0);
signal jump_addr_sig: std_logic_vector(15 downto 0);

signal op: std_logic_vector(2 downto 0);

signal rd1_sig, rd2_sig, ext_imm_sig : std_logic_vector(15 downto 0);
signal func_sig : std_logic_vector(2 downto 0);
signal sha_sig  : std_logic;
signal write_data_sig : std_logic_vector(15 downto 0);
signal read_data_sig: std_logic_vector(15 downto 0);                
signal val_regwrite, val_memwrite: std_logic;   
signal led_signal: std_logic_vector(7 downto 0); 
signal alu_res_sig: std_logic_vector(15 downto 0);        
signal alu_out_sig: std_logic_vector(15 downto 0);     
begin

op<=instr(15 downto 13);

mpg_map: MPG port map(clk=>clk, btn_enable=>btn_enable, btn_reset=>btn_reset, enable=>en, reset=>rst);

pcsrc_sig <= branch_sig and zero_sig;
jump_addr_sig <= pc_1(15 downto 13) & instr(12 downto 0);


IF_datapath_map: InstructionFetch
                port map(clk=>clk, enable=>en, reset=>rst, branch_addr=>branch_addr_sig,
                         jump_addr=>jump_addr_sig, jmp_ctr=>jump_sig, pcsrc=>pcsrc_sig, instruction=>instr,
                         next_addr=>pc_1);
                         
                         
MCU_map: MCU
    port map(opcode=>op, regdst=>regdst_sig, extop=>extop_sig, alusrc=>alusrc_sig, branch=>branch_sig,
             jump=>jump_sig, aluop=>aluop_sig, memwrite=>memwrite_sig, memtoreg=>memtoreg_sig, regwrite=>regwrite_sig);


val_regwrite <= en and regwrite_sig;

val_memwrite <= en and memwrite_sig;

write_data_sig <= alu_res_sig when memtoreg_sig='0' else read_data_sig;

ID_map: InstructionDecode
        port map(clk=>clk, instruction=>instr, write_data=>write_data_sig, regwrite=>val_regwrite,
                 regdst=>regdst_sig, extop=>extop_sig, rd1=>rd1_sig, rd2=>rd2_sig, ext_imm=>ext_imm_sig,
                 func=>func_sig, sha=>sha_sig);

EX_map: ExUnit port map(pc_plus1=>pc_1, rd1=>rd1_sig, rd2=>rd2_sig, ext_imm=>ext_imm_sig,
                        func=>func_sig, alu_src=>alusrc_sig, sha=>sha_sig, alu_op=>aluop_sig,
                        branch_address=>branch_addr_sig, alu_res=>alu_res_sig, zero=>zero_sig);
                        
mem_map: MEM port map(clk=>clk, alu_res=>alu_res_sig, rd2_wd=>rd2_sig, memwrite=>val_memwrite,
                      mem_data=>read_data_sig, alu_out=>alu_out_sig);
                      
process(sw)
begin
    case sw(7 downto 5) is
        when "000" => digits <= instr;
        when "001" => digits <= pc_1;
        when "010" => digits <= rd1_sig;
        when "011" => digits <= rd2_sig;   
        when others => digits <= (others=>'0');  
     end case;                          
end process;  

ssd_map: SSD port map(clk=>clk, digit0=>digits(3 downto 0), digit1=>digits(7 downto 4),
                      digit2=>digits(11 downto 8), digit3=>digits(15 downto 12), cathode=>cat, anode=>an);

dp<='1';
                          
end Behavioral;
