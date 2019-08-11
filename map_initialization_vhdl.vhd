library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity map_initialization_vhdl is
	port(
		row	: in natural range 0 to (2**9-1);
		column : in natural range 0 to (2**9-1);
		map_init_value : out std_logic_vector(13 downto 0)
	);
end entity map_initialization_vhdl ;
architecture Behavial of map_initialization_vhdl is
begin
	process(row,column)
	begin
		if row = column then map_init_value <= conv_std_logic_vector( 0 ,14);
		elsif ( row = 0   and column = 1  ) or (row = 1   and column = 0  ) then map_init_value <= conv_std_logic_vector( 247 ,14);
		elsif ( row = 0   and column = 2  ) or (row = 2   and column = 0  ) then map_init_value <= conv_std_logic_vector( 258 ,14);

		elsif ( row = 1   and column = 2  ) or (row = 2   and column = 1  ) then map_init_value <= conv_std_logic_vector( 289 ,14);
		elsif ( row = 1   and column = 5  ) or (row = 5   and column = 1  ) then map_init_value <= conv_std_logic_vector( 245 ,14);

		elsif ( row = 2   and column = 3  ) or (row = 3   and column = 2  ) then map_init_value <= conv_std_logic_vector( 132 ,14);
		elsif ( row = 2   and column = 4  ) or (row = 4   and column = 2  ) then map_init_value <= conv_std_logic_vector( 258 ,14);

		elsif ( row = 3   and column = 6  ) or (row = 6   and column = 3  ) then map_init_value <= conv_std_logic_vector( 217 ,14);
		elsif ( row = 3   and column = 7  ) or (row = 7   and column = 3  ) then map_init_value <= conv_std_logic_vector( 290 ,14);

		elsif ( row = 4   and column = 5  ) or (row = 5   and column = 4  ) then map_init_value <= conv_std_logic_vector( 178  ,14);
		elsif ( row = 4   and column = 7  ) or (row = 7   and column = 4  ) then map_init_value <= conv_std_logic_vector( 94  ,14);

		elsif ( row = 5   and column = 14 ) or (row = 14  and column = 5  ) then map_init_value <= conv_std_logic_vector( 187  ,14);
		elsif ( row = 5   and column = 13 ) or (row = 13  and column = 5  ) then map_init_value <= conv_std_logic_vector( 341  ,14);

		elsif ( row = 6   and column = 9 ) or (row = 9  and column = 6  ) then map_init_value <= conv_std_logic_vector( 309  ,14);


		elsif ( row = 7   and column = 8  ) or (row = 8   and column = 7  ) then map_init_value <= conv_std_logic_vector( 119  ,14);
		elsif ( row = 7   and column = 11 ) or (row = 11  and column = 7  ) then map_init_value <= conv_std_logic_vector( 180 ,14);

		elsif ( row = 8   and column = 9  ) or (row = 9   and column = 8  ) then map_init_value <= conv_std_logic_vector( 165  ,14);
		elsif ( row = 8   and column = 10 ) or (row = 10  and column = 8  ) then map_init_value <= conv_std_logic_vector( 312 ,14);
		elsif ( row = 8   and column = 12 ) or (row = 12  and column = 8  ) then map_init_value <= conv_std_logic_vector( 145 ,14);

		elsif ( row = 9   and column = 10 ) or (row = 10  and column = 9  ) then map_init_value <= conv_std_logic_vector( 176 ,14);

		elsif ( row = 10   and column = 15 ) or (row = 15  and column = 10  ) then map_init_value <= conv_std_logic_vector( 465 ,14);


		elsif ( row = 11  and column = 12 ) or (row = 12  and column = 11 ) then map_init_value <= conv_std_logic_vector( 45 ,14);
		elsif ( row = 11  and column = 13 ) or (row = 13  and column = 11 ) then map_init_value <= conv_std_logic_vector( 75 ,14);

		elsif ( row = 12  and column = 15 ) or (row = 15  and column = 12 ) then map_init_value <= conv_std_logic_vector( 352 ,14);

		elsif ( row = 13  and column = 15 ) or (row = 15  and column = 13 ) then map_init_value <= conv_std_logic_vector( 286 ,14);

		elsif ( row = 14  and column = 15 ) or (row = 15  and column = 14 ) then map_init_value <= conv_std_logic_vector( 231 ,14);

		else 
			map_init_value <= conv_std_logic_vector(10000 , 14);
		end if ;
	end process;
end Behavial ;