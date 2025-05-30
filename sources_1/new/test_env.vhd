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
                                    wa: in std_logic_vector(2 downto 0);
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
signal wa_sig: std_logic_vector(2 downto 0);

--signals declared 
signal IF_ID_reg: std_logic_vector(31 downto 0);
signal ID_EX_reg: std_logic_vector(75 downto 0);
signal EX_MEM_reg: std_logic_vector(52 downto 0);
signal MEM_WB_reg: std_logic_vector(36 downto 0);

begin

op<=instr(15 downto 13);

mpg_map: MPG port map(clk=>clk, btn_enable=>btn_enable, btn_reset=>btn_reset, enable=>en, reset=>rst);

pcsrc_sig <= branch_sig and zero_sig;
jump_addr_sig <= pc_1(15 downto 13) & instr(12 downto 0);


IF_datapath_map: InstructionFetch
                port map(clk=>clk, 
                enable=>en, reset=>rst, branch_addr=>branch_addr_sig,
                         jump_addr=>jump_addr_sig, jmp_ctr=>jump_sig, pcsrc=>pcsrc_sig, instruction=>instr,
                         next_addr=>pc_1);
                         
                         
MCU_map: MCU
    port map(opcode=>op, regdst=>regdst_sig, extop=>extop_sig, alusrc=>alusrc_sig, branch=>branch_sig,
             jump=>jump_sig, aluop=>aluop_sig, memwrite=>memwrite_sig, memtoreg=>memtoreg_sig, regwrite=>regwrite_sig);


val_regwrite <= en and regwrite_sig;

val_memwrite <= en and memwrite_sig;

write_data_sig <= MEM_WB_reg(15 downto 0) when MEM_WB_reg(32) = '0' else MEM_WB_reg(31 downto 16);

if_id: process(clk)
begin
    if rising_edge(clk) then
        if en='1' then
            IF_ID_reg(31 downto 16) <= pc_1;
            IF_ID_reg(15 downto 0) <= instr;
        end if;
    end if;
end process;

wa_sig <= IF_ID_reg(9 downto 7) when regdst_sig = '0' else IF_ID_reg(6 downto 4);

ID_map: InstructionDecode
    port map(clk => clk,
             instruction => IF_ID_reg(15 downto 0),
             write_data => write_data_sig,
             regwrite => val_regwrite,
             regdst => regdst_sig,
             extop => extop_sig,
             wa => wa_sig,
             rd1 => rd1_sig,
             rd2 => rd2_sig,
             ext_imm => ext_imm_sig,
             func => func_sig,
             sha => sha_sig);

id_ex: process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            ID_EX_reg(75)           <= branch_sig;
            ID_EX_reg(74)           <= regwrite_sig;
            ID_EX_reg(73 downto 58) <= IF_ID_reg(31 downto 16);
            ID_EX_reg(57 downto 42) <= rd1_sig;
            ID_EX_reg(41 downto 26) <= rd2_sig;
            ID_EX_reg(25 downto 10) <= ext_imm_sig;
            ID_EX_reg(9 downto 7)   <= func_sig;
            ID_EX_reg(6)            <= sha_sig;
            ID_EX_reg(5 downto 3)   <= aluop_sig;
            ID_EX_reg(2)            <= alusrc_sig;
            ID_EX_reg(1)            <= memwrite_sig;
            ID_EX_reg(0)            <= memtoreg_sig;
        end if;
    end if;
end process;

                                   

EX_map: ExUnit port map(pc_plus1=>ID_EX_reg(73 downto 58), 
                        rd1=>ID_EX_reg(57 downto 42), 
                        rd2=>ID_EX_reg(41 downto 26), 
                        ext_imm=>ID_EX_reg(25 downto 10),
                        func=>ID_EX_reg(9 downto 7), 
                        alu_src=>ID_EX_reg(6), 
                        sha=>ID_EX_reg(2), 
                        alu_op=>ID_EX_reg(5 downto 3),
                        branch_address=>branch_addr_sig, 
                        alu_res=>alu_res_sig, 
                        zero=>zero_sig);
                        
ex_mem: process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            EX_MEM_reg(52)           <= ID_EX_reg(75);
            EX_MEM_reg(51)           <= ID_EX_reg(74);
            EX_MEM_reg(50)           <= ID_EX_reg(1);
            EX_MEM_reg(49)           <= ID_EX_reg(0);
            EX_MEM_reg(48 downto 33) <= branch_addr_sig;
            EX_MEM_reg(32 downto 17) <= alu_res_sig;
            EX_MEM_reg(16 downto 1)  <= ID_EX_reg(41 downto 26);
            EX_MEM_reg(0)            <= zero_sig;
        end if;
    end if;
end process;
                       
                        
mem_map: MEM port map(clk=>clk, 
                      alu_res=>EX_MEM_reg(32 downto 17), 
                      rd2_wd=>EX_MEM_reg(16 downto 1), 
                      memwrite=>val_memwrite,
                      mem_data=>read_data_sig,
                      alu_out=>alu_out_sig);

MEMWB: process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            MEM_WB_reg(33)           <= EX_MEM_reg(51);
            MEM_WB_reg(32)           <= EX_MEM_reg(49); 
            MEM_WB_reg(31 downto 16) <= read_data_sig;  
            MEM_WB_reg(15 downto 0)  <= EX_MEM_reg(32 downto 17);
            MEM_WB_reg(36 downto 34) <= wa_sig;
        end if;
    end if;
end process;

write_data_sig <= MEM_WB_reg(15 downto 0) when MEM_WB_reg(32) = '0' else MEM_WB_reg(31 downto 16);

                      
process(sw)
begin
    case sw(7 downto 5) is
        when "000" => digits <= IF_ID_reg(15 downto 0);  
        when "001" => digits <= IF_ID_reg(31 downto 16);
        when "010" => digits <= ID_EX_reg(57 downto 42); -- this is rd1_sig
        when "011" => digits <= ID_EX_reg(41 downto 26); -- this is rd2_sig
        when "110" => digits <= EX_MEM_reg(32 downto 17); -- this is alu_res_sig
        when "111" => digits <= MEM_WB_reg(31 downto 16); -- this is read_data_sig

        when others => digits <= (others => '0');
    end case;
end process;


ssd_map: SSD port map(clk=>clk, digit0=>digits(3 downto 0), digit1=>digits(7 downto 4),
                      digit2=>digits(11 downto 8), digit3=>digits(15 downto 12), cathode=>cat, anode=>an);

dp<='1';
                          
end Behavioral;
