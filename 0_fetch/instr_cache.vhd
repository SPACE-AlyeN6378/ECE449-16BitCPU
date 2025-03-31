library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-- disp s is absolute locale
entity instruction_cache is
    port (
        clk   : in  std_logic;
        en    : in  std_logic;
        addr  : in  std_logic_vector(8 downto 0);
        data  : out std_logic_vector(15 downto 0)
    );
end instruction_cache;

architecture behavioral of instruction_cache is
    -- Define ROM type (512 entries of 16-bit instructions)
    type cache_type is array (0 to 255) of std_logic_vector(15 downto 0);
    
    -- Initialize ROM with sample instructions
    -- You can modify these instructions as needed
    signal cache : cache_type := (
        -- Address 0: Start of program
        0 => X"4280",
        1 => X"42C0",
        2 => X"0000",
        3 => X"0000",
        4 => X"0000",
        5 => X"0000",
        6 => X"0253",
        7 => X"0000",
        8 => X"0000",
        9 => X"0000",
        10 => X"0000",
        11 => X"0E40",


        -- Fill the rest with NOPs
        others => X"0000"  -- NOP
    );
    
    -- Registered output
    signal data_reg : std_logic_vector(15 downto 0) := (others => '0');
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                -- Read from ROM at the specified address
                data_reg <= cache(to_integer(unsigned(addr))/2); -- div by 2 bc the array only increments by 1. 
            end if;
        end if;
    end process;
    
    -- Output the data
    data <= data_reg;
end behavioral;