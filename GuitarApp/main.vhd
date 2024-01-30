library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GuitarApp is
    port (
        clk       : in  std_logic;
        gpio_in   : in  std_logic;
        count_out : out unsigned(9 downto 0);
        reset     : in  std_logic;
		  mode_button:in  std_logic; 
		  
		  gpio_out  : out std_logic;
		  
		  hexout0   : out std_logic_vector(6 downto 0);
		  hexout1   : out std_logic_vector(6 downto 0);
		  hexout2   : out std_logic_vector(6 downto 0);
		  hexout3   : out std_logic_vector(6 downto 0);
		  hexout4   : out std_logic_vector(6 downto 0);
		  hexout5   : out std_logic_vector(6 downto 0)
		  
    );
end GuitarApp;

architecture Behavioral of GuitarApp is

COMPONENT hex2led IS
	PORT (
		HEX : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		LED : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Separate_Digits is
    port (
        number     : in  integer range 0 to 999;
        digit1     : out integer range 0 to 9;
        digit2     : out integer range 0 to 9;
        digit3     : out integer range 0 to 9
    );
end COMPONENT;

	 type int_array is array(0 to 5) of integer;
	 

    signal digits0 : integer range 0 to 9;
	 signal digits1 : integer range 0 to 9;
	 signal digits2 : integer range 0 to 9;
    
    signal count : integer range 0 to 999;
    signal timer : unsigned(31 downto 0) := (others => '0');
    signal prev_gpio_in : std_logic := '0';
	 
	 
	 signal hexdata0 : std_logic_vector(6 downto 0);
	 signal hexdata1 : std_logic_vector(6 downto 0);
	 signal hexdata2 : std_logic_vector(6 downto 0);
	 signal hexdata3 : std_logic_vector(6 downto 0);
	 signal hexdata4 : std_logic_vector(6 downto 0);
	 signal hexdata5 : std_logic_vector(6 downto 0);
	 
	 
	 signal hexin0 : std_logic_vector(3 downto 0);
	 signal hexin1 : std_logic_vector(3 downto 0);
	 signal hexin2 : std_logic_vector(3 downto 0);
    signal hexin5 : std_logic_vector(3 downto 0);
			 
	 signal closestint : integer range 0 to 999;

	 signal buttonstate : std_logic;
	 signal chord       : integer range 0 to 5;
	 signal chordfreq   : int_array; 

	 
	 
begin
	 	 chordfreq(0) <= 330;
	 chordfreq(1) <= 247;
	 chordfreq(2) <= 196;
	 chordfreq(3) <= 147;
	 chordfreq(4) <= 110;
	 chordfreq(5) <= 83;
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                count <= 0;
					 closestint <= 0;
                timer <= (others => '0');
                prev_gpio_in <= '0';
					 hexout0 <= "1111111";
					 hexout1 <= "1111111";
					 hexout2 <= "1111111";
					 hexout3 <= "1111111";
					 hexout4 <= "1111111";
					 hexout5 <= "1111111";
					 
            else
                if gpio_in = '1' and prev_gpio_in = '0' then
							count <= count + 1;                   
					 end if;
                
					 timer <= timer + 1;
                
                if timer = to_unsigned(74075000, timer'length) then
							 timer <= (others => '0');
						  	 hexout0 <= hexdata0;
							 hexout1 <= hexdata1;
						    hexout2 <= hexdata2;
							 hexout5 <= hexdata5;
							 
							 
					 if chordfreq(chord) < count then
							if chordfreq(chord) + 11 > count then
								hexout3 <= "0111111";		--ok
								hexout4 <= "0111111";
							else
								hexout4 <= "0100001";		--lower
								hexout3 <= "0101011";
							end if;			
					 else
							if count + 11 > chordfreq(chord) then
								hexout3 <= "0111111";		--ok
								hexout4 <= "0111111";		--ok
							else
								hexout3 <= "0001100";		
								hexout4 <= "1000001";		--higher
									
									
					      end if; 
					 end if;
							 
							 count <= 0;
                end if;
                
                prev_gpio_in <= gpio_in;
					 
					 
					 
					 
					 
					 
            end if;
        end if;
    end process;

	 
	 process(mode_button)
	 begin
	 
	 if rising_edge(mode_button) then
		
		if(buttonstate = '0') then
			buttonstate <= '1';
		else
			buttonstate <= '0';
		end if;
		
	   if chord < 5 then
			chord <= chord + 1;
		else
			chord <= 0 ;
		end if;
		
	 end if;
	 
	 end process;
	 
	 
	 
	 
    --count_out <= count;
	 
	 
	 
	 TODIGIT : Separate_Digits port map(count,digits0,digits1,digits2);
	 
	 hexin0 <= std_logic_vector(to_unsigned(digits0,4));
	 hexin1 <= std_logic_vector(to_unsigned(digits1,4));
	 hexin2 <= std_logic_vector(to_unsigned(digits2,4));
	 hexin5 <= std_logic_vector(to_unsigned(chord+1,4));
	 
	 HEX0 : hex2led port map(hexin0,hexdata0);
	 HEX1 : hex2led port map(hexin1,hexdata1);
	 HEX2 : hex2led port map(hexin2,hexdata2);
	 HEX5 : hex2led port map(hexin5,hexdata5);
	 
	 gpio_out <= buttonstate;
	 
	 
end Behavioral;