library ieee;
use ieee.std_logic_1164.all;
-- use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity DecoderII is
port (
    opcode: in std_logic_vector(6 downto 0);
    ra: in std_logic_vector(2 downto 0);
    rb: in std_logic_vector(2 downto 0);
    rc: in std_logic_vector(2 downto 0);
    r_dest: in std_logic_vector(2 downto 0);
    r_src: in std_logic_vector(2 downto 0);

    rd_index1: out std_logic_vector(2 downto 0);
    rd_index2: out std_logic_vector(2 downto 0)
);
end DecoderII;

architecture Behavioral of DecoderII is

    -- ************* PREDEFINED OPCODES *************
    -- B-Format
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
    -- **********************************************
begin
    process(opcode) begin

        -- If absolute branching is used, read the value stored in R[ra]
        if (opcode = BR) or (opcode = BR_N) or (opcode = BR_Z) or (opcode = BR_SUB) then
            rd_index1 <= ra;
            rd_index2 <= rc;
            
        -- If returning from the subroutine, read the value stored in R7
        elsif (opcode = RETURN_OP) then
            rd_index1 <= "111";
            rd_index2 <= rc;
            
        -- If loading the data from the memory, we retrieve the memory address stored in the register
        elsif (opcode = LOAD) then
            rd_index1 <= rb;
            rd_index2 <= r_src;     -- r_data2 is used as a memory address
            
        -- If storing the r_src data to the memory,
        elsif (opcode = STORE) then
            rd_index1 <= r_src;     -- Straight through the ALU
            rd_index2 <= r_dest;
            
        -- If moving data from one register to another
        elsif (opcode = MOV) then
            rd_index1 <= r_src;     -- Straight through the ALU
            rd_index2 <= rc;
            
        -- Otherwise
        else
            rd_index1 <= rb;
            rd_index2 <= rc;
            
        end if;

    end process;
end Behavioral;