Library IEEE;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.instruction_buffer_type.all;

entity chip8 is
    port(
        CLOCK_50 : in std_logic;
        KEY			 	:  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        hsync : out std_logic;
        vsync : out std_logic;
        redout : out std_logic_vector(3 downto 0);
        greenout : out std_logic_vector(3 downto 0);
        blueout : out std_logic_vector(3 downto 0)
    );
end chip8;

architecture Behavioral of chip8 is
signal rst : std_logic;
signal clk : std_logic;
signal screen : ScreenBuffer;
begin


rst <= not KEY(0);
clk <= CLOCK_50;
screen <= (others => (others => '1')); -- initialize the screen to all black
screen(5)(5) <= '0'; -- set the first row to white for

U1 : entity work.vga
    port map (
        clk => clk,
        rst => rst,
        screen => screen,
        hsync => hsync,
        vsync => vsync,
        redout => redout,
        greenout => greenout,
        blueout => blueout
    );

end architecture Behavioral;

