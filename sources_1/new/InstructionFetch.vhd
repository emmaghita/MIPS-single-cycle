library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InstructionFetch is
    Port ( clk: in std_logic;
           enable: in std_logic;
           reset: in std_logic; 
           branch_addr: in std_logic_vector(15 downto 0);
           jump_addr: in std_logic_vector(15 downto 0);
           jmp_ctr: in std_logic;
           pcsrc: in std_logic;
           instruction: out std_logic_vector(15 downto 0);
           next_addr: out std_logic_vector(15 downto 0)); --si asta
end InstructionFetch;

architecture Behavioral of InstructionFetch is

signal pc: std_logic_vector(15 downto 0);
signal pc_plus1: std_logic_vector(15 downto 0);
signal mux_pcsrc: std_logic_vector(15 downto 0);
signal mux_jmp: std_logic_vector(15 downto 0);
signal rom_out: std_logic_vector(15 downto 0);

type rom_array is array (0 to 255) of std_logic_vector(15 downto 0);
signal rom: rom_array :=( 0 => x"11A0", --add $2, $4, $3
                          1 => x"11A1", --sub $5, $4, $3
                          2 => x"11AA", --sll $1, $3, 4
                          3 => x"171B", --srl $4, $6, 5: 000_1 01_11 0_001_ 0_011
                          4 => x"07E4", --and $6, $1, $7: 000_0 01_11 1_110 _0_100
                          5 => x"1635", --or $3, $5, $4: 000_1 01_10 0_011 _0_101
                          6 => x"1D16", --xor $7, $2, $1: 000_1 11_01 0_001_ 0_110
                          7 => x"0F97", --sra  000_0 11_11 1_001_ 0_111
                          
                          8 => x"2185", --addi $3, $0, 5: 001_0 00_01 1_000 0101
                          9 => x"4506", --lw $2, 6($1): 010_0 01_01 0_000 0110
                          10 => x"7602", --sw $4, 2($5): 011_1 01_10 0_000 0010
                          11 => x"8985", --beq $2, $3, 5: 100_0 10_01 1_000 0101
                          12 => x"B486", --andi $1, $5, 6: 101_1 01_00 1_000 0110
                          13 => x"DE05", --ori $4,  $7, 5: 110_1 11_10 0_000 0101
                          
                          14 => x"E005",--j 5: 111_0 0000 0000 0101
                          others => x"0000"); 
   

begin

--adder
pc_plus1 <= pc+1;
next_addr <= pc_plus1;

--mux1
mux1: process(pcsrc, pc_plus1, branch_addr)
begin
case pcsrc is
    when '0' => mux_pcsrc <= pc_plus1;
    when '1' => mux_pcsrc <= branch_addr;
end case;
end process mux1;

--mux2
mux2: process(jmp_ctr)
begin
case jmp_ctr is
    when '0' => mux_jmp <= mux_pcsrc;
    when '1' => mux_jmp <= jump_addr;
end case;
end process mux2;

--dff edge trig
dff: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            pc <= (others => '0');
        elsif enable ='1' then 
            pc <= mux_jmp;
        end if;
    end if;
end process dff;

rom_out <= rom(conv_integer(pc(7 downto 0)));
instruction <= rom_out;

end Behavioral;
