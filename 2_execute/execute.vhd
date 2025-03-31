library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity ExecutionStage is
    port (
        -- Input ports
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;

        -- From previous stage (ID/EX)
        rd_data1: in std_logic_vector(15 downto 0);     -- Goes to MUX, then to ALU
        rd_data2: in std_logic_vector(15 downto 0);     -- Goes to MUX, then to ALU and pipeline
        alu_mode: in std_logic_vector(2 downto 0);      -- Goes to ALU
        shift_count: in std_logic_vector(3 downto 0);   -- Goes to ALU

        mem_opr: in std_logic_vector(0 downto 0);       -- Goes straight to pipeline
        data_type: in std_logic_vector(1 downto 0);                         -- Goes straight to pipeline
        wb_opr: in std_logic;                           -- Goes straight to pipeline
        ra: in std_logic_vector(2 downto 0);            -- Goes straight to pipeline

        br_mode: in std_logic_vector(2 downto 0);       -- Goes to Branch control unit/ALU
        disp: in std_logic_vector(8 downto 0);          -- Goes to Branch control unit
        br_enable: in std_logic;                        -- Goes to Branch control unit
        pc_address: in std_logic_vector(8 downto 0);    -- Goes to Branch control unit/ALU


    -- From Branch control unit
        br_address_to_pc: out std_logic_vector(8 downto 0);        -- Goes back to PC at stage 1 - Fetch
        br_enable_to_pc: out std_logic;                      -- Goes back to PC stage 1 (at flush and br_active pins)
        alu_result_out: out std_logic_vector(15 downto 0);
        mem_addr_out: out std_logic_vector(8 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);
        data_type_out: out std_logic_vector(1 downto 0);
        wb_opr_out: out std_logic;
        ra_out: out std_logic_vector(2 downto 0)

    );
end ExecutionStage;

architecture Behavioral of ExecutionStage is
    
    
    -- -- Temporary ALU signals
    signal alu_in1: std_logic_vector(15 downto 0);      -- Goes to ALU
    signal alu_in2: std_logic_vector(15 downto 0);      -- Goes to ALU

    -- Outputs
    -- From ALU
    signal alu_result: std_logic_vector(15 downto 0);     -- Goes to EX/MEM pipeline
    signal z_flag: std_logic;                             -- Goes to Branch control unit
    signal n_flag: std_logic;                             -- Goes to Branch control unit

    signal mem_addr: std_logic_vector(8 downto 0);        -- Goes straight to pipeline

begin
    mem_addr <= rd_data2(8 downto 0);

    -- MUX: to determine between the input data for the ALU
    process(br_mode, pc_address, rd_data1, rd_data2) begin
        -- If the SUBROUTINE operation is used
        if (br_mode = "110") then
            -- The ALU gets the current PC value and stores them to R7 in later stages
            alu_in1 <= "0000000" & pc_address;
            alu_in2 <= std_logic_vector(to_unsigned(2, 16));    -- PC + 2
        else
            -- Otherwise, just use the values from the registers
            alu_in1 <= rd_data1;
            alu_in2 <= rd_data2;
        end if;
    end process;

    ALU: entity work.ALU_file
    port map (
        alu_mode => alu_mode,
        in1 => alu_in1,
        in2 => alu_in2,
        shift_count => shift_count,

        result => alu_result,
        z_flag => z_flag,
        n_flag => n_flag
        -- o_flag => o_flag (STUBBED)
    );

    BCU: entity work.BranchControlUnit
    port map (
        enable => br_enable,
        br_mode => br_mode,
        pc => pc_address,
        r_data => rd_data1,
        disp => disp,
        z_flag => z_flag,
        n_flag => n_flag,
        br_active_to_pc => br_enable_to_pc,
        new_pc => br_address_to_pc
    );

    PIPELINE: entity work.exmem_pipeline
    port map (
        clk => clk,
        rst => rst,
        enable => en,
        
        alu_result_in => alu_result,
        mem_addr_in => mem_addr,
        mem_opr_in => mem_opr,
        data_type_in => data_type,
        wb_opr_in => wb_opr,
        ra_in => ra,

        alu_result_out => alu_result_out,
        mem_addr_out => mem_addr_out,
        mem_opr_out => mem_opr_out,
        data_type_out => data_type_out,
        wb_opr_out => wb_opr_out,
        ra_out => ra_out
    );

end Behavioral;
