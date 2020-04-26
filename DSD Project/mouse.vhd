library IEEE;
use IEEE.std_logic_1164.all;

entity mouse is
	port (mouse_clk       :  in std_logic_vector;
		  reset           :  in std_logic_vector;      --reset all to zero;
		  status          :  in std_logic_vector;      --status active/idle 	
		  mouse_data      :  in std_logic_vector (1 downto 0);--left or right is clicked
		  speed           :  in std_logic_vector (3 downto 0);
		  displayed_number:  out std_logic_vector(6 downto 0);--7 segments
		  anode           :  out std_logic_vector (3 downto 0);)--4 digits
end mouse;

architecture mouse_arc of mouse is
	dig                    : std_logic_vector (1 downto 0);--led activation
	mouse_bits             : std_logic_vector (5 downto 0);--number of bits received
	signal displayed_number: std_logic_vector(15 downto 0);
	signal led_bcd         : std_logic_vector(4 downto 0);
	signal coordinate_x: std_logic_vector;
	signal coordinate_y: std_logic_vector;


 //32 bit signal received from the mouse
 	if(rising_edge(mouse_clk)||rising_edge(reset)) then
	 	if(reset==1) // resetting the mouse bits and displayed number
			mouse_bits <= 0;
	 	else if(mouse_bits<=31) //if the bits received from mouse is smaller than 31 bit
			mouse_bits <= mouse_bits+1;
	 	else
			mouse_bits <= 0;
	end

//Displayed number increment/decrement when the right or left button of the mouse is clicked
	if(falling_edge(mouse_clk)||rising_edge(reset)) then
		if(reset==1)
			displayed_number <=0;
		else begin
			if(status ==1) then//mouse is active
				if(mouse_data == "01") then//right button is pressed
					displayed_number <= displayed_number + 1;
				end
				else if(mouse_data == "10"&&displayed_number>0) then//left button is pressed
					displayed_number <= displayed_number -1;
				end
				else if(mouse_data =="11" || mouse_data =="00") then//inactive or both buttons
					displayed_number <= displayed_number;
				end
			end
	end


//converting the displayed_number to numeric number to be displayed on the 4-digit displayer
	begin
		case(dig)
		2'b00: begin
			anode = 4'b0111;
			led_bcd = displayed_number/1000;
			end
		2'b01: begin
			anode = 4'b1011
			led_bcd = displayed_number%1000/100;
			end
		2'b10: 
			begin
			anode = 4'b1101
			led_bcd = displayed_number%1000%100/10;
			end
		2'b11: begin
			anode = 4'b1110
			led_bcd = displayed_number%1000%100%10;
			end
		endcase
	end
  
	begin
		case(led_bcd)
		4'b0000: displayed_number = 7'b0000001; --"0"
		4'b0001: displayed_number = 7'b1001111; --"1"
		4'b0010: displayed_number = 7'b0010010; --"2"
		4'b0011: displayed_number = 7'b0000110; --"3"
		4'b0100: displayed_number = 7'b1001100; --"4"
		4'b0101: displayed_number = 7'b0100100; --"5"
		4'b0110: displayed_number = 7'b0100000; --"6"
		4'b0111: displayed_number = 7'b0001111; --"7"
		4'b1000: displayed_number = 7'b0000000; --"8"
		4'b1001: displayed_number = 7'b0001000; --"9"
		default: displayed_number = 7'b1111111;
		endcase
	end
end


			
