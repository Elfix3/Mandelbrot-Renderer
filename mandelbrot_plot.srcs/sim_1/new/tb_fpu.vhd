----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2026 19:37:33
-- Design Name: 
-- Module Name: tb_fpu - Behavioral
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

entity tb_fpu is
end tb_fpu;

architecture Behavioral of tb_fpu is
    signal clk : std_logic := '0';
    signal rst :std_logic := '0';
    signal frame_update : std_logic := '0';
    
    signal xCorr : signed(15 downto 0) := x"c000";
    signal yCorr : signed(15 downto 0) := x"2400"; 
    signal step : signed(15 downto 0) :=  x"0028";
    
begin
    DUT : entity work.frame_processing_unit generic map(W => 640, H => 480, n_itermax => 64)
    port map(
        clk => clk,
        rst => rst,
        frame_update => frame_update,
        xCorr => xCorr,
        yCorr => yCorr,
        step => step
            
    );
    clk <= not clk after 5ns;
    STIM : process begin
--        rst <= '1';
--        wait for 20ns;
--        rst <= '0';
--        wait for 70 ms;
        
--        rst <= '1';
--        wait for 20ns;
--        rst <= '0';
        
        wait;
    end process;
    
end Behavioral;
