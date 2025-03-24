library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CONTROLLER_file is 
	port(
		--input signals
		rst: in std_logic;  
		clk: in std_logic;
		IR: in std_logic_vector(15 downto 0);  
		--output signal
		PC: out std_logic_vector(15 downto 0);
		out_val: out std_logic_vector(15 downto 0);


        ra_idx_IFID, ra_idx_IDEX, ra_idx_EXMEM, ra_idx_MEMWB, ra_idx_mux: out std_logic_vector(2 downto 0);
        ra_val_IFID, ra_val_IDEX, ra_val_EXMEM, ra_val_MEMWB:  out std_logic_vector(15 downto 0);
        
		--debugger 
		memory_injection: in std_logic_vector(15 downto 0) := X"0001";
		
		addr_out: out std_logic_vector(15 downto 0) 
		
	); -- Removed extra semicolon
end CONTROLLER_file;

architecture behavioural of CONTROLLER_file is
	component ALU_file port (
		--input signals
		in1: in std_logic_vector(15 downto 0); 
		in2: in std_logic_vector(15 downto 0); 
		--alu mode signal
		alu_mode: in std_logic_vector(2 downto 0);
		shift_count: in std_logic_vector(3 downto 0);
		rst : in std_logic; --clock
		clk: in std_logic;  --reset
		--output signals
		result: out std_logic_vector(15 downto 0); 
		z_flag: out std_logic; 
		n_flag: out std_logic;
		o_flag: out std_logic
	);
	end component;

	component PC_file port (
		--input signals
        brch_addr: in std_logic_vector(15 downto 0);  
        brch_en: in std_logic;
        rst: in std_logic;  
        clk: in std_logic;  
        --output signal
        NPC: out std_logic_vector(15 downto 0);
        CPC: out std_logic_vector(15 downto 0)
	);
	end component;

	component REGISTER_file port (
		rst : in std_logic; 
        clk: in std_logic;
        --read signals
        rd_index1, rd_index2 : in std_logic_vector(2 downto 0);
        rd_data1, rd_data2: out std_logic_vector(15 downto 0);
        --write signals
        wr_index: in std_logic_vector(2 downto 0);
        wr_data: in std_logic_vector(15 downto 0);
        wr_enable: in std_logic
	);
	end component;

	component decoder port (
		rst_ex : in std_logic; -- may need to change temporarily
		clk: in std_logic;
		rst_ld : in std_logic;
		OPCODE: in std_logic_vector(6 downto 0);
		alu_mode_out: out std_logic_vector(2 downto 0);
		mem_opr_out: out std_logic_vector(0 downto 0);
		wb_opr_out: out std_logic;
		ra_in: in std_logic_vector(2 downto 0);
    	ra_out: out std_logic_vector(2 downto 0);
    	shift_count_in: in std_logic_vector(3 downto 0);
    	shift_count_out: out std_logic_vector(3 downto 0) -- Added missing shift_count parameters
	); -- Removed extra semicolon and fixed parameter list
	end component;	

	component ifid_pipeline_register port (
    	clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable flow <ROUGH> (if the pipeline supports stalls)
        instr_in: in std_logic_vector(15 downto 0); -- Instruction from the memory/cache
        opcode: out std_logic_vector(6 downto 0) := (others => '0'); -- Opcode
        reg_wr_en: out std_logic;
       	ra: out std_logic_vector(2 downto 0);	-- Address of register A
        rb: out std_logic_vector(2 downto 0); 	-- Address of register B
        rc: out std_logic_vector(2 downto 0); 	-- Address of register C
        c1: out std_logic_vector(3 downto 0); 	-- Direct shift value
        disp1: out std_logic_vector(8 downto 0); -- Direct disp values
        disp_s: out std_logic_vector(5 downto 0);
        brch_en: out std_logic;
        imm: out std_logic_vector(7 downto 0);  -- Immediate values
        m1: out std_logic;						-- Grab upper/lower byte
        r_dest: out std_logic_vector(2 downto 0);	-- Destination register address
        r_src: out std_logic_vector(2 downto 0)		-- Source Register address
	);
	end component;	

	component idex_pipeline port (
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        rd_data1: in std_logic_vector(15 downto 0);		-- Register data 1
        rd_data2: in std_logic_vector(15 downto 0);  	-- Register data 2
        alu_mode_in: in std_logic_vector(2 downto 0);	-- ALU Mode
        shift_count_in: in std_logic_vector(3 downto 0); -- Added missing parameter
        mem_opr_in: in std_logic_vector(0 downto 0);	-- Memory operand
        wb_opr_in: in std_logic;						-- WB Operand
        dr1_out: out std_logic_vector(15 downto 0);		-- Register data 1
        dr2_out: out std_logic_vector(15 downto 0);  	-- Register data 2
        alu_mode_out: out std_logic_vector(2 downto 0);	-- ALU Mode
        shift_count_out: out std_logic_vector(3 downto 0); -- Added missing parameter
        mem_opr_out: out std_logic_vector(0 downto 0);	-- Memory operand
        wb_opr_out: out std_logic;
		ra_in: in std_logic_vector(2 downto 0);
        ra_out: out std_logic_vector(2 downto 0)			
	); -- Fixed parameter list
	end component;	

	component exmem_pipeline port (
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        alu_result_in_lower: in std_logic_vector(15 downto 0);
        mem_addr_in: in std_logic_vector(8 downto 0);
        mem_opr_in: in std_logic_vector(0 downto 0);			-- Memory operand
        wb_opr_in: in std_logic;								-- WB Operand
        alu_result_out_lower: out std_logic_vector(15 downto 0);		-- ALU Result (Lower half)
        mem_addr_out: out std_logic_vector(8 downto 0);
        mem_opr_out: out std_logic_vector(0 downto 0);			-- Memory operand
        wb_opr_out: out std_logic;
		ra_in: in std_logic_vector(2 downto 0);
        ra_out: out std_logic_vector(2 downto 0)		
	);
	end component;	

	component memwb_pipeline port (
        clk: in std_logic;		-- System clock
        rst: in std_logic;		-- Reset pin
        enable: in std_logic;	-- Enable pin
        mem_data_in: in std_logic_vector(15 downto 0);			-- Memory data
        alu_result_in_lower: in std_logic_vector(15 downto 0);	-- ALU Result
        wb_opr_in: in std_logic;		
		mem_opr_in: in std_logic_vector(0 downto 0);						-- WB Operand
        ra: in std_logic_vector(2 downto 0);					-- Register A address
        mem_data_out: out std_logic_vector(15 downto 0);
        alu_result_out_lower: out std_logic_vector(15 downto 0);	
        wb_opr_out: out std_logic;		
        ra_out: out std_logic_vector(2 downto 0)	
	);
	end component;	

	component mux port ( -- Renamed from duplicate memwb_pipeline
        A      : in  STD_LOGIC_VECTOR(2 downto 0);
        B      : in  STD_LOGIC_VECTOR(2 downto 0);
        sel    : in  STD_LOGIC;
        C      : out STD_LOGIC_VECTOR(2 downto 0)
	);
	end component;	
	
	component mux_pc is
        Port ( 
            A      : in  STD_LOGIC_VECTOR(15 downto 0);
            B      : in  STD_LOGIC_VECTOR(15 downto 0);
            sel    : in  STD_LOGIC;
            C      : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

	-- stubs
	signal enable: std_logic := '1'; -- Changed from "1" to '1'
	signal disp1:  std_logic_vector(8 downto 0); -- Direct disp values
	signal disp_s: std_logic_vector(5 downto 0);
	signal imm:  std_logic_vector(7 downto 0);  -- Immediate values
	signal m1:  std_logic;						-- Grab upper/lower byte
	signal r_dest: std_logic_vector(2 downto 0);	-- Destination register address
	signal r_src:  std_logic_vector(2 downto 0);	-- Source Register address, added semicolon

	-- IF/ID    	(currently handles wr_en for regfile writing)
	signal opcode: std_logic_vector(6 downto 0);
	
	-- FETCH
	signal brch_addr, CPC, NPC: std_logic_vector(15 downto 0);
	signal brch_en: std_logic;

	-- DECODE
	signal ra_idx, rb_idx, rc_idx: std_logic_vector(2 downto 0);
	signal ra_val, rb_val, rc_val: std_logic_vector(15 downto 0);
	signal wr_en: std_logic := '1'; -- Changed from "1" to '1'
	signal IFID_mem_opr : std_logic_vector(0 downto 0);
	signal IFID_wb_opr:  std_logic;
	signal IFID_alu_mode: std_logic_vector(2 downto 0);
	signal IFID_shift_count,IFID_shift_count_dec: std_logic_vector(3 downto 0);

	signal ra_idx_dec : std_logic_vector(2 downto 0);

	-- EXECUTE
	signal in1, in2, out1, IR_execute: std_logic_vector(15 downto 0);
	signal z_flag, n_flag, o_flag: std_logic; --stubbed for now
	signal IDEX_alu_mode: std_logic_vector(2 downto 0);
	signal IDEX_mem_opr : std_logic_vector(0 downto 0);
	signal IDEX_wb_opr:  std_logic;
	signal IDEX_shift_count: std_logic_vector(3 downto 0);
	
	-- MEMORY ACCESS
	signal mem_idx: std_logic_vector(8 downto 0); -- change size (stubbed)
	signal EX_MEM_mem_opr : std_logic_vector(0 downto 0);
	signal EX_MEM_wb_opr:  std_logic;
	signal EX_MEM_out: std_logic_vector(15 downto 0);
	signal EX_MEM_ra_idx : std_logic_vector(2 downto 0);
	signal EX_MEM_mem_idx : std_logic_vector(8 downto 0); -- change size (stubbed)

	-- WRITE BACK
	signal MEMWB_mem_idx: std_logic_vector(8 downto 0); -- change size (stubbed)
	signal IR_writeback, MEMWB_out, mem_data_snub: std_logic_vector(15 downto 0);
	signal MEMWB_mem_opr : std_logic_vector(0 downto 0);
	signal MEMWB_wb_opr:  std_logic;
	signal MEMWB_ra_idx : std_logic_vector(2 downto 0);

	signal ra_idx_wb : std_logic_vector(2 downto 0);
	signal ra_val_wb : std_logic_vector(15 downto 0);

	--WB mux
	signal ra2, ra_muxd: std_logic_vector(2 downto 0);
	signal ra_sel : std_logic := '0'; -- Changed from "0" to '0'
	
	
	--debugs
	--signal ra_idx_IFIDs, ra_idx_IDEXs, ra_idx_EXMEMs ,ra_idx_MEMWBs: std_logic_vector(2 downto 0);
    --signal ra_val_IFID,ra_val_IDEX,ra_val_EXMEMs,ra_val_MEMWBs:  std_logic_vector(15 downto 0);
    signal disp1_scale:  std_logic_vector(15 downto 0); -- Direct disp values
	begin
	PC_module : PC_file port map(brch_addr, brch_en, rst, clk, NPC, CPC);	
	PC_MUX: mux_pc port map(disp1_scale, CPC, brch_en, brch_addr); --configure disp_s later
	-- ra for WRITE only, rb, rc for READ only

	IFID: ifid_pipeline_register port map(clk, rst, enable, IR, opcode, wr_en, ra_idx, rb_idx, rc_idx, IFID_shift_count, disp1, disp_s,brch_en, imm, m1, r_dest, r_src);
	REGISTER_module: REGISTER_file port map(rst, clk, rb_idx, rc_idx, rb_val, rc_val, ra_muxd, ra_val_wb, wr_en);
	decoder_module: decoder port map(rst, clk, rst, opcode, IFID_alu_mode, IFID_mem_opr, IFID_wb_opr, ra_muxd, ra_idx_dec, IFID_shift_count, IFID_shift_count_dec); -- Added shift_count parameters

	IDEX: idex_pipeline port map(clk, rst, enable, rb_val, rc_val, IFID_alu_mode, IFID_shift_count_dec, IFID_mem_opr, IFID_wb_opr, in1, in2, IDEX_alu_mode, IDEX_shift_count, IDEX_mem_opr, IDEX_wb_opr, ra_idx_dec, EX_MEM_ra_idx);
	ALU_module: ALU_file port map(in1, in2, IDEX_alu_mode, IDEX_shift_count, rst, clk, out1, z_flag, n_flag, o_flag); -- Reordered parameters to match component declaration

	EXMEM: exmem_pipeline port map(clk, rst, enable, out1, mem_idx, IDEX_mem_opr, IDEX_wb_opr, EX_MEM_out, EX_MEM_mem_idx, EX_MEM_mem_opr, EX_MEM_wb_opr, EX_MEM_ra_idx, ra_idx_wb);
	-- ram to be placed here

	MEMWB: memwb_pipeline port map(clk, rst, enable, memory_injection, EX_MEM_out, EX_MEM_wb_opr, EX_MEM_mem_opr, ra_idx_wb, mem_data_snub, ra_val_wb, MEMWB_wb_opr, ra2);
	WB_MUX: mux port map(ra_idx, ra2, MEMWB_wb_opr, ra_muxd);
	
	

	process (clk) begin
		PC <= CPC;
		out_val <= ra_val_wb;
		
		ra_idx_IFID <= ra_idx; 
		ra_idx_mux <= ra_muxd;
		ra_idx_IDEX <= ra_idx_dec;
		ra_idx_EXMEM <= EX_MEM_ra_idx;
		ra_idx_MEMWB <= ra_idx_wb;
		
		ra_val_IFID <= ra_val_wb;
		ra_val_IDEX <= out1;
		ra_val_EXMEM <= EX_MEM_out;
		ra_val_MEMWB <= ra_val_wb;
		
		disp1_scale <= "0000000" & disp1;
		addr_out <= brch_addr; 
		
    end process;
 end behavioural;