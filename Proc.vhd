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
        
        resultL_OUT : out std_logic_vector(15 downto 0); -- Lower 16 bits of result
        resultU_OUT : out std_logic_vector(15 downto 0) -- Upper 16 bits of result

    ); -- these get assigned in port maps as portmap(clk => CLOCK) to help wire between files
        -- inter file uses comments on bottom to declare.
end proc;


architecture Behavioral of proc is
    signal data_in_s: STD_LOGIC_VECTOR(15 downto 0);

    component ALU port(
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

    component register_file port(
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
--------------- Program counter ------------
    component PC is
        port ( 
            clk         : in STD_LOGIC;
            halt        : in STD_LOGIC;
            
            write_en    : in STD_LOGIC;
            reset_ex    : in STD_LOGIC;  
            reset_ld    : in STD_LOGIC;
            addr_asn    : in STD_LOGIC_VECTOR(15 downto 0);
            addr        : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;
    signal halt_s : STD_LOGIC := '0'; 
    signal write_en_s : STD_LOGIC := '1';  --, wr_data_s  WILL need to update hald and write en at somepoint.
    signal addr_asn_s, address_s: STD_LOGIC_VECTOR(15 downto 0);
    
    
    component ifid_pipeline_register is
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
        



------ START OF TEMP SIGNALS
        signal ALU_TEMP :  std_logic_vector(2 downto 0);
begin
    u1: register_file 
        port map(
            rst => RESET,
            clk => CLOCK,  --TO REASSIGN TO CLK_S OR SMTH
            rd_index1 => rb_s, 
            rd_index2 => rc_s, 
            rd_data1 => rd_data1_s, 
            rd_data2 => rd_data2_s, 
            wr_index => ra_s, --CHANGE TO RA_WB_S WHEN WRITE BACK IS FINISHED 
            wr_data => data_in_s, -- THIS TOO 
            wr_enable => write_en_s 
        );

    u2: ALU 
        port map( 
            alu_mode => ALU_TEMP, --alu_mode_s
            in1 => rd_data1_s, --in1_s,--in1 => rd_data1, 
            in2 => rd_data2_s, --in2_s,--in2 => rd_data2, -- replaced in1 and in2 
            resultU => resultU_s,
            resultL => resultL_s, 
            z_flag => z_flag_s, 
            n_flag => n_flag_s
        );    
        
    u3: PC 
        port map(
            clk => CLOCK,
            halt => halt_s,
            write_en => write_en_s,
            reset_ex => RESET,
            reset_ld => RESET,
            addr_asn => addr_asn_s,
            addr => address_s
        );
     u4: ifid_pipeline_register
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
            ALU_TEMP <= "001";
            --addr_asn_s <= x"0000";
            --address_OUT_IM <= address_s;
            resultU_OUT <= resultU_s;
            resultL_OUT <= resultL_s;  
            
       

    --end process;
end Behavioral;
