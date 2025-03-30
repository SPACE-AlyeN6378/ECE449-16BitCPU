library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;
--- -fsynopsys -fexplicit
entity ALU_file is
    port (
        -- rst : in std_logic; --clock
        -- clk: in std_logic;  --reset
    
        alu_mode : in std_logic_vector(2 downto 0); -- ALU op code from decode stage
        in1 : in std_logic_vector(15 downto 0); -- Input from RA
        in2 : in std_logic_vector(15 downto 0); -- Input from RB
        shift_count : in std_logic_vector(3 downto 0); -- Shift count for barrel shifting
        result : out std_logic_vector(15 downto 0); -- Lower 16 bits of result
        --resultU : out std_logic_vector(15 downto 0); -- Upper 16 bits of result
        z_flag : out std_logic;
        n_flag : out std_logic;
        o_flag : out std_logic  -- Added overflow flag
    );
end ALU_file;

architecture behavioral of ALU_file is
    -- 32-bit temporary result for full multiplication and addition overflow
    signal temp_result: std_logic_vector(31 downto 0);
    
    -- Addition with overflow detection
    signal add_result: std_logic_vector(16 downto 0);  -- 17 bits for overflow
    
    -- Flags
    signal z : std_logic;
    signal n : std_logic;
    signal o : std_logic;
begin
    process(alu_mode, in1, in2, shift_count)
        -- Variables for bit shifting process
        variable shifted_value: signed(31 downto 0);
        variable in1_signed: signed(15 downto 0);
        variable in2_signed: signed(15 downto 0);
        variable shift_amt: integer;
    begin
        -- Default values
        temp_result <= (others => '0');
        add_result <= (others => '0');
        o <= '0'; -- Default overflow flag

        -- Assign variables
        shifted_value := X"00000000";
        in1_signed := signed(in1);
        in2_signed := signed(in2);
        shift_amt := to_integer(unsigned(shift_count));
        
        case alu_mode is
            when "000" =>  -- NOP
                temp_result <= x"00000000";
                
            when "001" =>  -- ADD
                temp_result <= X"0000" & std_logic_vector(in1_signed + in2_signed);
                -- Check for overflow in ADD
                if (in1(15) = in2(15) AND temp_result(15) /= in1(15)) then
                    o <= '1';
                else 
                    o <= '0';
                end if;
                
            when "010" =>  -- SUB
                temp_result <= X"0000" & std_logic_vector(in1_signed - in2_signed);
                -- Check for overflow in SUB
                if (in1(15) /= in2(15) AND temp_result(15) = in2(15)) then
                    o <= '1';
                else 
                    o <= '0';
                end if;
                
            when "011" =>  -- MUL
                temp_result <= std_logic_vector(signed(in1_signed) * signed(in2_signed));
                -- Check for overflow in MUL
                -- Overflow detection: If shifting caused a sign change or loss of significant bits
                if (in1(15) = '0' and temp_result(31 downto 16) /= X"0000") or
                (in1(15) = '1' and temp_result(31 downto 16) /= X"FFFF") then
                    o <= '1';
                else
                    o <= '0';
                end if;
                
            when "100" =>  -- NAND
                temp_result <= x"0000" & (in1 nand in2);
                
            when "101" =>  -- SHL (Arithmetic method)
                -- Perform shift and assign to temp_result
                shifted_value := shift_left(resize(in1_signed, 32), shift_amt);
                temp_result <= std_logic_vector(shifted_value);

                -- Overflow detection: If shifting caused a sign change or loss of significant bits
                if (in1(15) = '0' and shifted_value(31 downto 16) /= X"0000") or
                (in1(15) = '1' and shifted_value(31 downto 16) /= X"FFFF") then
                    o <= '1';
                else
                    o <= '0';
                end if;
            
            when "110" =>  -- SHR (barrel shift implementation)
                -- Perform shift and assign to temp_result
                shifted_value := shift_right(resize(in1_signed, 32), shift_amt);
                temp_result <= std_logic_vector(shifted_value);
                
            when "111" =>  -- TEST
                temp_result <= x"0000" & in1;
                
            when others =>
                temp_result <= (others => '0');
        end case;
    end process;

    -- Set flags based on result
    z <= '1' when temp_result(15 downto 0) = x"0000" else '0';
    n <= temp_result(15);  -- Sign bit from lower result
    
    -- Output the results and flags
    result <= temp_result(15 downto 0);   -- Lower 16 bits
    --resultU <= temp_result(31 downto 16);  -- Upper 16 bits
    z_flag <= z;
    n_flag <= n;
    o_flag <= o;

end behavioral;