library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    Port ( 
        A      : in  STD_LOGIC_VECTOR(15 downto 0);
        B      : in  STD_LOGIC_VECTOR(15 downto 0);
        sel    : in  STD_LOGIC;
        C      : out STD_LOGIC_VECTOR(15 downto 0)
    );
end mux;

architecture Behavioral of mux is
begin
    process(A, B, sel)
    begin
        if (sel = '0') then
            C <= A;
        else
            C <= B;
        end if;
    end process;
    
    -- Alternative concurrent statement approach:
    -- C <= A when sel = '0' else B;
end Behavioral;