library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Separate_Digits is
    port (
        number     : in  integer range 0 to 999;
        digit1     : out integer range 0 to 9;
        digit2     : out integer range 0 to 9;
        digit3     : out integer range 0 to 9
    );
end Separate_Digits;

architecture Behavioral of Separate_Digits is
begin
    digit1 <= number mod 10;
    digit2 <= (number / 10) mod 10;
    digit3 <= (number / 100) mod 10;
end Behavioral;