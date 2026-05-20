----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2026 13:38:38
-- Design Name: 
-- Module Name: calculator - Behavioral
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

entity calculator is
  Generic(n_itermax : integer := 32);
  
  Port (
    clk : in std_logic;
    rst : in std_logic;
  
    -- c = a +j*b
    a : in signed(15 downto 0);
    b : in signed(15 downto 0);
    
    -- starts the calculation
    start : std_logic;

    --high when calculation done
    done : out std_logic;
    
    --number of iteration
    n_iter : out integer range 0 to n_itermax-1

  );
end calculator;

architecture Behavioral of calculator is
    
    --state control    
    type t_state is(IDLE, RUNNING);
    signal state : t_state := IDLE;
    
    
    --next x and next y
    signal x : signed(15 downto 0) := (others => '0'); --zn = zn-1² + c
    signal y : signed(15 downto 0) := (others => '0');
    
    
    --products squares and xy
    signal xsq : signed(31 downto 0) := (others => '0');
    signal ysq : signed(31 downto 0) := (others => '0');
    signal xy : signed(31 downto 0) := (others => '0');
    
    --magnitudes
    signal mag : signed(31 downto 0) := (others => '0');
    constant MAG_THRESHOLD : signed(31 downto 0) := to_signed(4 * 2**13, 32); -- 4 in Q 3.13 format
    
    --iteration counter
    signal icount : integer range 0 to n_itermax := 0;
    
begin
   
   --magnitude
    mag <= xsq + ysq;
    n_iter <= icount;
    
    --calculation of the new x and y with respect to the xsq, yxsq and xy internal signals
    x <= resize(xsq - ysq + resize(a,32),16);
    y <= resize(shift_left(xy,1) + resize(b,32),16);
    
    
    process(clk) begin        
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                
                --resets registers
                xsq <= (others => '0');
                ysq <= (others => '0');
                xy <= (others => '0');
                        
                icount <= 0;
                done <= '0';
            else
                case state is
                    when IDLE =>
                        if start = '1' then
                            done <= '0';
                            icount <= 0;
                            state <= RUNNING;
                        end if;
                        
                    when RUNNING =>

                        --magnitude check
                        if mag >= MAG_THRESHOLD then
                            done <= '1';
                            xsq <= (others => '0');ysq <= (others => '0');xy <= (others => '0');
                            state <= IDLE;

                        --max_iter                            
                        elsif icount = n_itermax-1 then
                            done <= '1';
                            xsq <= (others => '0');ysq <= (others => '0');xy <= (others => '0');
                            state <= IDLE;
                        
                        --next calculation    
                        else
                            xsq <= shift_right(x*x,13);
                            ysq <= shift_right(y*y,13);
                            xy <= shift_right(x*y,13);
                            icount <= icount + 1;
                        end if;                   
                    when others =>
                        null;
                end case;
            
            
            end if;
        end if;
    end process;
    

end Behavioral;
