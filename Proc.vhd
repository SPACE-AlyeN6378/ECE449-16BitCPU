library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity proc is 
    port(
        RESET : in std_logic; -- only for Register file
        CLOCK: in std_logic;
        
        data_in : in std_logic_vector(15 downto 0);
        
        enable_in: in std_logic;
        enable_out: out std_logic;       
        
        resultL_OUT : out std_logic_vector(15 downto 0); -- Lower 16 bits of result
        resultU_OUT : out std_logic_vector(15 downto 0) -- 

    ); -- these get assigned in port maps as portmap(clk => CLOCK) to help wire between files
        -- inter file uses comments on bottom to declare.
end proc;


architecture Behavioral of proc is
        signal data_in_s: STD_LOGIC_VECTOR(15 downto 0);
        signal data_throughput_s: STD_LOGIC_VECTOR(15 downto 0);

    component ALU 
        port(
            --rst :       in std_logic;
            -- note: alu_mode may need some serious padding to get to opcode A Length
            -- or make an overflow address here? how do i handle upper register lol
            alu_mode:   in std_logic_vector(2 downto 0);
            in1, in2:   in std_logic_vector(15 downto 0);
    
            resultL : out std_logic_vector(15 downto 0); -- Lower 16 bits of result
            resultU : out std_logic_vector(15 downto 0); -- Upper 16 bits of result
    
            z_flag :    out std_logic;
            n_flag :    out std_logic  
        );
    end component;
        signal resultL_s, resultU_s: STD_LOGIC_VECTOR(15 downto 0);
        signal z_flag_s, n_flag_s: STD_LOGIC;

--------Reg file----------------    

    component register_file 
        port(
            rst : in std_logic;
            clk : in std_logic;
            
            rd_index1, rd_index2: in std_logic_vector(2 downto 0);
            rd_data1, rd_data2: out std_logic_vector(15 downto 0); 
            
            wr_index: in std_logic_vector(2 downto 0); 
            wr_data: in std_logic_vector(15 downto 0);
            wr_enable: in std_logic
        );
    end component;
        signal rd_data1_s, rd_data2_s: std_logic_vector(15 downto 0);  --, wr_data_s 
        signal write_en_s: std_logic;
    
-------- Decoder ----------------  
    component decoder
        port(
            rst_ex : in std_logic; -- may need to change temporarily
            clk: in std_logic;
            rst_ld : in std_logic;
            
            OPCODE: in std_logic_vector(6 downto 0);
            alu_mode_out: out std_logic_vector(2 downto 0);
            mem_opr_out: out std_logic_vector(0 downto 0);
            wb_opr_out: out std_logic
        );
    end component;

------- IF/ID Reg ---------------- 
    component ifid_pipeline_register 
            port ( 
                clk: in std_logic;		-- System clock
                rst: in std_logic;        -- Reset pin
                enable: in std_logic;    -- Enable flow <ROUGH> (if the pipeline supports stalls)
                
                -- INSTRUCTION INPUT
                instr_in: in std_logic_vector(15 downto 0); -- Instruction from the memory/cache
                
                -- OUTPUTS
                opcode: out std_logic_vector(6 downto 0) := (others => '0'); -- Opcode
            
                -- Format A1/A3
                ra: out std_logic_vector(2 downto 0);    -- Address of register A
                rb: out std_logic_vector(2 downto 0);     -- Address of register B
                rc: out std_logic_vector(2 downto 0);     -- Address of register C
                
                -- Format A2
                c1: out std_logic_vector(3 downto 0);     -- Direct shift value
                
                -- Format B1-B2
                disp1: out std_logic_vector(8 downto 0); -- Direct disp values
                disp_s: out std_logic_vector(5 downto 0);
                
                -- Format L1 and L2 (LOAD/STORE/MOV)
                imm: out std_logic_vector(7 downto 0);  -- Immediate values
                m1: out std_logic;                        -- Grab upper/lower byte
                r_dest: out std_logic_vector(2 downto 0);    -- Destination register address
                r_src: out std_logic_vector(2 downto 0)

            );
        end component;
        signal ifid_en_s, m1_s: std_logic;
        signal ra_s, rb_s, rc_s, r_dest_s, r_src_s: std_logic_vector(2 downto 0);
        signal c1_s: std_logic_vector(3 downto 0);
        signal disp1_s:std_logic_vector(8 downto 0);
        signal disp_s_s:std_logic_vector(5 downto 0);
        signal imm_s:std_logic_vector(7 downto 0);
        signal instr_in_s : std_logic_vector(15 downto 0);
        signal opcode_s :  std_logic_vector(6 downto 0);
        
-------- ID/EX Reg --------------
    component idex_pipeline 
                port ( 
                    clk: in std_logic;        -- System clock
                    rst: in std_logic;        -- Reset pin
                    enable: in std_logic;    -- Enable flow <ROUGH> (if the pipeline supports stalls)
                    
                    -- INSTRUCTION INPUT
                    -- Inputs from the Register file and the controller
                    rd_data1: in std_logic_vector(15 downto 0);        -- Register data 1
                    rd_data2: in std_logic_vector(15 downto 0);      -- Register data 2
                    alu_mode_in: in std_logic_vector(2 downto 0);    -- ALU Mode
                    mem_opr_in: in std_logic_vector(0 downto 0);    -- Memory operand
                    wb_opr_in: in std_logic;                        -- WB Operand
                    
                    dr1_out: out std_logic_vector(15 downto 0);        -- Register data 1 TO ALU
                    dr2_out: out std_logic_vector(15 downto 0);      -- Register data 2   TO ALU
                    alu_mode_out: out std_logic_vector(2 downto 0);    -- ALU Mode
                    mem_opr_out: out std_logic_vector(0 downto 0);    -- Memory operand
                    wb_opr_out: out std_logic                        -- Write-back Operand
                );
            end component;
        signal idex_en_s: std_logic;
        signal alu_mode_in_s, alu_mode_out_s: std_logic_vector(2 downto 0); -- rememebr 
        signal mem_opr_idex_s: std_logic_vector(0 downto 0); -- WIRE FROM DECODER
        signal wb_opr_idex_s: std_logic;                     -- WIRE FROM DECODER
        
        signal dr1_out_s:  std_logic_vector(15 downto 0);        -- Register data 1 TO ALU
        signal dr2_out_s:  std_logic_vector(15 downto 0);

-------- EX/MEM Reg --------------
   component exmem_pipeline 
                port ( 
                    clk: in std_logic;		-- System clock
                    rst: in std_logic;        -- Reset pin
                    enable: in std_logic;    -- Enable pin
                    
                    -- Inputs from the Register file and the controller
                    alu_result_in_upper: in std_logic_vector(15 downto 0);        -- ALU Result
                    alu_result_in_lower: in std_logic_vector(15 downto 0);
                    mem_addr_in: in std_logic_vector(8 downto 0);
                    mem_opr_in: in std_logic_vector(0 downto 0);            -- Memory operand
                    wb_opr_in: in std_logic;                                -- WB Operand
                    
                    
                    alu_result_out_upper: out std_logic_vector(15 downto 0);        -- ALU Result (Upper half)
                    alu_result_out_lower: out std_logic_vector(15 downto 0);        -- ALU Result (Lower half)
                    mem_addr_out: out std_logic_vector(8 downto 0);
                    mem_opr_out: out std_logic_vector(0 downto 0);            -- Memory operand
                    wb_opr_out: out std_logic                                -- WB Operand
                );
            end component;
        signal mem_opr_exmem_s, mem_en_s : std_logic_vector (0 downto 0);
        signal wb_opr_exmem_s, wb_opr_memwb_s : std_logic;
        signal exmem_en_s : std_logic;
        signal mem_addr_in_exmem_s :  std_logic_vector(8 downto 0);
        signal exmem_AR_U_s, exmem_AR_L_s: std_logic_vector(15 downto 0); --from alu result out of ex_mem 
        signal mem_addr_s : std_logic_vector(8 downto 0);
        
   component memwb_pipeline 
                port ( 
                    -- CORE INPUTS
                    clk: in std_logic;        -- System clock
                    rst: in std_logic;        -- Reset pin
                    enable: in std_logic;    -- Enable pin
                    
                    -- Inputs from the Memory and the EX/MEM
                    mem_data_in: in std_logic_vector(15 downto 0);            -- Memory data
                    alu_result_in_lower: in std_logic_vector(15 downto 0);    -- ALU Result
                    wb_opr_in: in std_logic;                                -- WB Operand
                    ra: in std_logic_vector(2 downto 0);                    -- Register A address
                    
                    mem_data_out: out std_logic_vector(15 downto 0);
                    alu_result_out_lower: out std_logic_vector(15 downto 0);    
                    wb_opr_out: out std_logic;        
                    ra_out: out std_logic_vector(2 downto 0)                             -- WB Operand
                );
            end component;
       signal ra_wb_s : std_logic_vector(2 downto 0); -- ra index back to wr index of reg file
       signal mem_data_out_s, mem_data_s : std_logic_vector(15 downto 0);
       signal wb_en_s : std_logic;
       
begin

    u1: register_file 
        port map(
            rst => RESET,
            clk => CLOCK,  --TO REASSIGN TO CLK_S OR SMTH
            rd_index1 => rb_s, 
            rd_index2 => rc_s, 
            rd_data1 => rd_data1_s, 
            rd_data2 => rd_data2_s, 
            wr_index => ra_wb_s,
            wr_data => data_throughput_s, -- THIS TOO 
            wr_enable => write_en_s 
        );

    u2: ALU 
        port map( 
            alu_mode => alu_mode_out_s,
            in1 => dr1_out_s, --in1_s,--in1 => rd_data1, 
            in2 => dr2_out_s, --in2_s,--in2 => rd_data2, -- replaced in1 and in2 
            resultU => resultU_s,
            resultL => resultL_s, 
            z_flag => z_flag_s, 
            n_flag => n_flag_s
        );    
        
    u3: ifid_pipeline_register
        port map(
            clk => CLOCK,
            rst => RESET,
            enable => ifid_en_s,
            instr_in => data_in_s,
            opcode => opcode_s,
            ra => ra_s,
            rb => rb_s,
            rc => rc_s,
            c1 => c1_s,
            disp1 => disp1_s,
            disp_s => disp_s_s,
            imm => imm_s,
            m1 => m1_s,
            r_dest => r_dest_s,
            r_src => r_src_s
        );
        
    u4: idex_pipeline
       port map(
           clk => CLOCK,
           rst => RESET,
           enable => idex_en_s, -- where does this get enabled from???
           rd_data1 => rd_data1_s,
           rd_data2 => rd_data2_s,
           alu_mode_in => alu_mode_in_s, -- from decoder
           mem_opr_in => mem_opr_idex_s,
           wb_opr_in => wb_opr_idex_s,
           dr1_out => dr1_out_s,
           dr2_out => dr2_out_s,
           alu_mode_out => alu_mode_out_s,
           mem_opr_out => mem_opr_exmem_s, -- mem_opr_exmem_s
           wb_opr_out => wb_opr_exmem_s --wb_opr_exmem_s
       );
       
    u5: exmem_pipeline
        port map(
            clk => CLOCK,
            rst => RESET,
            enable => exmem_en_s, -- where does this get enabled from???
            alu_result_in_upper => resultU_s,
            alu_result_in_lower => resultL_s,
            mem_addr_in => mem_addr_in_exmem_s, -- set signal to all zeros 
            mem_opr_in => mem_opr_exmem_s,
            wb_opr_in => wb_opr_exmem_s,
            alu_result_out_upper => exmem_AR_U_s,
            alu_result_out_lower => exmem_AR_L_s,
            mem_addr_out => mem_addr_s, -- stub it like vvvv
            mem_opr_out => mem_en_s, -- to memory access (maybe just leave as stub for now)
            wb_opr_out => wb_opr_memwb_s
      );
          
    u6: memwb_pipeline
        port map(
            clk => CLOCK,
            rst => RESET,
            enable => wb_en_s,
            mem_data_in => mem_data_s, -- stub this (1 port wire)
            alu_result_in_lower => exmem_AR_L_s, 
            --TODO IMPLEMENT ALU_RESULT_UPPER
            wb_opr_in => wb_opr_memwb_s,
            ra => ra_s, -- from if/id     
            mem_data_out => mem_data_out_s, -- stub this for now, we dont know hwo to handle it
            alu_result_out_lower => data_throughput_s, -- to reg file wr_data
            wb_opr_out => write_en_s,
            ra_out => ra_wb_s -- to reg file
    );
        
    u7: decoder
        port map(
            rst_ex => RESET,
            clk => CLOCK,
            rst_ld => RESET,
            OPCODE => opcode_s,
            alu_mode_out => alu_mode_in_s, -- to id/ex
            mem_opr_out => mem_opr_idex_s,
            wb_opr_out => wb_opr_idex_s
        );
            --ALU_TEMP <= "001";
            --addr_asn_s <= x"0000";
            --address_OUT_IM <= address_s;
            
            resultU_OUT <= data_throughput_s; -- to reg file AND output
            resultL_OUT <=  resultU_s;  -- resultU from exmem gets snubbed, will have to figure out what to do with the size (or number of) alu result registers. 

end Behavioral;
