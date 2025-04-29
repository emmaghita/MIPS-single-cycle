library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SSD is
    Port ( clk: in std_logic;
           digit0: in std_logic_vector(3 downto 0); --4 lsbs
           digit1: in std_logic_vector(3 downto 0);
           digit2: in std_logic_vector(3 downto 0);
           digit3: in std_logic_vector(3 downto 0); --4 msbs
           cathode: out std_logic_vector(6 downto 0);
           anode: out std_logic_vector(3 downto 0));
end SSD;

architecture Behavioral of SSD is

signal count: std_logic_vector(15 downto 0):=x"0000";
signal out1: std_logic_vector(3 downto 0);

begin

counter: process(clk)
begin
    if rising_edge(clk) then
        count<=count+1;
    end if;
end process counter;

mux1: process(digit0, digit1, digit2, digit3, count)
begin
case count(15 downto 14) is
    when "00" => out1 <= digit0;
    when "01" => out1 <= digit1;
    when "10" => out1 <= digit2;
    when "11" => out1 <= digit3;
end case;
end process mux1;

mux2: process(count)
begin
case count(15 downto 14) is
    when "00" => anode <= "1110";
    when "01" => anode <= "1101";
    when "10" => anode <= "1011";
    when "11" => anode <= "0111";
end case;
end process mux2;

hex_dcd: process(out1)
begin
case out1 is --on 4 bits
    when "0001" => cathode <= "1111001"; --1
    when "0010" => cathode <= "0100100"; --2
    when "0011" => cathode <= "0110000"; --3
    when "0100" => cathode <= "0011001"; --4
    when "0101" => cathode <= "0010010"; --5   
    when "0110" => cathode <= "0000010"; --6
    when "0111" => cathode <= "1111000"; --7
    when "1000" => cathode <= "0000000"; --8
    when "1001" => cathode <= "0010000"; --9
    when "1010" => cathode <= "0001000"; --A=10
    when "1011" => cathode <= "0000011"; --b=11
    when "1100" => cathode <= "1000110"; --C=12
    when "1101" => cathode <= "0100001"; --d=13
    when "1110" => cathode <= "0000110"; --E=14
    when "1111" => cathode <= "0001110"; --F=15
    when others => cathode <= "1000000"; --0
end case;
end process hex_dcd;

end Behavioral;
