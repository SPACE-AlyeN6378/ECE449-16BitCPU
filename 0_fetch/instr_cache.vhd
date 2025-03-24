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
        0  => X"4240",  -- IN r1              -- r1 = 04
        1  => X"4280",  -- IN r2              -- r2 = 15
        2  => X"0000",  -- NOP
        3  => X"0000",  -- NOP
        4  => X"0000",  -- NOP
        5  => X"0000",  -- NOP
        6  => X"02D1",  -- ADD r3, r2, r1     -- r3 = 19
        7  => X"0AF4",  -- NOP
        8  => X"0000",  -- NOP
        9  => X"0000",  -- NOP
        10 => X"0000",  -- NOP
        11 => X"0000",  -- SHL r3, 2          -- r3 = 32
        12 => X"0000",  -- NOP
        13 => X"0000",  -- NOP
        14 => X"0000",  -- NOP
        15 => X"0000",  -- NOP
        16 => X"068B",  -- MUL r2, r1, r3     -- r2 = 96
        17 => X"0000",  -- NOP
        18 => X"0000",  -- NOP
        19 => X"0000",  -- NOP
        20 => X"0000",  -- NOP
        21 => X"4080",  -- OUT r2             -- r2 = 96
        
        -- Example of branch instructions
        22 => "1000011000000011",  -- BR r0, 3           -- Branch to address in r0
        -- 23 => X"8909",  -- BR.N r4, 9 
        23 => X"0000",
        24 => X"8709",
        25 => X"8484",
        26 => X"0000",
        27 => "1000110010001100",
       -- 23 => X"6401",  -- BRR +1             -- Branch relative by 1
       -- 24 => X"0000",  -- NOP (skipped if branch taken)
       -- 25 => X"6500",  -- BRR.N 0            -- Branch if negative (example)
       -- 26 => X"6600",  -- BRR.Z 0            -- Branch if zero (example)
        --27 => X"7100",  -- RETURN             -- Return from subroutine
        
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