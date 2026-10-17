Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package instruction_buffer_type is
type ScreenBuffer is array (0 to 64) of std_logic_vector(31 downto 0);
end package instruction_buffer_type;

Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.instruction_buffer_type.all;

entity vga is
    generic (
        HRQ : natural := 22
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        screen : in ScreenBuffer;
        hsync : out std_logic;
        vsync : out std_logic;
        redout : out std_logic_vector(3 downto 0);
        greenout : out std_logic_vector(3 downto 0);
        blueout : out std_logic_vector(3 downto 0)
    );
end vga;

architecture Behavioral of vga is
    signal hcount : integer range 0 to 799 := 0;
    signal vcount : integer range 0 to 524 := 0;
    signal hsync_reg : std_logic := '1';
    signal vsync_reg : std_logic := '1';
    constant B : natural := 93;  -- horizontal blank: 3.77 us
    constant C : natural := 45;  -- front guard: 1.89 us
    constant D : natural := 640; -- horizontal columns: 25.17 us
    constant E : natural := 22;  -- rear guard: 0.94 us
    constant A : natural := B + C + D + E;  -- one horizontal sync cycle: 31.77 us
    constant P : natural := 2;   -- vertical blank: 64 us
    constant Q : natural := 32;  -- front guard: 1.02 ms
    constant R : natural := 480; -- vertical rows: 15.25 ms
    constant S : natural := 11;  -- rear guard: 0.35 ms
    constant O : natural := P + Q + R + S;
    signal count : std_logic; -- division by 2 of the clock to get 25 MHz

begin

    process(rst,clk)
    begin
        if rst = '1' then
            hcount <= 0 ;
            vcount <= 0 ;
            hsync_reg <= '0' ;
            vsync_reg <= '0' ;
        elsif rising_edge(clk) then
            if count = '0' then
                count <= '1';
            else
                count <= '0';
                if hcount = (A - 1) then
                    hcount <= 0 ;
                    if vcount = (O - 1) then
						    vcount <= 0 ;	
                    else
                      vcount <= vcount + 1 ;
                    end if; 
                else
                    hcount <= hcount + 1 ;
                end if;
            end if;

            
            if hcount < D  and vcount < R  then
                if screen(hcount / 10)(vcount / 15) = '1' then
                    redout <= "1111";
                    blueout <= "1111";
                    greenout <= "1111";
                else
                    redout <= "0000";
                    blueout <= "0000";
                    greenout <= "0000";
                end if;
            else
                redout   <= "0000";
                greenout <= "0000";
                blueout  <= "0000";
            end if;
            --if hcount > 0 and hcount < D + E and
            --    vcount > 0 and vcount < R + 5 then
			--	redout   <= redin;
            --    greenout <= green;
            --    blueout  <= bluein;
            --else
            --    redout   <= "0000";
            --    greenout <= "0000";
            --    blueout  <= "0000";
            --end if;

            if  hcount >= (D + E)  and  hcount < (D + E + B)  then
                hsync_reg <= '0';
            else
                hsync_reg <= '1';
            end if;

            if  vcount >= (R + S)  and  vcount < (R + S + P)  then
                vsync_reg <= '0';
            else
                vsync_reg <= '1';
            end if;

            -- mapping of the variable to the signals
            -- negative signs are because the conversion bits are reversed
            hsync <= hsync_reg;
            vsync <= vsync_reg;

        end if;
    end process;
end architecture Behavioral;