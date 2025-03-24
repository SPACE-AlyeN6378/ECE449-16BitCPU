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
        br_active_final : out std_logic;
        new_pc : out std_logic_vector(8 downto 0)
    );
end BranchControlUnit;

architecture behavioral of BranchControlUnit is

    signal relative_val: unsigned(8 downto 0);      -- Relative
    signal absolute_val: unsigned(8 downto 0);      -- Absolute
    signal result: unsigned(8 downto 0);        -- Result
    signal br_active_sig: std_logic;

    signal disp_signed: signed(8 downto 0);
    signal pc_unsigned: unsigned(8 downto 0);
    signal r_data_unsigned: unsigned(8 downto 0);

begin
    -- Convert the signals
    disp_signed <= signed(disp);
    pc_unsigned <= unsigned(pc);
    r_data_unsigned <= unsigned(r_data(8 downto 0));

    -- Assign the signals to the outputs
    br_active_final <= br_active_sig;
    new_pc <= std_logic_vector(result);
    
    process(enable, br_mode, relative_val, absolute_val, disp_signed, pc_unsigned, r_data_unsigned, z_flag, n_flag) 
    begin
        br_active_sig <= '0'; -- ADDED THIS
        -- result <= (others => '0');
        result <= pc_unsigned + 2;  -- COMMENT THIS IF IT STILL DOESNT WORK

        -- Calculation of the new PC address
        if disp_signed(8) = '0' then
            relative_val <= pc_unsigned + unsigned(disp_signed) + unsigned(disp_signed);
            absolute_val <= r_data_unsigned + unsigned(disp_signed) + unsigned(disp_signed);
        else
            relative_val <= pc_unsigned - unsigned(disp_signed) - unsigned(disp_signed);
            absolute_val <= r_data_unsigned - unsigned(disp_signed) - unsigned(disp_signed);
        end if;
        
        -- Send the results, according to br_mode
        case br_mode is
            when "000" =>   -- BRR
                br_active_sig <= enable;
                result <= relative_val;
            
            when "001" =>   -- BRR.N
                br_active_sig <= enable and n_flag;
                result <= relative_val;
                
            when "010" =>   -- BRR.Z
                br_active_sig <= enable and z_flag;
                result <= relative_val;

            when "011" =>   -- BR
                br_active_sig <= enable;
                result <= absolute_val;

            when "100" =>   -- BR.N
                br_active_sig <= enable and n_flag;
                result <= absolute_val;

            when "101" =>   -- BR.Z
                br_active_sig <= enable and z_flag;
                result <= absolute_val;

            when "110" =>   -- BR.SUB
                br_active_sig <= enable;
                result <= absolute_val;

            when "111" =>   -- RETURN
                br_active_sig <= enable;
                result <= r_data_unsigned;

            when others =>
                result <= pc_unsigned + 2;

        end case;
    end process;

    

end behavioral;