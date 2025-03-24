library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity decoder is
port(
    rst_ex : in std_logic; -- may need to change temporarily
    clk: in std_logic;
    rst_ld : in std_logic;
    OPCODE: in std_logic_vector(6 downto 0);

    alu_mode_out: out std_logic_vector(2 downto 0);
    mem_opr_out: out std_logic_vector(0 downto 0);
    wb_opr_out: out std_logic;
    br_active_out: out std_logic;
    br_mode_out : out std_logic_vector(2 downto 0);

    -- Other incoming signals from the IF/ID pipeline
    ra_in: in std_logic_vector(2 downto 0);
    ra_out: out std_logic_vector(2 downto 0);

    shift_count_in : in std_logic_vector(3 downto 0);
    shift_count_out : out std_logic_vector(3 downto 0);

    pc_address_in : in std_logic_vector(8 downto 0);
    pc_address_out : out std_logic_vector(8 downto 0);

    disp_l_in: in std_logic_vector(8 downto 0);
    disp_s_in: in std_logic_vector(5 downto 0);
    disp_out: out std_logic_vector(8 downto 0)
); 
end decoder;

architecture behavioural of decoder is
    type state_type is (RESET_EX, RESET_LD, DECODE);
    signal current_state, next_state : state_type;
    
    signal alu_mode : std_logic_vector(2 downto 0);
    signal mem_opr : std_logic_vector(0 downto 0);
    signal wb_opr : std_logic; -- wb enable and reg enable
    signal br_active : std_logic;   -- activate branch
    signal disp : std_logic_vector(8 downto 0);
    signal br_mode : std_logic_vector(2 downto 0);
    
    -- No operation
    constant NOP : std_logic_vector(6 downto 0) := "0000000";

    -- A-Format
    constant ADD: std_logic_vector(6 downto 0) := "0000001";
    constant SUB: std_logic_vector(6 downto 0) := "0000010";
    constant MUL: std_logic_vector(6 downto 0) := "0000011";
    constant NAND_OP: std_logic_vector(6 downto 0) := "0000100";
    constant SHL: std_logic_vector(6 downto 0) := "0000101";
    constant SHR  : std_logic_vector(6 downto 0) := "0000110";
    constant TEST : std_logic_vector(6 downto 0) := "0000111";
    constant OUT_OP: std_logic_vector(6 downto 0) := "0100000";
    constant IN_OP: std_logic_vector(6 downto 0) := "0100001";

    -- B-Format
    constant BRR: std_logic_vector(6 downto 0) := "1000000";
    constant BRR_N: std_logic_vector(6 downto 0) := "1000001";
    constant BRR_Z: std_logic_vector(6 downto 0) := "1000010";
    constant BR: std_logic_vector(6 downto 0) := "1000011";
    constant BR_N: std_logic_vector(6 downto 0) := "1000100";
    constant BR_Z: std_logic_vector(6 downto 0) := "1000101";
    constant BR_SUB: std_logic_vector(6 downto 0) := "1000110";
    constant RETURN_OP: std_logic_vector(6 downto 0) := "1000111";

    -- L-Format
    constant LOAD: std_logic_vector(6 downto 0) := "0010000";
    constant STORE: std_logic_vector(6 downto 0) := "0010001";
    constant LOADIMM: std_logic_vector(6 downto 0) := "0010010";
    constant MOV : std_logic_vector(6 downto 0) := "0010011";
    
begin

    process(clk, rst_ex, rst_ld)
    begin
        if rst_ex = '1' then
            current_state <= RESET_EX;
        elsif rst_ld = '1' then
            current_state <= RESET_LD;
        elsif rising_edge(clk) then
            current_state <= next_state;
            
            -- Address A assignment (register address will always be 7 if return)
            if (opcode = BR_SUB or opcode = LOADIMM) then
                ra_out <= "111";
            else
                ra_out <= ra_in;
            end if;

            shift_count_out <= shift_count_in;
            pc_address_out <= pc_address_in;
            alu_mode_out <= alu_mode;
            mem_opr_out <= mem_opr;
            wb_opr_out <= wb_opr;
            br_active_out <= br_active;
            disp_out <= disp;
            br_mode_out <= br_mode;
            
        end if;
    end process;
    
    process(current_state, OPCODE, disp_s_in, disp_l_in)
    begin
        alu_mode <= "000";
        br_mode <= "000";
        mem_opr <= "0";
        wb_opr <= '0';
        br_active <= '0';
        disp <= (others => '0');

        next_state <= current_state;
        
        case current_state is
            when RESET_EX =>
                alu_mode <= "000";
                br_mode <= "000";
                mem_opr <= "0";
                wb_opr <= '0';
                br_active <= '0';
                disp <= (others => '0');
                next_state <= DECODE;
                
            when RESET_LD =>
                alu_mode <= "000";
                br_mode <= "000";
                mem_opr <= "0";
                wb_opr <= '0';
                br_active <= '0';
                disp <= (others => '0');
                next_state <= DECODE;

            when DECODE =>
                case OPCODE is
                    when NOP =>
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when ADD =>
                        alu_mode <= "001";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when SUB =>
                        alu_mode <= "010";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when MUL =>
                        alu_mode <= "011";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when NAND_OP =>
                        alu_mode <= "100";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when SHL =>
                        alu_mode <= "101";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when SHR =>
                        alu_mode <= "110";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                        
                    when TEST =>
                        alu_mode <= "111";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '0';
                        disp <= (others => '0');
                         
                    -- B-Format
                    when BRR => 
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= disp_l_in;
                        
                    when BRR_N =>
                        alu_mode <= "000";
                        br_mode <= "001";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= disp_l_in;
                        
                    when BRR_Z =>
                        alu_mode <= "000";
                        br_mode <= "010";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= disp_l_in;
                        
                    when BR =>
                        alu_mode <= "000";
                        br_mode <= "011";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= "000" & disp_s_in;
                        
                    when BR_N =>
                        alu_mode <= "111";
                        br_mode <= "100";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= "000" & disp_s_in;
                         
                    when BR_Z =>
                        alu_mode <= "111";
                        br_mode <= "101";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= "000" & disp_s_in;
                    
                    when BR_SUB =>
                        alu_mode <= "000";
                        br_mode <= "110";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '1';
                        disp <= "000" & disp_s_in;
                         
                    when RETURN_OP =>
                        alu_mode <= "001";
                        br_mode <= "111";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '1';
                        disp <= (others => '0');
            
                    when LOAD =>
                        alu_mode <= "111";
                        br_mode <= "000";
                        mem_opr <= "1";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when STORE =>
                        alu_mode <= "111";
                        br_mode <= "000";
                        mem_opr <= "1";
                        wb_opr <= '0';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when LOADIMM =>
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when MOV =>
                        alu_mode <= "111";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when IN_OP =>
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when OUT_OP =>
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0'; -- temp
                        br_active <= '0';
                        disp <= (others => '0');
                        
                    when others =>
                        alu_mode <= "000";
                        br_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        br_active <= '0';
                        disp <= (others => '0');
                        
                end case;


                
                next_state <= DECODE;
                
            when others =>
                next_state <= RESET_EX;
        end case;
        -- DEBUG
        -- ra_out <= ra_in;
        -- shift_count_out <= shift_count_in;
        -- pc_address_out <= pc_address_in;
        
    end process;
    
end behavioural;