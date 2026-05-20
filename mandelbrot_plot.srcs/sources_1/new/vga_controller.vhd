----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2026 10:37:01
-- Design Name: 
-- Module Name: vga_controler - Behavioral
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

entity vga_controller is
  Port (
  
    --Clk 25MHz
    clk_25MHz : in std_logic;

    --Rst
    rst : in std_logic;

    --write Pixel
    pixelData : in std_logic_vector(3 downto 0); --mapped to VGA colors

    --adressNext Pixel
    addrPixel : out std_logic_vector(18 downto 0);

    --Color canals
    vgaRed : out std_logic_vector(3 downto 0);
    vgaGreen : out std_logic_vector(3 downto 0);
    vgaBlue : out std_logic_vector(3 downto 0);
    
    --Sync signals
    Hsync : out std_logic;
    Vsync : out std_logic
  );
end vga_controller;

    
architecture Behavioral of vga_controller is
    
    --Horizontal
    constant H_Active : integer := 640;
    constant H_Front : integer := 16;
    constant H_Pulse: integer := 96;
    constant H_Back : integer := 48;
     
    constant H_Total : integer := H_Active + H_Front + H_Pulse + H_Back;
    
    
    --Vertical
    constant V_Active : integer := 480;
    constant V_Front : integer := 11;
    constant V_Pulse: integer := 2;
    constant V_Back : integer := 31;
     
    constant V_Total : integer := V_Active + V_Front + V_Pulse + V_Back;
    

    --internal counters    
    signal H_Count : integer range 0 to H_Total; 
    signal V_Count : integer range 0 to V_Total; 
    
    signal Display_Active : std_logic;
    signal addr : unsigned(18 downto 0) := (others => '0');
    signal incrAddr : std_logic;
    
    
    --calculated Colors
    signal redCalc : std_logic_vector(3 downto 0) := (others => '0');
    signal greenCalc : std_logic_vector(3 downto 0) := (others => '0');
    signal blueCalc : std_logic_vector(3 downto 0) := (others => '0');
begin

    addrPixel <= std_logic_vector(addr);
    
    Display_Active <= '1' when (H_Count<H_Active) and (V_Count<V_Active)
    else '0';
    
    Hsync <= '0' when (H_Count >= H_Active + H_Front) and (H_Count < H_Active + H_Front + H_Pulse)
    else '1';
    
    Vsync <= '0' when (V_Count >= V_Active + V_Front) and (V_Count < V_Active + V_Front + V_Pulse)
    else '1';
    
    
    --Red display, RGB color should come from BRAM (4 bits) -> mapping RGB for VGA
    vgaRed <= redCalc when Display_Active = '1'     else  "0000";
    vgaGreen <= greenCalc when Display_Active = '1' else  "0000";
    vgaBlue <= blueCalc when Display_Active = '1'   else  "0000";


    --COLOR MAPPING
    
    with pixelData select redCalc <=
        "0000" when "0000",
        "0000" when "0001",
        "0000" when "0010",
        "0000" when "0011",
        "0000" when "0100",
        "0000" when "0101",
        "0100" when "0110",
        "1000" when "0111",
        "1111" when "1000",
        "1111" when "1001",
        "1111" when "1010",
        "1111" when "1011",
        "1111" when "1100",
        "1010" when "1101",
        "0100" when "1110",
        "0000" when others;

    with pixelData select greenCalc <=
        "0000" when "0000",
        "0100" when "0001",
        "1000" when "0010",
        "1111" when "0011",
        "1111" when "0100",
        "1111" when "0101",
        "1111" when "0110",
        "1111" when "0111",
        "1111" when "1000",
        "1100" when "1001",
        "1000" when "1010",
        "0100" when "1011",
        "0000" when "1100",
        "0000" when "1101",
        "0000" when "1110",
        "0000" when others;
    
    with pixelData select blueCalc <=
        "1111" when "0000",
        "1111" when "0001",
        "1111" when "0010",
        "1111" when "0011",
        "1000" when "0100",
        "0000" when "0101",
        "0000" when "0110",
        "0000" when "0111",
        "0000" when "1000",
        "0000" when "1001",
        "0000" when "1010",
        "0000" when "1011",
        "0000" when "1100",
        "0000" when "1101",
        "0000" when "1110",
        "0000" when others;



    incrAddr <= '1' when (H_Count < H_Active-1 and V_Count < V_Active)
     or (H_Count = H_Total-1 and (V_Count < V_Active-1 or (V_Count = V_Total-1)))
     else '0';
    
    process(clk_25MHz) begin
        if rising_edge(clk_25MHz) then
            if rst = '1' then
                H_Count <= 0;
                V_Count <= 0;
            
            
            else
                if H_Count < H_Total-1 then
                    H_Count <= H_Count + 1;
                else
                    H_Count <= 0;
                    
                    if V_Count < V_Total-1 then
                        V_Count <= V_Count + 1;
                    else
                        V_Count <= 0;    
                    end if;
                                        
                end if; 
            end if;
        end if;
    end process;
    
    
    --BRAM read adress Management
    process(clk_25MHz) begin
        if rising_edge(clk_25MHz) then
            if (H_Count = H_Total-2) and (V_Count = V_Total-1) then
                addr <= (others => '0');
            elsif   incrAddr = '1'  then
                addr <= addr+1;
            end if;
        end if;    
    end process;
    
    
    

end Behavioral;
