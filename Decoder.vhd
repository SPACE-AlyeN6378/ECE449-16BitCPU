library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity decoder is
port(
    rst_ex : in std_logic; -- may need to change temporarily
    clk: in std_logic;
    rst_ld : in std_logic;
    OPCODE: in std_logic_vector(6 downto 0);
    alu_mode_out: out std_logic_vector(2 downto 0);
    mem_opr_out: out std_logic_vector(0 downto 0);
    wb_opr_out: out std_logic
);
end decoder;

architecture behavioural of decoder is
    type state_type is (RESET_EX, RESET_LD, DECODE);
    signal current_state, next_state : state_type;
    
    signal alu_mode : std_logic_vector(2 downto 0);
    signal mem_opr : std_logic_vector(0 downto 0);
    signal wb_opr : std_logic;
    
    constant NOP : std_logic_vector(6 downto 0) := "0000000";
    constant ADD: std_logic_vector(6 downto 0) := "0000001";
    constant SUB: std_logic_vector(6 downto 0) := "0000010";
    constant MUL: std_logic_vector(6 downto 0) := "0000011";
    constant NAND_OP: std_logic_vector(6 downto 0) := "0000100";
    constant SHL: std_logic_vector(6 downto 0) := "0000101";
    constant SHR  : std_logic_vector(6 downto 0) := "0000110";
    constant TEST : std_logic_vector(6 downto 0) := "0000111";
    constant OUT_OP: std_logic_vector(6 downto 0) := "0100000";
    constant IN_OP: std_logic_vector(6 downto 0) := "0100001";
    constant LOAD: std_logic_vector(6 downto 0) := "0010000";
    constant STORE: std_logic_vector(6 downto 0) := "0010001";
    constant LOADIMM: std_logic_vector(6 downto 0) := "0010010";
    constant MOV : std_logic_vector(6 downto 0) := "0010011";
    
begin
    alu_mode_out <= alu_mode;
    mem_opr_out <= mem_opr;
    wb_opr_out <= wb_opr;
    
    process(clk, rst_ex, rst_ld)
    begin
        if rst_ex = '1' then
            current_state <= RESET_EX;
        elsif rst_ld = '1' then
            current_state <= RESET_LD;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    process(current_state, OPCODE)
    begin
        alu_mode <= "000";
        mem_opr <= "0";
        wb_opr <= '0';
        next_state <= current_state;
        
        case current_state is
            when RESET_EX =>
                alu_mode <= "000";
                mem_opr <= "0";
                wb_opr <= '0';
                next_state <= DECODE;
                
            when RESET_LD =>
                alu_mode <= "000";
                mem_opr <= "0";
                wb_opr <= '0';
                next_state <= DECODE;
                
            when DECODE =>
                case OPCODE is
                    when NOP =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        
                    when ADD =>
                        alu_mode <= "001";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when SUB =>
                        alu_mode <= "010";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when MUL =>
                        alu_mode <= "011";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when NAND_OP =>
                        alu_mode <= "100";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when SHL =>
                        alu_mode <= "101";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when SHR =>
                        alu_mode <= "110";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when TEST =>
                        alu_mode <= "111";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        
                    when LOAD =>
                        alu_mode <= "000";
                        mem_opr <= "1";
                        wb_opr <= '1';
                        
                    when STORE =>
                        alu_mode <= "000";
                        mem_opr <= "1";
                        wb_opr <= '0';
                        
                    when LOADIMM =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when MOV =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when IN_OP =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '1';
                        
                    when OUT_OP =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        
                    when others =>
                        alu_mode <= "000";
                        mem_opr <= "0";
                        wb_opr <= '0';
                        
                end case;
                
                next_state <= DECODE;
                
            when others =>
                next_state <= RESET_EX;
                
        end case;
    end process;
    
end behavioural;
