library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
entity comparator_vhdl is
	port(
		clk : in std_logic ;
		reset : in std_logic ;
		state : in natural range 0 to  7 ;
		distance : in std_logic_vector(13 downto 0);
		shortest : in std_logic ;
		counter : in std_logic_vector(8 downto 0);
		min_distance_in : in std_logic_vector(13 downto 0);
		min_distance : out std_logic_vector(13 downto 0);
		new_in		: in std_logic_vector(8 downto 0);
		new_out	: out std_logic_vector(8 downto 0)
		);
end entity comparator_vhdl;
architecture Behavial of comparator_vhdl is
begin	
  process(clk,reset) begin
  if clk'event and clk='1' then
		if(reset = '0' or state /= 4) then
			min_distance <= conv_std_logic_vector(10000,14);
			new_out          <= (others => '0');
		 elsif(shortest = '0' and min_distance_in > distance) then
			min_distance <= distance; 
			new_out      <= counter;	  
		else 
		  min_distance <= min_distance_in;
		  new_out          <= new_in ;
		end if ;
	end if ;
  end process;
  
end architecture Behavial ;