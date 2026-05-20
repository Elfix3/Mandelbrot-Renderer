----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2026 11:21:07
-- Design Name: 
-- Module Name: top - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity top is
Port (
  
    --clk
    clk : in std_logic;

    --Rst button
    rst : in std_logic;
    
    --Move buttons
    btnU : in std_logic;
    btnL : in std_logic;
    btnD : in std_logic;
    btnR : in std_logic;
    
    
    --Mode switch
    mode : in std_logic;
    
    --frame done led
    led_frame : out std_logic;
    
    
    
    --Color canals
    vgaRed : out std_logic_vector(3 downto 0);
    vgaGreen : out std_logic_vector(3 downto 0);
    vgaBlue : out std_logic_vector(3 downto 0);
    
    --Sync signals
    Hsync : out std_logic;
    Vsync : out std_logic
    
    
  );
end top;

architecture Behavioral of top is
    
    signal clk_100 : std_logic;
    
    --MMCM
    signal clk_vga : std_logic;
    signal locked : std_logic;
    
    --BRAM write
    
    signal addrWrite : std_logic_vector(18 downto 0);
    signal dataIn : std_logic_vector(3 downto 0);
    signal writeEnable : std_logic_vector(0 downto 0);
    
    --BRAM read
    signal addrRead : std_logic_vector(18 downto 0);
    signal dataOut : std_logic_vector(3 downto 0);
    
    --Zoom manager
    signal xOut : signed(15 downto 0);
    signal yOut : signed(15 downto 0);
    signal stepOut : signed(15 downto 0);
    
    --FPU
    signal frame_update : std_logic := '0';
    signal pixel_val : integer range 0 to 128;
    

    constant n_itermax : integer := 64;

begin
    
    
    
    
    MMCM_INSTANCE : entity work.clk_wiz_0 port map(
        clk_in1 => clk,
        reset => '0',
        clk_out1 => clk_vga,
        clk_out2 => clk_100,
        locked => locked
    );
    
    --BRAM
    FRAME_BUFFER_INSTANCE : entity work.frame_buffer port map(
        clka => clk_100,
        addra=> addrWrite,
        dina => dataIn,
        ena => '1',
        wea => writeEnable,
        
        clkb => clk_vga,
        addrb => addrRead,
        doutb => dataOut, 
        enb => '1'                      
    );
    
    CONVERTER : entity work.level_converter generic map(max_iter => n_itermax) port map(
        x => pixel_val,         --pixel val from the FPU
        level => dataIn         --level to the BRAM
    );
    
    ZOOM : entity work.zoom_manager port map(
        clk => clk_100,
        rst => rst,
        u => btnU,
        l => btnL,
        d => btnD,
        r => btnR,
        mode => mode,
        frame_update => frame_update,
        xOut => xOut,
        yOut => yOut,
        stepOut => stepOut
    );
    
    FPU : entity work.frame_processing_unit
        generic map(n_itermax => n_itermax)
        port map(
        clk => clk_100,
        rst => rst,
        xCorr => xOut,                          --output of the zoom manager
        yCorr => yOut,                          --output of the zoom manager
        step =>  stepOut,                       --output of the zoom manager
        frame_update => frame_update,
        
        --LED for frame in process
        frame_in_process => led_frame,
        
        --BRAM connections
        addrWrite => addrWrite,
        wea => writeEnable,
        
        --CONVERTER connection
        pixel_val => pixel_val
        
    );

    VGA_INSTANCE : entity work.vga_controller port map(
        --MMCM connections
        clk_25MHz => clk_vga,
        rst => not locked,
        
        --BRAM connections
        pixeldata => dataOut,   --BRAM read port
        addrPixel => addrRead,  --BRAM read adress
        
        --TOP connections
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue,
        Hsync => Hsync,
        Vsync => vSync       
    );

end Behavioral;
