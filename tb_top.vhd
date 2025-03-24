library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 
use work.all;

entity test_controller_sub is end test_controller_sub;

architecture behavioral of test_controller_sub is

   component CPU_TOP port(
           clk : in std_logic;
           rst : in std_logic;
           
           memory_injection_in: in std_logic_vector(15 downto 0) := X"0001";
           out_val : out std_logic_vector(15 downto 0);
           
           ra_idx_IFID, ra_idx_IDEX, ra_idx_EXMEM, ra_idx_MEMWB, ra_idx_mux: out std_logic_vector(2 downto 0);
           ra_val_IFID, ra_val_IDEX, ra_val_EXMEM, ra_val_MEMWB:  out std_logic_vector(15 downto 0);
           
           IR : out std_logic_vector(15 downto 0); 
           PC : out std_logic_vector(15 downto 0);
           
           addr_out: out std_logic_vector(15 downto 0)
   );
   end component; 
   
   signal rst, clk : std_logic; 
   signal IR, PC, out_val : std_logic_vector(15 downto 0); 
   
   --tests
   signal memory_injection_s:  std_logic_vector(15 downto 0);
   signal ra_idx_IFIDs, ra_idx_IDEXs, ra_idx_EXMEMs ,ra_idx_MEMWBs, ra_idx_muxs: std_logic_vector(2 downto 0);
   signal ra_val_IFIDs, ra_val_IDEXs, ra_val_EXMEMs, ra_val_MEMWBs:  std_logic_vector(15 downto 0);
   
   
   signal  addr_outs: std_logic_vector(15 downto 0);
   begin
   u0 : CPU_TOP  port map(clk, rst, memory_injection_s, out_val, 
                                 ra_idx_IFIDs, ra_idx_IDEXs, ra_idx_EXMEMs, ra_idx_MEMWBs, ra_idx_muxs,
                                 ra_val_IFIDs, ra_val_IDEXs, ra_val_EXMEMs, ra_val_MEMWBs,IR,PC,addr_outs);

   process begin
       clk <= '0'; wait for 10 us;
       clk <= '1'; wait for 10 us; 
   end process;
   
   process begin
       memory_injection_s <= x"0007";
       rst <= '1'; wait until (rising_edge(clk)); 
       rst <= '0'; wait until (rising_edge(clk));     -- IN r1             -- r1 = 03
       memory_injection_s <= x"0002";
       wait until (rising_edge(clk));  -- IN r2             -- r2 = 05
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       wait until (rising_edge(clk));  -- NOP
       rst <= '1';
       wait;
   end process;
end behavioral;