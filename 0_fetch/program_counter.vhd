-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
	port (
    	-- Core Input
    	clk: std_logic; rst: std_logic;
        
        -- Input signals
        br_address_in: in std_logic_vector(8 downto 0);
        en: in std_logic;
        branch_active: in std_logic;
        
        -- Output signal
        address_out: out std_logic_vector(8 downto 0)
    );
end ProgramCounter;

architecture behavioural of ProgramCounter is
	
-- PC Signal
signal address: std_logic_vector(8 downto 0) := (others => '1');
signal prev_br_address: std_logic_vector(8 downto 0);

begin
	process (clk) begin
    -- Rising edge
    if (rst = '1') then
       	address <= (others => '0');
        prev_br_address <= (others => '0');
        
    elsif (clk = '0' and clk'event) then
        if (en = '1') then
              -- New Branch address has been detected
              if (br_address_in /= prev_br_address) then
                  prev_br_address <= br_address_in;
                  address <= br_address_in;
              elsif (branch_active = '1') then
                  -- Maintain loop behavior when branch input is reset
                  address <= prev_br_address;
              else
                  -- Normal incrementing behavior
                  address <= std_logic_vector(unsigned(address) + 2);
              end if;
        end if;
    end if;
    
end process;

-- Output assignment
address_out <= address;

end behavioural;
