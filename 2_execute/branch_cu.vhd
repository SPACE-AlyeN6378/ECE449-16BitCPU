library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity BranchControlUnit is
    port (
        -- Input signal
        enable : in std_logic;
        br_mode : in std_logic_vector(2 downto 0);

        pc : in std_logic_vector(8 downto 0);
        r_data : in std_logic_vector(15 downto 0);
        disp : in std_logic_vector(8 downto 0);

        z_flag : in std_logic;
        n_flag : in std_logic;

        -- Output signal
        br_active_to_pc : out std_logic;
        new_pc : out std_logic_vector(8 downto 0)
    );
end BranchControlUnit;

architecture behavioral of BranchControlUnit is

    signal relative_val: unsigned(8 downto 0);      -- Relative
    signal absolute_val: unsigned(8 downto 0);      -- Absolute
    signal result: std_logic_vector(8 downto 0);        -- Result
    signal br_active_sig: std_logic;

    signal disp_signed: signed(8 downto 0);
    signal pc_signed: signed(8 downto 0);
    signal r_data_signed: signed(8 downto 0);

begin
    -- Convert the signals
    disp_signed <= signed(disp);
    pc_signed <= signed(pc);
    r_data_signed <= signed(r_data(8 downto 0));

    -- Assign the signals to the outputs
    br_active_to_pc <= br_active_sig;
    new_pc <= result;
    
    process(enable, br_mode, relative_val, absolute_val, disp_signed, pc_signed, r_data_signed, z_flag, n_flag) 
    begin
        br_active_sig <= '0'; -- ADDED THIS
        -- result <= (others => '0');

        -- Calculation of the new PC address
        relative_val <= unsigned(pc_signed + disp_signed + disp_signed);
        absolute_val <= unsigned(r_data_signed + disp_signed + disp_signed);
        
        -- Send the results, according to br_mode
        case br_mode is
            when "000" =>   -- BRR
                br_active_sig <= enable;
                result <= std_logic_vector(relative_val);
            
            when "001" =>   -- BRR.N
                br_active_sig <= enable and n_flag;
                result <= std_logic_vector(relative_val);
                
            when "010" =>   -- BRR.Z
                br_active_sig <= enable and z_flag;
                result <= std_logic_vector(relative_val);

            when "011" =>   -- BR
                br_active_sig <= enable;
                result <= std_logic_vector(absolute_val);

            when "100" =>   -- BR.N
                br_active_sig <= enable and n_flag;
                result <= std_logic_vector(absolute_val);

            when "101" =>   -- BR.Z
                br_active_sig <= enable and z_flag;
                result <= std_logic_vector(absolute_val);

            when "110" =>   -- BR.SUB
                br_active_sig <= enable;
                result <= std_logic_vector(absolute_val);

            when "111" =>   -- RETURN
                br_active_sig <= enable;
                result <= std_logic_vector(r_data_signed);

            when others =>
                result <= std_logic_vector(pc_signed + 2);

        end case;
    end process;

    

end behavioral;