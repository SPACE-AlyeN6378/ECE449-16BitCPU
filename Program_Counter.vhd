library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

------------------ uses instruction fetch
-- PC is the only object to write into ram?
entity PC is
    port ( 
        clk         : in STD_LOGIC;
        halt        : in STD_LOGIC;
        write_en    : in STD_LOGIC;
        reset_ex    : in STD_LOGIC;  
        reset_ld    : in STD_LOGIC;
        addr_asn    : in STD_LOGIC_VECTOR(15 downto 0); -- in addr
        addr     : out STD_LOGIC_VECTOR(15 downto 0) -- out addr
    );
end PC;

architecture Behavioral of PC is

    signal addr_buffer: STD_LOGIC_VECTOR(15 downto 0);
    
begin
    process(clk, addr_buffer)
        begin
            if(reset_ex = '1') then
                addr_buffer <= x"0000";                
            elsif(reset_ld = '1') then
                addr_buffer <= x"0002"; -- alt value until further thoughts   please change kaz
            elsif(RISING_EDGE(clk))then -- the concat ensures evenness for address alignment, 
                if ( write_en = '1' ) then
                    addr_buffer <= addr_asn(15 downto 1) & '0';
                elsif ( halt /= '1' ) then
                    addr_buffer <= STD_LOGIC_VECTOR(UNSIGNED(addr_asn) + 2 ); -- go to next instruction
                end if;
            end if;
        addr <= addr_buffer;
    end process;
end Behavioral;
------------------------------------ end of program counter --------------------------------\




--
--begin
--    process(clk, addr_buffer)
--        begin  
--            if(opcode = "0001" OR "0010" OR "0101") then -- "A1" 
--                bits(8-6) of inputregister => ra_out
--                bits(5-3) of inputregister => rb_out 
--                bits(2-0) of inputregister => rc_out  
--            elsif(opcode = "0001" OR "0010" OR "0101") then -- "A2" 
--                bits(8-6) of inputregister => ra_out
--                bits(3-0) of inputregister => c1_out
--            elsif(opcode = "32") then -- "A3" 
--                bits(8-6) of inputregister => ra_out
                
                                
                



