library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity Dijkstra_vhdl is
	generic(
		NODE_CNT	: integer := 16 -- number of nides in the graph
	);
	port(
		clk	: in std_logic ;	-- clk		: main clock , in DE2-115 board , frequency of his clock is 50MHz.
		clk_NIOS	: std_logic ;	-- clk_NIOS	: clock from NIOS II processor , maybe 25MHz.
		reset		: in std_logic ; -- reset signal, active 0, if needed to start finding shortest path , this signal will be activated.
		start		: in std_logic_vector(8 downto 0);	-- strating node index of shortest path
		trans_count : in std_logic_vector(8 downto 0); -- end node index of shortest path
		state_out	: out natural range 0 to 7 ;-- tracks the state of the controler
		neighbor_out	: out std_logic_vector(8 downto 0);-- gives the neighbor information
		distance_out	: out std_logic_vector(13 downto 0)--gives the distance between the start and end nodes. 
	);
end entity Dijkstra_vhdl ;
architecture Behavial of Dijkstra_vhdl is

component RAM_vhdl  
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
end component;
component comparator_vhdl 
	port(
		clk : in std_logic ;--standard input clock
		reset : in std_logic ;-- To reset
		state : in natural range 0 to  7 ;-- To track the state of the controller
		distance : in std_logic_vector(13 downto 0);-- To calculate the distance between the nodes
		shortest : in std_logic ;-- To check if the shortest path is calculated
		counter : in std_logic_vector(8 downto 0);-- To iterate through all the nodes
		min_distance_in : in std_logic_vector(13 downto 0);-- Saved minimum distance between the nodes
		min_distance : out std_logic_vector(13 downto 0);-- Updated minimum distance after comparison 
		new_in		: in std_logic_vector(8 downto 0);-- Saved neighbor index in the shortest path
		new_out	: out std_logic_vector(8 downto 0)-- Updated neighbour index in the shortest path
		);
end component;
component map_initialization_vhdl 
	port(
		row	: in natural range 0 to (2**9-1);
		column : in natural range 0 to (2**9-1);
		map_init_value : out std_logic_vector(13  downto 0)
	);
end component ;
component comparator_4_to_1_vhdl 
	port 
	(
	  min_distance_1 : in std_logic_vector(13 downto 0); -- Input from the instance 1 of the comparator
	  min_distance_2 : in std_logic_vector(13 downto 0) ;-- Input from the instance 2 of the comparator
	  min_distance_3 : in std_logic_vector(13 downto 0) ;-- Input from the instance 3 of the comparator
	  min_distance_4 : in std_logic_vector(13 downto 0);-- Input from the instance 4 of the comparator
	  new_1 : in std_logic_vector(8 downto 0);-- Neighbor index from the instance 1 of the comparator
	  new_2 : in std_logic_vector(8 downto 0);-- Neighbor index from the instance 2 of the comparator
	  new_3 : in std_logic_vector(8 downto 0);-- Neighbor index from the instance 3 of the comparator
	  new_4 : in std_logic_vector(8 downto 0);-- Neighbor index from the instance 4 of the comparator
	  min_distance : out std_logic_vector(13 downto 0);-- Minimum distance after comparision of the output of 4 instances
	  new_out	: out std_logic_vector(8 downto 0)-- NEw neghbour index after comparision of the output of 4 instances
	);
end component ;
--	following signals is used to read and write graph data to RAM memory.
--	RAM Memory count is same as node count of graph.

  type NODE_ARRAY is array(NODE_CNT-1 downto 0) of std_logic_vector(8 downto 0);
  type DIST_ARRAY is array(NODE_CNT-1 downto 0) of std_logic_vector(13 downto 0);
  
  signal     w_en            : std_logic_vector(NODE_CNT-1 downto 0);		--write enable to write RAM
  signal     write_address   : NODE_ARRAY;		
  signal     read_address    : NODE_ARRAY;
  signal     w_data          : DIST_ARRAY;		--write data
  signal     r_data          : DIST_ARRAY;		--read data
  signal     distance        : DIST_ARRAY;	--distance from start node for each nodes
  signal     shortest        : std_logic_vector(NODE_CNT-1 downto 0); --Is the node finished to find shortest path for each nodes?
  signal     neighbor        : NODE_ARRAY; --neighbor node index of shortest path for each nodes
  
  
  signal   min_distance : std_logic_vector(13 downto 0);
  signal   new_node : std_logic_vector(8 downto 0);
  signal 	min_distance_reg : std_logic_vector(13 downto 0);
  signal    New_reg : std_logic_vector(8 downto 0);
  -- states variables of controller 
	subtype state_type is natural range 0 to 7 ;
	signal state : state_type ;
  signal state_reg : state_type ;
  signal state_reg_reg : state_type ;
  signal counter : natural range 0 to (2**9-1) ;
  signal sub_counter : natural range 0 to (2**9-1) ;
  signal sub_counter_reg : natural range 0 to (2**9-1) ;
  signal sub_counter_reg_reg : natural range 0 to (2**9-1) ;
 
  signal   map_init_value  : DIST_ARRAY ;
  -- declaration of constants to denote state of controller
  constant   map_init : state_type := 0;		-- initialize graph data, graph data is writed to RAM blocks.		
  constant   dsn_init : state_type := 1;	-- 	initialize  distance[NODE_CNT-1:0],neighbor[NODE_CNT-1:0],shortest[NODE_CNT-1:0]
  constant   min_cost2: state_type := 2; 	-- state of finding shortest path
  constant   min_cost1: state_type := 3;  	-- state of finding shortest path
  constant   min_cost : state_type := 4;	-- state of finding shortest path
  constant   upd_minc : state_type := 5;	-- increase counter 
  constant   upd_dist : state_type := 6;	-- update distance for each node
  constant   done     : state_type := 7;		-- shortest path finding is finished.
  -- following are 4 of compare module instances and 1 of comparator_4_to_1 instance.
  signal min_distance_1 : std_logic_vector(13 downto 0);
  signal min_distance_2 : std_logic_vector(13 downto 0);
  signal min_distance_3 : std_logic_vector(13 downto 0);
  signal min_distance_4 : std_logic_vector(13 downto 0);
  signal new_1  : std_logic_vector(8 downto 0);
  signal new_2  : std_logic_vector(8 downto 0);
  signal new_3  : std_logic_vector(8 downto 0);
  signal new_4  : std_logic_vector(8 downto 0);
  signal new_a  : std_logic_vector(8 downto 0);
  signal new_b  : std_logic_vector(8 downto 0);
  signal new_c  : std_logic_vector(8 downto 0);
  signal new_d  : std_logic_vector(8 downto 0);

begin
  state_out <= state ;
  -- state transaction of controller
  process(clk,reset) begin
  if(clk'event and clk='1') then
		 if(reset = '0') then
		  state_reg       <= map_init;	--setting initial state(map_init) when reset is active
		  state_reg_reg   <= map_init;
		else
		  state_reg       <= state;     -- 1 clock delay of state
		  state_reg_reg   <= state_reg; -- 2 clock delay of state
		end if ;
	end if;
  end process;
  
  process(clk) begin
  if(clk'event and clk='1') then
    if(reset = '0') then
	  sub_counter_reg      <= 0;
	  sub_counter_reg_reg  <= 0;
	 else 
	  sub_counter_reg      <= sub_counter;
	  sub_counter_reg_reg  <= sub_counter_reg;
	 end if ;
  end if ;
  end process;
	-- Controller : main state transation.
  process(clk) begin
	  if(clk'event and clk='1') then
		  if(reset = '0') then
			  state           <= map_init;
			  counter         <= 0;
			  sub_counter     <= 0;
			elsif(state = map_init and counter /= NODE_CNT-1) then
			  state           <= map_init;
			  counter         <= counter + 1;
			elsif(state = map_init and counter = NODE_CNT-1) then
			  state           <= dsn_init;
			  counter         <= conv_integer(start);	                
			elsif(state = dsn_init) then
			  state           <= min_cost2;
			  counter         <= 0;
			elsif(state = min_cost2 and counter /= NODE_CNT-1) then
			  state           <= min_cost1;
			elsif(state = min_cost1) then
				state           <= min_cost;	
			elsif(state = min_cost and sub_counter /= NODE_CNT*1/4-1 and counter /= NODE_CNT-1) then
			  state           <= min_cost;
			  sub_counter     <= sub_counter + 1;
			elsif(state = min_cost and sub_counter = NODE_CNT*1/4-1 and counter /= NODE_CNT-1) then
			  state           <= upd_minc;
			  sub_counter     <= 0;
			elsif(state = upd_minc and counter /= NODE_CNT-1) then
			  state           <= upd_dist;
			elsif(state = upd_dist and counter /= NODE_CNT-1) then
			  state           <= min_cost2;
			  counter         <= counter + 1;
			else 
			  state           <= done;
			  counter         <= counter;
			end if;
		end if;
	end process;
  --output results
  process(clk_NIOS) begin
	  if(clk_NIOS'event and clk_NIOS = '1' ) then
		 neighbor_out      <= neighbor(conv_integer(trans_count));
		 distance_out      <= distance(conv_integer(trans_count));
	  end if ;
  end process;
 ----------------------/
RAM_PREFETCH_BLOCK: 
	for i in 0 to NODE_CNT-1 generate
		-- Concurrent Statement(s)

	  uut_1 : RAM_vhdl
			generic map ( NODE_CNT => NODE_CNT)
			port map
		  (			-- RAM blocks to save graph data
			clk =>clk,
			w_en => w_en(i),
			write_address => conv_integer(write_address(i)) , 
			w_data => w_data(i),
			read_address => conv_integer(read_address(i)),
			r_data => r_data(i)
		  );
	  
	  uut_2 : map_initialization_vhdl  port map(			-- RAM graph data definition blocks
	    row => counter,
		 column => i,
		 map_init_value => map_init_value(i) 
	  );
	
	  --RAM initialization and prefetch block
	  process(state) begin
			case state is 
				when map_init =>	--write graph data to RAM
					w_en(i)          <= '1';
					write_address(i) <= conv_std_logic_vector(counter,9);
					w_data(i)        <= map_init_value(i);
					read_address(i)  <= (others => 'X');
				when dsn_init => --read graph data from RAM
				  w_en(i)          <= '0';
				  write_address(i) <= (others => 'X');
				  w_data(i)        <= (others => 'X');
				  read_address(i)  <= conv_std_logic_vector(counter,9);		  
				when upd_dist	=>	-- when finded new shorter path, 
				  w_en(i)          <= '0';
				  write_address(i) <= (others => 'X');
				  w_data(i)        <= (others => 'X');
				  read_address(i)  <= New_reg;
				when others =>
				  w_en(i)          <= '0';
				  write_address(i) <= (others => 'X');
				  w_data(i)        <= (others => 'X');
				  read_address(i)  <= (others => 'X');
			end case ;
      end process;	 

		--update distance and neighbor according to state of controller
      process (clk) begin
		if(clk'event and clk = '1') then
			if( state_reg_reg = dsn_init ) then
				 distance(i)      <= r_data(i);
				 neighbor(i)      <= start;
			elsif ( state_reg_reg = upd_dist ) then
			  if( shortest(i) = '0' and (distance(conv_integer(New_reg)) + r_data(i) < distance(i)) ) then
				 distance(i)    <= distance(conv_integer(New_reg)) + r_data(i);
				 neighbor(i)    <= New_reg;
			  else 
				 distance(i)    <= distance(i);
				 neighbor(i)    <= neighbor(i);
			  end if ;
			 else 
				 distance(i)      <= distance(i);
				 neighbor(i)      <= neighbor(i);
			 end if ;
		end if ;
	  end process;
	--update shortest according to state of controller
	  process(clk) begin
		  if(clk'event and clk='1') then
				if( state_reg_reg = dsn_init and start /= i) then	--On init , all is 0 except start node
					 shortest(i)      <= '0';
				 elsif( state_reg_reg = dsn_init and start = i) then	-- if start node , shortest  = 1  ;
					 shortest(i)      <= '1';
				elsif( state = upd_minc and new_node = i) then		-- if shortest finding is finished , shortest  = 1  ;
				  shortest(i)      <= '1';
				else 
				  shortest(i)      <= shortest(i);
				end if ;
		  end if;
	  end process ;
	end generate;




  comp_dist_1_4 : comparator_vhdl port map (
    clk => clk,
	 reset => reset ,
	 state => state ,
	 distance => distance(0+sub_counter) ,
	 shortest => shortest(0+sub_counter),
	 counter => conv_std_logic_vector(sub_counter,9) ,
	 min_distance_in => min_distance_1 ,
	 min_distance => min_distance_1 ,
	 new_in => new_a ,
	 new_out => new_a 
  );
  new_1 <= new_a + 0;
  
  comp_dist_2_4 : comparator_vhdl  port map (
    clk => clk ,
	 reset => reset ,
	 state => state ,
	 distance => distance(NODE_CNT*1/4 + sub_counter),
	 shortest => shortest(NODE_CNT*1/4 + sub_counter),
	 counter => conv_std_logic_vector(sub_counter,9) ,
	 min_distance_in => min_distance_2,
	 min_distance => min_distance_2,
	 new_in => new_b ,
	 new_out => new_b
  );
  new_2 <= new_b + NODE_CNT*1/4;
  
  comp_dist_3_4 : comparator_vhdl port map (
    clk => clk ,
	 reset => reset ,
	 state => state ,
	 distance => distance(NODE_CNT*2/4+sub_counter),
	 shortest => shortest(NODE_CNT*2/4+sub_counter),
	 counter => conv_std_logic_vector(sub_counter,9) ,
	 min_distance_in => min_distance_3 ,
	 min_distance => min_distance_3 ,
	 new_in => new_c ,
	 new_out => new_c
  );
  new_3 <= new_c + NODE_CNT*2/4;
  
  comp_dist_4_4 : comparator_vhdl port map (
    clk => clk,
	 reset => reset ,
	 state => state ,
	 distance => distance(NODE_CNT*3/4 + sub_counter),
	 shortest => shortest(NODE_CNT*3/4 + sub_counter),
	 counter => conv_std_logic_vector(sub_counter,9) ,
	 min_distance_in => min_distance_4 ,
	 min_distance => min_distance_4 ,
	 new_in => new_d ,
	 new_out => new_d
	 );
  new_4 <= new_d + NODE_CNT*3/4;
	
  comp_4_to_1 : comparator_4_to_1_vhdl  port map (
	min_distance_1 => min_distance_1 ,
	min_distance_2 => min_distance_2 ,
	min_distance_3 => min_distance_3 ,
	min_distance_4 => min_distance_4 ,
	new_1 => new_1 ,
	new_2 => new_2 ,
	new_3 => new_3 ,
	new_4 => new_4 ,
	min_distance => min_distance ,
	new_out=> new_node 
  );

  process(clk) begin
	if clk'event and clk ='1' then
    if( state = upd_minc) then
	  min_distance_reg <= min_distance;
	  New_reg          <= new_node;
	 else 
	  min_distance_reg <= min_distance_reg;
	  New_reg          <= New_reg;
	 end if ;
   end if ;
  end process;
end architecture Behavial ;