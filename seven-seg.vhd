library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_display is
    Port ( 
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        display_num : in  STD_LOGIC_VECTOR(15 downto 0); -- number to be output to display
        seg         : out STD_LOGIC_VECTOR(6 downto 0);  -- 7 seg mapping pins
        dp          : out STD_LOGIC;                     -- decimal enable 
        an          : out STD_LOGIC_VECTOR(3 downto 0)   -- digit place select
    );
end seven_segment_display;

architecture Behavioral of seven_segment_display is
    signal byte1 : STD_LOGIC_VECTOR(3 downto 0);
    signal byte2 : STD_LOGIC_VECTOR(3 downto 0);
    signal byte3 : STD_LOGIC_VECTOR(3 downto 0);
    signal byte4 : STD_LOGIC_VECTOR(3 downto 0);
    
    signal refresh_counter : STD_LOGIC_VECTOR(19 downto 0); -- # clock speed / 2^n, 2 MSB bits preserved for digit select
                                                            -- causes each digit to update every (clock speed / 2^(n-2) seconds
    signal digit_selector : STD_LOGIC_VECTOR(1 downto 0);
    signal current_digit : STD_LOGIC_VECTOR(3 downto 0);
    
begin
    byte1 <= display_num(3 downto 0);
    byte2 <= display_num(7 downto 4);
    byte3 <= display_num(11 downto 8);
    byte4 <= display_num(15 downto 12);
    
    process(clk, rst)
    begin
        if rst = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(clk) then
            refresh_counter <= std_logic_vector(unsigned(refresh_counter) + 1);
        end if;
    end process;
    
    -- uses front 2 msb digits to select digit place
    digit_selector <= refresh_counter(19 downto 18);
    
    process(digit_selector, byte1, byte2, byte3, byte4)
    begin
        case digit_selector is
            when "00" =>
                current_digit <= byte1;
                an <= "1110"; -- Enable first digit (active low)
            when "01" =>
                current_digit <= byte2;
                an <= "1101"; -- Enable second digit
            when "10" =>
                current_digit <= byte3;
                an <= "1011"; -- Enable third digit
            when others =>
                current_digit <= byte4;
                an <= "0111"; -- Enable fourth digit
        end case;
    end process;
    
    process(current_digit)
    begin
        case current_digit is
            -- In segment order: abcdefg (common FPGA mapping)
            when "0000" =>
                seg <= "0000001"; -- 0
            when "0001" => 
                seg <= "1001111"; -- 1
            when "0010" => 
                seg <= "0010010"; -- 2
            when "0011" => 
                seg <= "0000110"; -- 3
            when "0100" => 
                seg <= "1001100"; -- 4
            when "0101" => 
                seg <= "0100100"; -- 5
            when "0110" =>
                seg <= "0100000"; -- 6
            when "0111" =>
                seg <= "0001111"; -- 7
            when "1000" =>
                seg <= "0000000"; -- 8
            when "1001" =>
                seg <= "0000100"; -- 9
            when "1010" =>
                seg <= "0001000"; -- A
            when "1011" =>
                seg <= "1100000"; -- B
            when "1100" =>
                seg <= "0110001"; -- C
            when "1101" =>
                seg <= "1000010"; -- D
            when "1110" =>
                seg <= "0110000"; -- E
            when "1111" =>
                seg <= "0111000"; -- F
            when others =>
                seg <= "1111111";
        end case;
    end process;
    
    
    dp <= '1'; -- no decimal place
    
end Behavioral;