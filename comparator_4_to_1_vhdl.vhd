library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity comparator_4_to_1_vhdl is
	port 
	(
	  min_distance_1 : in std_logic_vector(13 downto 0);
	  min_distance_2 : in std_logic_vector(13 downto 0) ;
	  min_distance_3 : in std_logic_vector(13 downto 0) ;
	  min_distance_4 : in std_logic_vector(13 downto 0);
	  new_1 : in std_logic_vector(8 downto 0);
	  new_2 : in std_logic_vector(8 downto 0);
	  new_3 : in std_logic_vector(8 downto 0);
	  new_4 : in std_logic_vector(8 downto 0);
	  min_distance : out std_logic_vector(13 downto 0);
	  new_out	: out std_logic_vector(8 downto 0)
	);
end entity comparator_4_to_1_vhdl;
architecture Behavial of comparator_4_to_1_vhdl is
begin
	process(min_distance_1,min_distance_2,min_distance_3,min_distance_4) 
	begin
	  if(min_distance_1 <= min_distance_2 and min_distance_1 <= min_distance_3 and min_distance_1 <= min_distance_4) then
		  min_distance <= min_distance_1;
		  new_out          <= new_1;
	  elsif(min_distance_2 <= min_distance_1 and min_distance_2 <= min_distance_3 and min_distance_2 <= min_distance_4) then
		  min_distance <= min_distance_2;
		 new_out          <= new_2;
	  elsif(min_distance_3 <= min_distance_1 and min_distance_3 <= min_distance_2 and min_distance_3 <= min_distance_4) then
		  min_distance <= min_distance_3;
		 new_out          <= new_3;
	  else 
		  min_distance <= min_distance_4;
		  new_out          <= new_4;
	  end if;
	end process; 

end architecture Behavial ;