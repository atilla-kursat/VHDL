library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GuitarTuner is
  port (
    clk       : in std_logic;               -- System clock
    reset     : in std_logic;               -- System reset
    adc_data  : in std_logic;               -- ADC data
    hex_led   : out std_logic_vector(7 downto 0)  -- HEX2LED display
  );
end GuitarTuner;

architecture Behavioral of GuitarTuner is
  signal prev_value      : std_logic := '0';  -- Previous ADC value
  signal transition_flag : std_logic := '0';  -- Transition flag
  signal counter         : integer range 0 to 9999 := 0;  -- Counter for transitions
  signal frequency       : integer range 0 to 9999 := 0;  -- Calculated frequency

  -- Constants for desired sample rate
  constant SAMPLE_RATE    : integer := 10000;  -- 10 kHz
  constant SAMPLE_PERIOD  : integer := 50000;  -- System clock frequency divided by SAMPLE_RATE
  constant TRANSITION_THRESHOLD : integer := SAMPLE_RATE / 10;  -- Threshold for transition detection (adjust as needed)

begin
  process (clk, reset)
  begin
    if reset = '1' then
      prev_value <= '0';
      transition_flag <= '0';
      counter <= 0;
      frequency <= 0;
    elsif rising_edge(clk) then
      -- Detect transitions from increasing to decreasing values
      if adc_data < prev_value and transition_flag = '0' then
        transition_flag <= '1';
      else
        transition_flag <= '0';
      end if;
      
      -- Calculate frequency based on transitions
      if transition_flag = '1' then
        counter <= counter + 1;
        frequency <= SAMPLE_RATE / counter;
      end if;
      
      prev_value <= adc_data;
    end if;
  end process;

  -- Convert frequency value to HEX2LED display format
  process (frequency)
  begin
    case frequency is
      when 0 to 9 =>
        hex_led <= std_logic_vector(to_unsigned(frequency, 8));
      when 10 to 15 =>
        hex_led <= "0000" & std_logic_vector(to_unsigned(frequency, 4));
      when 16 to 255 =>
        hex_led <= std_logic_vector(to_unsigned(frequency, 8));
      when others =>
        hex_led <= "11111111";  -- Display "FF" for frequencies greater than 255
    end case;
  end process;
  
end Behavioral;