-- Quartus II VHDL Template
-- Simple Dual-Port RAM with different read/write addresses and
-- different read/write clock

library ieee;
use ieee.std_logic_1164.all;
entity RAM_vhdl is 
	generic (
		NODE_CNT : integer := 16
	);
	port (
		clk : in std_logic ;
		w_en : in std_logic ;
		write_address : in natural range 0 to (2**9-1);
		w_data : in std_logic_vector(13 downto 0);
		read_address : in natural range 0 to (2**9-1);
		r_data : out std_logic_vector(13 downto 0)
	);
end entity RAM_vhdl;
architecture Behavial of RAM_vhdl is
	type MEM_TYPE is array (NODE_CNT-1 downto 0) of std_logic_vector(13 downto 0);
	signal mem : MEM_TYPE ;
	signal read_address_reg : natural range 0 to (2**9-1);
begin
  
  
  process(clk) begin 
	if(clk'event and clk ='1') then
    if (w_en = '1' ) then        
      mem(write_address) <= w_data;
    end if ;
	end if;
  end process;
   
  process(clk) begin 
	if(clk'event and clk ='1') then 
    r_data <= mem(read_address_reg);      
    read_address_reg <= read_address;   
   end if ;
  end process;

end architecture Behavial ;