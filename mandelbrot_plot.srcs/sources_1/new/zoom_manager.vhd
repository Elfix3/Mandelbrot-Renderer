----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2026 22:04:28
-- Design Name: 
-- Module Name: zoom_manager - Behavioral
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

entity zoom_manager is
    Port(
        clk : in std_logic;
        rst : in std_logic;
        
        --buttons
        u : in std_logic;
        l : in std_logic;
        r : in std_logic;
        d : in std_logic;
        
        --zoom mode or translation mode
        mode : in std_logic;
        
        --coordinates of the center
        xOut : out signed(15 downto 0);         --vga starts with xMin
        yOut : out signed(15 downto 0);         --vga starts with yMax

        --steps
        stepOut : out signed(15 downto 0);
    
        --frame update signal
        frame_update : out std_logic             --tells the frame processing unit to refresh
    );
end zoom_manager;

architecture Behavioral of zoom_manager is

    
    --position of the computed frame
    signal xMin : signed(15 downto 0)   := x"c000";     --          -2.0 
    signal yMin : signed(15 downto 0)   := x"d928";     --          -1.2138671875
    signal xMax : signed(15 downto 0)   := x"23d8";     --          1.1201171875
    signal yMax : signed(15 downto 0)   := x"2400";     --          1.125
    
    signal step : signed(15 downto 0)   := x"0028"; -- step of 0.0048828125 (adapted for VGA 640*480)
    
    
    constant Q3_13_LOWER_BOUND : signed(15 downto 0) := x"8000"; --     -4
    constant Q3_13_UPPER_BOUND : signed(15 downto 0) := x"7fff"; --     3.9998779296875

    
    --stable buttons
    signal stable_u : std_logic := '0';
    signal stable_l : std_logic := '0';
    signal stable_d : std_logic := '0';
    signal stable_r : std_logic := '0';

    --previous buttons
    signal previous_u : std_logic := '0';
    signal previous_l : std_logic := '0';
    signal previous_d : std_logic := '0';
    signal previous_r : std_logic := '0';
    
    --zoom on rising edge of stable
    signal previous_stable_u : std_logic := '0';
    signal previous_stable_d : std_logic := '0';
    
    --translation
    signal translation_counter : unsigned(19 downto 0) := (others => '0'); --2 second of press is one unit in the plan
    
    --dbounce count
    signal count_u : unsigned(19 downto 0) := (others => '0');
    signal count_l : unsigned(19 downto 0) := (others => '0');
    signal count_d : unsigned(19 downto 0) := (others => '0');
    signal count_r : unsigned(19 downto 0) := (others => '0');
    
begin
    
    xOut <= xMin;
    yOut <= yMax;
    stepOut <= step;
    
    
    process(clk) begin 
        if rising_edge(clk) then
            frame_update <= '0';
        
            if rst = '1' then
                xMin <= x"c000";     --             -2.0
                yMin <= x"d928";     --             -1.2138671875
                xMax <= x"23d8";     --             1.1201171875
                Ymax <= x"2400";     --             1.125
                step <= x"0028";     -- step of 0.0048828125 (adapted for VGA 640*480)
                frame_update <= '1';
            
            else
            
                case mode is
                    --zoom mode
                    
                    --NOT FUNCTIONNAL YET
                    --UNDER CONSTRUCTION
                    
                    when '1' =>
                        --zoom in
                        if stable_u = '1' and previous_stable_u = '0' then
                            step <= shift_right(step,1);
                            yMax <= yMax - shift_right(yMax-yMin,2);
                            yMin <= yMin + shift_right(yMax-yMin,2);
                            
                            xMax <= xMax - shift_right(xMax-xMin,2);
                            xMin <= xMin + shift_right(xMax-xMin,2);
                            
                            frame_update <= '1';
                        
                        elsif stable_d = '1' and previous_stable_d = '0' then
                            step <= shift_left(step,1);
                            
                            yMax <= yMax + shift_right(yMax-yMin,1);
                            yMin <= yMin - shift_right(yMax-yMin,1);

                            xMax <= xMax + shift_right(xMax-xMin,1);
                            xMin <= xMin - shift_right(xMax-xMin,1);
                            
                            frame_update <= '1';
                        end if;
                        
                        
                        
                    --translation mode
                    when others =>
                        --moving up
                        if stable_u = '1' then
                            if translation_counter = x"ee2f0" then
                                --overflow detection
                                if (ymax < 0) or (ymax + step >= 0) then
                                    ymax <= ymax + step;
                                    ymin <= ymin + step;                                    
                                    frame_update <= '1';
                                end if;
                                
                                translation_counter <= (others => '0');
                            else
                                translation_counter <= translation_counter + 1;
                        end if; 
                                     
                        --moving left
                        elsif stable_l = '1' then
                            if translation_counter = x"ee2f0" then --ee2f0
                                --overflow detection
                                if (xmin > 0) or (xmin - step <= 0) then
                                    xmax <= xmax - step;
                                    xmin <= xmin - step;
                                    frame_update <= '1';
                                end if;
                                
                                translation_counter <= (others => '0');
                            else
                                translation_counter <= translation_counter + 1;
                        end if;
                        
                        --moving down
                        elsif stable_d = '1' then
                            if translation_counter = x"ee2f0" then
                                 --overflow detection
                                if (ymin > 0) or (ymin - step <= 0) then
                                    ymax <= ymax - step;
                                    ymin <= ymin - step;
                                    frame_update <= '1';
                                end if;
                                                               
                                translation_counter <= (others => '0');
                            else
                                translation_counter <= translation_counter + 1;
                        end if;
                        
                        
                        --moving right                        
                        elsif stable_r = '1' then
                            if translation_counter = x"ee2f0" then
                                --overflow detection
                                if (xmax < 0) or (xmax + step >= 0) then
                                    xmax <= xmax + step;
                                    xmin <= xmin + step;
                                    frame_update <= '1';
                                end if;
                                
                                translation_counter <= (others => '0');
                            else
                                translation_counter <= translation_counter + 1;
                            end if;
                        end if;
                
                end case;
                
                --for zoom
                previous_stable_u <= stable_u;
                previous_stable_d <= stable_d;
            
            
            end if;
            
        end if;  
    
    end process;
    
    --rework dbounce logic
    
    
    --Dbounce Up
    process(clk) begin
        if rising_edge(clk) then
            if u /= previous_u then
                count_u <= (others => '0');
            elsif count_u(19) = '1' then
                stable_u <= u;
            else
                count_u <= count_u + 1;
            end if;
            previous_u <= u;
        end if;
    end process;
    
    --Dbounce Left
    process(clk) begin
        if rising_edge(clk) then
            if l /= previous_l then
                count_l <= (others => '0');
            elsif count_l(19) = '1' then
                stable_l <= l;
            else
                count_l <= count_l + 1;
            end if;
            previous_l <= l;
        end if;
    end process;
    
    
    --Dbounce Down
    process(clk) begin
        if rising_edge(clk) then
            if d /= previous_d then
                count_d <= (others => '0');
            elsif count_d(19) = '1' then
                stable_d <= d;
            else
                count_d <= count_d + 1;
            end if;
            previous_d <= d;
        end if;
    end process;
        
    
    --Dbounce Right
    process(clk) begin
        if rising_edge(clk) then
            if r /= previous_r then
                count_r <= (others => '0');
            elsif count_r(19) = '1' then
                stable_r <= r;
            else
                count_r <= count_r + 1;
            end if;
            previous_r <= r;
        end if;
    end process;
    
end Behavioral;