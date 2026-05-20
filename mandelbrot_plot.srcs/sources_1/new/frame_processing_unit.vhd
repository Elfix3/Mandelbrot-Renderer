----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.05.2026 15:45:33
-- Design Name: 
-- Module Name: frame_processing_unit - Behavioral
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

entity frame_processing_unit is
    Generic(W : integer := 640;                 --number of points to compute in a row
            H : integer := 480;                 --number of points to compute in a column
            n_itermax : integer := 128           --number of iterations per calculator
            );

    Port(
        clk : in std_logic;
        rst : in std_logic;
        
        frame_update : in std_logic;
        
        xCorr : in signed(15 downto 0);
        yCorr : in signed(15 downto 0);
        step : in signed(15 downto 0);
        
        addrWrite : out std_logic_vector(18 downto 0) := (others => '1');   --adress where the BRAM must be written
        pixel_val : out integer range 0 to 128;                             --n_iteration for this pixel
        wea : out std_logic_vector(0 downto 0);
        
        frame_in_process : out std_logic                                    --connected to a led
    );
    

end frame_processing_unit;

architecture Behavioral of frame_processing_unit is

    type t_state is(RUNNING, WRITE, FRAME_COMPLETE);
    signal state : t_state := RUNNING;

    signal xPos : integer range 0 to W-1 := 0;
    signal yPos : integer range 0 to H-1 := 0;

    
    --single calculator signal
    signal a : signed(15 downto 0) := x"c000";
    signal b : signed(15 downto 0) := x"2400";
    signal start : std_logic := '1';
    signal done : std_logic;
    signal n_iter : integer range 0 to 128;
    
begin

    --At the moment : only one instance of calculator
    CALC : entity work.calculator generic map(n_itermax => n_itermax)
    port map(
        clk => clk,
        rst =>  rst,
        start => start,
        a => a,
        b => b,
        done => done,
        n_iter => pixel_val
    );

    
    process(clk) begin
        if rising_edge(clk) then
            if rst = '1' or frame_update = '1' then
                a <= xCorr;
                b <= yCorr;
                xPos <= 0;
                yPos <= 0;
                addrWrite <= (others => '1');
                start <= '1';
                state <= RUNNING;
 
            else
            
            case(state) is
                when RUNNING =>
                    --from here start should be '1'
                    if start = '1' then
                        frame_in_process <= '1';
                        start <= '0';
                        wea <= "0";
                    
                    elsif done = '1' then
                        state <= WRITE; 
                    end if;
                    
                when WRITE =>
                    wea <= "1";
                    --increments adress only the first time
                    --if xPos /= 0 or yPos /= 0 then
                        addrWrite <= std_logic_vector(unsigned(addrWrite)+1);
                    --end if;
                    
                    if xPos < W-1 then
                        xPos <= xPos + 1;       --horitontal step
                        a <= a + step; 
                        
                        --start      
                        start <= '1';
                        state <= RUNNING;
                        
                    elsif xPos = W-1 then
                        xPos <= 0;              --line complete
                        a <= xCorr;
                        
                        if yPos < H-1 then
                            yPos <= yPos + 1;
                            b <= b - step;    
                                
                            --start
                            start <= '1';
                            state <= RUNNING;
                        
                        elsif yPos = H-1 then
                            yPos <= 0; 
                            b <= yCorr;
                            state <= FRAME_COMPLETE;

                        end if;
                    
                    
                    end if;
                        
                when FRAME_COMPLETE =>
                        frame_in_process <= '0';
                        wea <= "0";
                        if frame_update = '1' then
                            start <= '1';
                            state <= RUNNING;
                        end if;
                    
                when others =>
                    null;
            end case;
            
            
            end if;
            
            
        end if;
    end process;
    
end Behavioral;