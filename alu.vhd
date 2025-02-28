library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;
--- -fsynopsys -fexplicit
entity alu is
    port (
        alu_mode : in std_logic_vector(2 downto 0); -- ALU op code from decode stage
        in1 : in std_logic_vector(15 downto 0); -- Input from RA
        in2 : in std_logic_vector(15 downto 0); -- Input from RB
        resultL : out std_logic_vector(15 downto 0); -- Lower 16 bits of result
        resultU : out std_logic_vector(15 downto 0); -- Upper 16 bits of result
        z_flag : out std_logic;
        n_flag : out std_logic
    );
end alu;

architecture behavioral of alu is
    -- 32-bit temporary result for full multiplication and addition overflow
    signal temp_result: std_logic_vector(31 downto 0);
    
    -- Addition with overflow detection
    signal add_result: std_logic_vector(16 downto 0);  -- 17 bits for overflow
begin
    process(alu_mode, in1, in2)
    --variable mult_result: signed(31 downto 0);
    begin
        -- Default values
        temp_result <= (others => '0');
        add_result <= (others => '0');
        
        case alu_mode is
            when "000" =>  -- NOP
                temp_result <= x"00000000";  -- Pass through first input
                
            when "001" =>  -- ADD                 MAY CAUSE ERRORS
                add_result <= std_logic_vector(('0' & signed(in1)) + ('0' & signed(in2)));
                temp_result <= x"0000" & add_result(15 downto 0); -- Perform 17-bit addition to catch overflow
                if add_result(16) = '1' then  -- Handle overflow
                    temp_result(16) <= '1';  -- Set overflow bit in upper result
                end if;
                
            when "010" =>  -- SUB
                temp_result <= x"0000" & std_logic_vector(signed(in1) - signed(in2));
                
            when "011" =>  -- MUL
                temp_result <= std_logic_vector(signed(in1) * signed(in2));
                
            when "100" =>  -- NAND
                temp_result <= x"0000" & (in1 nand in2);
                
            when "101" =>  -- LSL
                temp_result <= x"0000" & std_logic_vector(shift_left(signed(in1), 
                             to_integer(signed(in2(3 downto 0))) mod 16));  -- mod added to fix edge case, could be wrong
                
            when "110" =>  -- LSR
                temp_result <= x"0000" & std_logic_vector(shift_right(signed(in1), 
                             to_integer(signed(in2(3 downto 0))) mod 16));
                
            when "111" =>  -- TEST
                temp_result <= x"0000" & (in1 and in2);
                
            when others =>
                temp_result <= (others => '0');
        end case;
    end process;

    -- Set flags based on lower result
    z_flag <= '1' when temp_result(15 downto 0) = x"0000" else '0';
    n_flag <= temp_result(15);  -- Sign bit from lower result
    
    -- Output the results
    resultL <= temp_result(15 downto 0);   -- Lower 16 bits
    resultU <= temp_result(31 downto 16);  -- Upper 16 bits

end behavioral;
