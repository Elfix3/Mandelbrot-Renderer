----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2026 14:50:34
-- Design Name: 
-- Module Name: level_converter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity level_converter is
    Generic(
        max_iter :integer := 64); --32 ,64 , 128
    Port(
        
        x : in integer range 0 to 128; --number of iterations
        level : out std_logic_vector(3 downto 0) --level between 0 and 15
    );
end level_converter;


architecture Behavioral of level_converter is
    
    type threshold_table is array (0 to 15) of integer;
    
    
    constant THRESHOLD_16  : threshold_table := (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15); 
    constant THRESHOLD_32  : threshold_table := (0,3,6,9,12,14,16,18,20,22,24,26,28,29,30,31); 
    --constant THRESHOLD_64 : threshold_table :=  (0,0,0,0,4,8,12,16,20,24,28,32,35,37,39,40);
    constant THRESHOLD_64 : threshold_table := (0,10,12,14,16,18,20,22,26,30,35,40,46,52,55,58);
    constant THRESHOLD_128 : threshold_table := (0,50,64,73,80,86,92,97,101,105,109,112,116,119,122,125);
    
    
    function sel_table(max_iter : integer) return threshold_table is
    begin
        if max_iter = 16 then
            return THRESHOLD_16;
        elsif    max_iter = 32 then
            return THRESHOLD_32;
        elsif max_iter = 64
            then return THRESHOLD_64;
        else 
            return THRESHOLD_128;
        end if;
    
    end function;
    
    
    constant THOLD : threshold_table := sel_table(max_iter);
    
    
begin
    level <= "1111" when x >= THOLD(15) else
         "1110" when x >= THOLD(14) else
         "1101" when x >= THOLD(13) else
         "1100" when x >= THOLD(12) else
         "1011" when x >= THOLD(11) else
         "1010" when x >= THOLD(10) else
         "1001" when x >= THOLD(9)  else
         "1000" when x >= THOLD(8)  else
         "0111" when x >= THOLD(7)  else
         "0110" when x >= THOLD(6)  else
         "0101" when x >= THOLD(5)  else
         "0100" when x >= THOLD(4)  else
         "0011" when x >= THOLD(3)  else
         "0010" when x >= THOLD(2)  else
         "0001" when x >= THOLD(1)  else
         "0000";

end Behavioral;
