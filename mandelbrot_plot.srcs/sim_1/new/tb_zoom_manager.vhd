----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2026 21:30:21
-- Design Name: 
-- Module Name: tb_zoom_manager - Behavioral
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

entity tb_zoom_manager is
end tb_zoom_manager;

architecture Behavioral of tb_zoom_manager is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal u : std_logic := '0';
    signal l : std_logic := '0';
    signal d : std_logic := '0';
    signal r : std_logic := '0';
    
    signal mode : std_logic := '0';


begin
    DUT : entity work.zoom_manager port map(
        clk => clk,
        rst => rst,
        u => u,
        l => l,
        d => d,
        r => r,
        mode => mode
    );
    clk <= not clk after 5ns;
    STIM : process begin
        wait for 50ns;
        u <= '1';
        wait for 50ns;
        u <= '0';
        
        wait for 6000000ns;
        d <= '1';
        wait for 12000000ns;
        
        
        wait for 20ns;
        wait;
    end process;

end Behavioral;
