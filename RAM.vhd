Library xpm;
use xpm.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use this file after A format prez
entity DPDISTRAM is
    port( -- a -> r/w     b -> r/o
        dina : in std_logic_vector(15 downto 0);
        addra : in std_logic_vector(8 downto 0);    -- Address of the input data
        addrb : in std_logic_vector(8 downto 0);    -- Address of the instruction
        wea : in std_logic_vector(0 downto 0);      -- mem_opr
        
        clka: in STD_LOGIC;
        rsta: in STD_LOGIC;
        rstb: in STD_LOGIC;
        ena: in STD_LOGIC;
        enb: in STD_LOGIC;
        
        douta : out std_logic_vector(15 downto 0);  -- Output data
        doutb : out std_logic_vector(15 downto 0)   -- Output instruction
    );
end DPDISTRAM;

architecture behavioral of DPDISTRAM is
begin
      xpm_memory_dpdistram_inst : xpm_memory_dpdistram
      generic map (
    
        -- Common module generics
        MEMORY_SIZE             => 8912,           --positive integer
        CLOCKING_MODE           => "common_clock", --string; "common_clock", "independent_clock" 
        MEMORY_INIT_FILE        => "none",         --string; "none" or "<filename>.mem" 
        MEMORY_INIT_PARAM       => "",             --string;
        USE_MEM_INIT            => 1,              --integer; 0,1
        MESSAGE_CONTROL         => 0,              --integer; 0,1
        USE_EMBEDDED_CONSTRAINT => 0,              --integer: 0,1
        MEMORY_OPTIMIZATION     => "true",          --string; "true", "false" 
    
        -- Port A module generics
        WRITE_DATA_WIDTH_A      => 16,             --positive integer
        READ_DATA_WIDTH_A       => 16,             --positive integer
        BYTE_WRITE_WIDTH_A      => 16,             --integer; 8, 9, or WRITE_DATA_WIDTH_A value
        ADDR_WIDTH_A            => 9,              --positive integer
        READ_RESET_VALUE_A      => "0000000000000000",            --string
        READ_LATENCY_A          => 0,              --non-negative integer
    
        -- Port B module generics
        READ_DATA_WIDTH_B       => 16,             --positive integer
        ADDR_WIDTH_B            => 9,              --positive integer
        READ_RESET_VALUE_B      => "0000000000000000",            --string
        READ_LATENCY_B          => 0               --non-negative integer
      )
      port map (
    
      douta => douta,                   -- READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
               doutb => doutb,                   -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
               addra => addra,                   -- ADDR_WIDTH_A-bit input: Address for port A write and read operations.
               addrb => addrb,                   -- ADDR_WIDTH_B-bit input: Address for port B write and read operations.
               clka => clka,                     -- 1-bit input: Clock signal for port A. Also clocks port B when parameter
                                                 -- CLOCKING_MODE is "common_clock".
               clkb => '0',                     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                                 -- "independent_clock". Unused when parameter CLOCKING_MODE is "common_clock".
               dina => dina,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
               ena => ena,                       -- 1-bit input: Memory enable signal for port A. Must be high on clock cycles when read
                                                 -- or write operations are initiated. Pipelined internally.
               enb => enb,                       -- 1-bit input: Memory enable signal for port B. Must be high on clock cycles when read
                                                 -- or write operations are initiated. Pipelined internally.
               regcea => '1',                 -- 1-bit input: Clock Enable for the last register stage on the output data path.
               regceb => '1',                 -- 1-bit input: Do not change from the provided value.
               rsta => rsta,                     -- 1-bit input: Reset signal for the final port A output register stage. Synchronously
                                                 -- resets output port douta to the value specified by parameter READ_RESET_VALUE_A.
               rstb => rstb,                     -- 1-bit input: Reset signal for the final port B output register stage. Synchronously
                                                 -- resets output port doutb to the value specified by parameter READ_RESET_VALUE_B.
               wea => wea                      -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input data port dina. 1
                                                 -- bit wide when word-wide writes are used. In byte-wide write configurations, each bit
                                                 -- controls the writing one byte of dina to address addra. For example, to
                                                 -- synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea
                                                 -- would be 4'b0010.
      );
end behavioral;
    -- End of xpm_memory_dpdistram_inst instance declaration

				
				
