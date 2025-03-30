-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DeltaComponent is
    port (
        -- CORE INPUTS
        clk: in std_logic;
        data_in: in std_logic_vector(8 downto 0);
        data_out: out std_logic_vector(8 downto 0)
    );

end DeltaComponent;

architecture behavioural of DeltaComponent is
    begin
        process(clk, data_in)
        
        begin
            if rising_edge(clk) then
                data_out <= data_in;
            end if;
        end process;
    end behavioural;