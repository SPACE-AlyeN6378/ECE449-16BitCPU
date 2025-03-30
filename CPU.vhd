library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity CPU is
    port (
        -- Input ports
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;

        -- Branching controller ports
        br_address_in: in std_logic_vector(8 downto 0);
        branch_active: in std_logic;

        -- Write signals
        wr_en: in std_logic;
        wr_reg_index: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0)

        -- Outputs
        -- rd_data1_out: out std_logic_vector(15 downto 0);
        -- rd_data2_out: out std_logic_vector(15 downto 0);
        -- alu_mode_out: out std_logic_vector(2 downto 0);
        -- br_mode_out: out std_logic_vector(2 downto 0);
        -- mem_opr_out: out std_logic_vector(0 downto 0);
        -- wb_opr_out: out std_logic;
        -- br_active_out: out std_logic;
        -- ra_out: out std_logic_vector(2 downto 0);
        -- shift_count_out: out std_logic_vector(3 downto 0);
        -- pc_address_out: out std_logic_vector(8 downto 0);
        -- disp_out: out std_logic_vector(8 downto 0)
    );

end CPU;

architecture Behavioral of CPU is
    -- 
    signal flush : std_logic;    -- For clearing out the instructions after branching
    signal addr  : std_logic_vector(8 downto 0);    -- address

    -- =====================================
    --       SIGNALS IN DECODING STAGE
    -- =====================================
    -- From IF/ID Pipeline
    signal opcode: std_logic_vector(6 downto 0) := (others => '0'); -- Opcode

    signal ra: std_logic_vector(2 downto 0);	-- Address of register A
    signal rb: std_logic_vector(2 downto 0); 	-- Address of register B
    signal rc: std_logic_vector(2 downto 0); 	-- Address of register C
    signal c1: std_logic_vector(3 downto 0); 	-- Direct shift value
    signal rd_index1: std_logic_vector(2 downto 0);     -- Address of either A or B, depending on the instructions
    signal rd_index2: std_logic_vector(2 downto 0);     -- Address of either 
    
    signal disp_l: std_logic_vector(8 downto 0); -- Direct disp values
    signal disp_s: std_logic_vector(5 downto 0);
    
    signal imm: std_logic_vector(7 downto 0);  -- Immediate values
    signal m1: std_logic;						-- Grab upper/lower byte
    signal r_dest: std_logic_vector(2 downto 0);	-- Destination register address
    signal r_src: std_logic_vector(2 downto 0);		-- Source Register address

    signal pc_address_ifid: std_logic_vector(8 downto 0);


    -- To ID/EX Pipeline
    signal ra_idex: std_logic_vector(2 downto 0);	-- Address of register A
    signal rd_data1_idex: std_logic_vector(15 downto 0);    -- Register data 1
    signal rd_data2_idex: std_logic_vector(15 downto 0);    -- Register data 2

    signal alu_mode_idex: std_logic_vector(2 downto 0);
    signal br_mode_idex: std_logic_vector(2 downto 0);
    signal mem_opr_idex: std_logic_vector(0 downto 0);
    signal wb_opr_idex: std_logic;
    signal br_active_idex: std_logic;
    signal shift_count_idex: std_logic_vector(3 downto 0);

    signal pc_address_from_decoder: std_logic_vector(8 downto 0);
    signal pc_address_idex: std_logic_vector(8 downto 0);
    signal disp_idex: std_logic_vector(8 downto 0); -- Direct disp values

    -- =====================================
    --      SIGNALS IN EXECUTION STAGE
    -- =====================================
    -- From ID/EX Pipeline
    signal rd_data1_exec: std_logic_vector(15 downto 0);
    signal rd_data2_exec: std_logic_vector(15 downto 0);
    signal alu_mode_exec: std_logic_vector(2 downto 0);
    signal br_mode_exec: std_logic_vector(2 downto 0);
    signal mem_opr_exec: std_logic_vector(0 downto 0);
    signal wb_opr_exec: std_logic;
    signal br_active_exec: std_logic;
    signal ra_exec: std_logic_vector(2 downto 0);
    signal shift_count_exec: std_logic_vector(3 downto 0);
    signal pc_address_exec: std_logic_vector(8 downto 0);
    signal disp_exec: std_logic_vector(8 downto 0);

    ----------------------------------------------------------------------------------
    -- To the program counter
    signal br_address_to_pc: std_logic_vector(8 downto 0);        -- Goes back to PC at stage 1 - Fetch
    signal br_enable_to_pc: std_logic;                      -- Goes back to PC stage 1 (at flush and br_active pins)

    -- =====================================
    --       SIGNALS IN MEMORY STAGE
    -- =====================================
    signal alu_result_mem: std_logic_vector(15 downto 0);
    signal mem_addr_mem: std_logic_vector(8 downto 0);
    signal mem_opr_mem: std_logic_vector(0 downto 0);
    signal wb_opr_mem: std_logic;
    signal ra_mem: std_logic_vector(2 downto 0);
    

begin
    -- Only specific components can be flushed
    flush <= rst or br_enable_to_pc;
    -- TODO: Use XOR gate for register indices to stall pipeline

    -- Port mappings
    FETCH_STAGE: entity work.CPUFetch
    port map (
        clk => clk, rst => rst,

        br_address_in => br_address_in,
        en => en,
        branch_active => branch_active,

        opcode => opcode,
        ra => ra, rb => rb, rc => rc, c1 => c1,
        disp1 => disp_l, disp_s => disp_s,
        
        imm => imm, m1 => m1, 
        r_dest => r_dest, r_src => r_src,
        pc_address_out => pc_address_ifid
    );

    DECODER2: entity work.DecoderII
    port map (
        opcode, ra, rb, rc, r_dest, r_src, rd_index1, rd_index2
    );
    
    REGISTER_FILE: entity work.register_file
    port map (
        clk => clk,
        rst => rst,
        rd_index1 => rd_index1,
        rd_index2 => rd_index2,
        rd_data1 => rd_data1_idex,
        rd_data2 => rd_data2_idex,
        
        wr_index => wr_reg_index,
        wr_data => wr_data,
        wr_enable => wr_en
    );

    DECODER: entity work.decoder
    port map (
        rst_ex => rst, 
        clk => clk, 
        rst_ld => rst,
        OPCODE => opcode,
        alu_mode_out => alu_mode_idex,
        br_mode_out => br_mode_idex,
        mem_opr_out => mem_opr_idex,
        wb_opr_out => wb_opr_idex,
        br_active_out => br_active_idex,

        r_dest_in => r_dest,
        r_src_in => r_src,

        ra_in => ra,
        ra_out => ra_idex,

        shift_count_in => c1,
        shift_count_out => shift_count_idex,
        
        pc_address_in => pc_address_ifid,
        pc_address_out => pc_address_from_decoder,

        disp_l_in => disp_l,
        disp_s_in => disp_s,
        disp_out => disp_idex
    );

    PC_DELTA: entity work.DeltaComponent
    port map (
        clk => clk,
        data_in => pc_address_from_decoder,
        data_out => pc_address_idex
    );

    IDEX_PIPELINE: entity work.idex_pipeline
    -- IN - idex, OUT - output ports
    port map (
        clk => clk,		-- System clock
        rst => rst,		-- Reset pin
        enable => en,	-- Enable pin
        rd_data1 => rd_data1_idex,		-- Register data 1
        rd_data2 => rd_data2_idex,  	-- Register data 2
        alu_mode_in => alu_mode_idex,	-- ALU Mode
        br_mode_in => br_mode_idex,
        mem_opr_in => mem_opr_idex,	    -- Memory operand
        wb_opr_in => wb_opr_idex,		-- WB Operand
       
    	dr1_out => rd_data1_exec,	-- Register data 1
        dr2_out => rd_data2_exec, 	-- Register data 2

        alu_mode_out => alu_mode_exec,
        br_mode_out => br_mode_exec,
        mem_opr_out => mem_opr_exec,
        wb_opr_out => wb_opr_exec,
        
        ra_in => ra_idex,
        ra_out => ra_exec,

        shift_count_in => shift_count_idex,
        shift_count_out => shift_count_exec,

        pc_address_in => pc_address_idex,
        pc_address_out => pc_address_exec,

        br_active_in => br_active_idex,
        br_active_out => br_active_exec,

        disp_in => disp_idex,
        disp_out => disp_exec
    );

    -- TODO: Attach the execution stage here
    EXECUTE_STAGE: entity work.ExecutionStage
    port map (
        clk => clk, rst => rst, en => en,
        rd_data1 => rd_data1_exec,
        rd_data2 => rd_data2_exec,
        alu_mode => alu_mode_exec,
        shift_count => shift_count_exec,

        mem_opr => mem_opr_exec,
        wb_opr => wb_opr_exec, 
        ra => ra_exec,

        br_mode => br_mode_exec, disp => disp_exec,          -- Goes to Branch control unit
        br_enable => br_active_exec, 
        pc_address => pc_address_exec,

        br_address_to_pc => br_address_to_pc,
        br_enable_to_pc => br_enable_to_pc,

        alu_result_out => alu_result_mem,
        mem_addr_out => mem_addr_mem,
        mem_opr_out => mem_opr_mem,
        wb_opr_out => wb_opr_mem,
        ra_out => ra_mem
    );


end Behavioral;
