----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2026 21:19:39
-- Design Name: 
-- Module Name: tb_calculator - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_calculator is
end tb_calculator;

architecture Behavioral of tb_calculator is
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal start : std_logic := '0';
    
    signal a : signed(15 downto 0) := (others => '0');
    signal b : signed(15 downto 0) := (others => '0');
    
    signal done : std_logic := '0';
    signal n_iter : integer := 0;
    
begin

    DUT : entity work.calculator generic map(n_itermax => 64)
    port map(
        clk => clk,
        rst => rst,
        start => start,
        a => a,
        b => b,
        done => done,
        n_iter => n_iter
    );
    
    clk <= not clk after 5ns;
    
    STIM : process begin
        rst <= '1';
        wait for 20ns;
        
        rst <= '0';
        wait for 50ns;
        
        a <= x"e3b1"; --divergence un peu lente
        b <= x"0ec1";
        start <= '1';
        wait for 10ns;
        
        --start <= '0';
        wait for 200ns;
        
        
        
        a <= x"fd3a"; --convergence
        b <= x"0809";
        --start <= '1';
        wait for 10ns;
        
        --start <= '0';
        wait for 2000ns;
        
        
        a <= x"c000"; --divergence très rapide
        b <= x"4000";
        --start <= '1';
        wait for 10ns;
        
        --start <= '0';
        wait for 200ns;
        
        
        
        wait;
    end process;
    
    
end Behavioral;
