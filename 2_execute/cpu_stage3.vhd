library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity CPUExecute is
    port (
        -- Input ports
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;

        -- Branching controller ports
        -- br_address_in: in std_logic_vector(8 downto 0);
        -- branch_active: in std_logic

        -- Write signals
        wr_en: in std_logic;
        wr_reg_index: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0);
        mem_addr_in: in std_logic_vector(8 downto 0);

        -- Outputs
        alu_result_out: out std_logic_vector(15 downto 0);
        mem_addr_out: out std_logic_vector(8 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);
        wb_opr_out: out std_logic;
        ra_out: out std_logic_vector(2 downto 0)

    );
end CPUExecute;

architecture Behavioral of CPUExecute is
    -- From previous stage (ID/EX)
    signal rd_data1: std_logic_vector(15 downto 0);     -- Goes to MUX, then to ALU
    signal rd_data2: std_logic_vector(15 downto 0);     -- Goes to MUX, then to ALU and pipeline
    signal alu_mode: std_logic_vector(2 downto 0);      -- Goes to ALU
    signal shift_count: std_logic_vector(3 downto 0);   -- Goes to ALU

    signal mem_opr: std_logic_vector(0 downto 0);       -- Goes to pipeline
    signal wb_opr: std_logic;                           -- Goes to pipeline
    signal ra: std_logic_vector(2 downto 0);            -- Goes to pipeline

    signal br_mode: std_logic_vector(2 downto 0);       -- Goes to Branch control unit/ALU
    signal disp: std_logic_vector(8 downto 0);          -- Goes to Branch control unit
    signal br_active: std_logic;                        -- Goes to Branch control unit
    signal pc_address: std_logic_vector(8 downto 0);    -- Goes to Branch control unit/ALU
    
    -- Temporary ALU signals
    signal alu_in1: std_logic_vector(15 downto 0);      -- Goes to ALU
    signal alu_in2: std_logic_vector(15 downto 0);      -- Goes to ALU

    -- From ALU
    signal alu_result: std_logic_vector(15 downto 0);     -- Goes to EX/MEM pipeline
    signal z_flag: std_logic;                             -- Goes to Branch control unit
    signal n_flag: std_logic;                             -- Goes to Branch control unit
    signal mem_addr: std_logic_vector(8 downto 0);

    -- From Branch control unit
    signal br_address: std_logic_vector(8 downto 0);        -- Goes back to PC at stage 1
    signal br_active_final: std_logic;   -- Goes back to PC stage 1

    -- Used for flushing previous stages
    -- signal flush: std_logic;                          -- Goes to previous stages


begin
    mem_addr <= rd_data2(8 downto 0);

    -- Port mappings
    CPU2: entity work.CPUDecode
    port map (
        clk => clk, rst => rst,
        flush => br_active_final,
        br_address_in => br_address,
        en => en,
        branch_active => br_active_final,

        -- Write signals
        wr_en => wr_en,
        wr_reg_index => wr_reg_index,
        wr_data => wr_data,

        rd_data1_out => rd_data1,
        rd_data2_out => rd_data2,
        alu_mode_out => alu_mode,
        br_mode_out => br_mode,
        mem_opr_out => mem_opr,
        wb_opr_out => wb_opr,
        br_active_out => br_active,
        ra_out => ra,
        shift_count_out => shift_count,
        pc_address_out => pc_address,
        disp_out => disp
    );

    -- MUX to determine between the input data for the ALU
    process(br_mode, pc_address, rd_data1, rd_data2) begin
        -- If the RETURN branch is used
        if (br_mode = "111") then
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
        enable => br_active,
        br_mode => br_mode,
        pc => pc_address,
        r_data => rd_data1,
        disp => disp,
        z_flag => z_flag,
        n_flag => n_flag,
        br_active_final => br_active_final,
        new_pc => br_address
    );

    PIPELINE: entity work.exmem_pipeline
    port map (
        clk => clk,
        rst => rst,
        enable => en,
        alu_result_in => alu_result,
        mem_addr_in => mem_addr,
        mem_opr_in => mem_opr,
        wb_opr_in => wb_opr,
        ra_in => ra,
        alu_result_out => alu_result_out,
        mem_addr_out => mem_addr_out,
        mem_opr_out => mem_opr_out,
        wb_opr_out => wb_opr_out,
        ra_out => ra_out
    );

end Behavioral;
