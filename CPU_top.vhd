library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.all;

entity CPU_TOP is 
    port(
        clk : in std_logic;
        rst : in std_logic;
        
        memory_injection_in: in std_logic_vector(15 downto 0) := X"0001";
        out_val : out std_logic_vector(15 downto 0);
        
        ra_idx_IFID, ra_idx_IDEX, ra_idx_EXMEM, ra_idx_MEMWB, ra_idx_mux: out std_logic_vector(2 downto 0);
        ra_val_IFID, ra_val_IDEX, ra_val_EXMEM, ra_val_MEMWB:  out std_logic_vector(15 downto 0)
        
    ); -- these get assigned in port maps as portmap(clk => CLOCK) to help wire between files
        -- inter file uses comments on bottom to declare.
end CPU_TOP;


architecture Behavioral of CPU_TOP is
   component instruction_rom  
                port (  
                        clk   : in  std_logic;
                        en    : in  std_logic := '1';
                        addr  : in  std_logic_vector(8 downto 0);
                        data  : out std_logic_vector(15 downto 0)
                );
    end component;
                
   component CONTROLLER_file 
                port ( 
                     --input signals
                        rst: in std_logic;  
                        clk: in std_logic;
                        IR: in std_logic_vector(15 downto 0);  
                        PC: out std_logic_vector(15 downto 0);
                        out_val: out std_logic_vector(15 downto 0);
                        --debug
                        ra_idx_IFID, ra_idx_IDEX, ra_idx_EXMEM, ra_idx_MEMWB, ra_idx_mux: out std_logic_vector(2 downto 0);
                        ra_val_IFID, ra_val_IDEX, ra_val_EXMEM, ra_val_MEMWB:  out std_logic_vector(15 downto 0);
                        memory_injection: in std_logic_vector(15 downto 0) := X"0001"
                );
    end component;
                
                --controller-file
                signal PC_s, out_val_s,IR_s : std_logic_vector(15 downto 0); 
                signal  ra_idx_IFIDs, ra_idx_IDEXs, ra_idx_EXMEMs, ra_idx_MEMWBs, ra_idx_muxs:  std_logic_vector(2 downto 0);
                signal ra_val_IFIDs, ra_val_IDEXs, ra_val_EXMEMs, ra_val_MEMWBs:  std_logic_vector(15 downto 0);
                signal memory_injections:  std_logic_vector(15 downto 0) := X"0001";
                
                --rom
                signal en_s: std_logic;
                signal addr_s:  std_logic_vector(8 downto 0);
            
begin

    rom: instruction_rom port map(clk, en_s, addr_s, IR_s);
    top_A: CONTROLLER_file port map(rst, clk, IR_s, PC_s, out_val_s,
                                     ra_idx_IFIDs, ra_idx_IDEXs, ra_idx_EXMEMs, ra_idx_MEMWBs, ra_idx_muxs,
                                     ra_val_IFIDs, ra_val_IDEXs, ra_val_EXMEMs, ra_val_MEMWBs,
                                     memory_injections);
    
    process (clk) begin
            out_val <= out_val_s;
            
            ra_idx_IFID <= ra_idx_IFIDs; 
            ra_idx_mux <= ra_idx_muxs;
            ra_idx_IDEX <= ra_idx_IDEXs;
            ra_idx_EXMEM <= ra_idx_EXMEMs;
            ra_idx_MEMWB <= ra_idx_MEMWBs;
            
            ra_val_IFID <= ra_val_IFIDs;
            ra_val_IDEX <= ra_val_IDEXs;
            ra_val_EXMEM <= ra_val_EXMEMs;
            ra_val_MEMWB <= ra_val_MEMWBs;
            
        end process;

end Behavioral;
