module touch_detector(clock, reset, oLEDR, x_coord, y_coord, led, new_coord, oStart, iPhoto);
input clock;
input reset;
input [1:0] iPhoto;
input [11:0] x_coord;
input [11:0] y_coord;
input new_coord;

output oStart;
output [15:0] oLEDR;
output [7:0] led;

reg [16:0] checkedsquares = 17'b0;
reg [7:0] led;
reg [3:0] square;
reg [15:0] activesquare;
reg [24:0] debounceCounter = 2500000;
reg [24:0] offsetCounter = 0;
reg start;
reg [1:0] showcounter = 0;


assign oLEDR = activesquare;
assign oStart = start;

always @( posedge clock)
begin
	if(!reset) begin
		showcounter = 0;
		activesquare = 16'b0;
		checkedsquares = 16'b0;
		start = 0;
	end
	else if(showcounter < 2) begin	
		if(x_coord > 0 && x_coord <=  1365) begin
			if(y_coord < 819) 
			begin
				led = 8'b00000001;
				if(debounceCounter < 2500000)
				begin
					debounceCounter = debounceCounter + 1;
				end
				else
				begin
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
				end
								
			end
			else if(y_coord > 819 && y_coord < 1638) begin
				led = 8'b00000100;
				square = 4;
				if(!checkedsquares[4]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						showcounter = showcounter + 1;
						debounceCounter = 0;
						
					end
				end
			end
			else if(y_coord > 1638 && y_coord < 2457) begin
				 led = 8'b000000111;
				 square = 7;
				 if(!checkedsquares[7]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord > 2457 && y_coord < 3276) begin
				 led = 8'b000001010;
				 square = 10;
				 if(!checkedsquares[10]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord >3276) begin
				 led = 8'b000001101;
				 square = 13;
				 if(!checkedsquares[13]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
		end
		else if(x_coord > 1365 && x_coord <= 2730) begin
			if(y_coord < 819) begin
				 led = 8'b00000010;
				 square = 2;
				 if(debounceCounter < 25000000)
				begin
					debounceCounter = debounceCounter + 1;
				end
				else if(new_coord)
				begin
				start = 1;
					activesquare[square] = ~activesquare[square];
					debounceCounter = 0;
					
				end
			end
			else if(y_coord > 819 && y_coord < 1638) begin
				 
				 
				 if(!checkedsquares[5]) begin
				
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					led = 8'b00000101;
				square = 5;
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord > 1638 && y_coord < 2457) begin
				 led = 8'b00001000;
				 square = 8;
				 if(!checkedsquares[8]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord > 2457 && y_coord < 3276) begin
				 led = 8'b000001011;
				 square = 11;
				 if(!checkedsquares[11]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord >3276) begin
				 led = 8'b000001110;
				 square = 14;
				 if(!checkedsquares[14]) begin
					 if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
		end
		else if(x_coord >2730) begin
			if(y_coord < 819) begin
				 led = 8'b00000011;
				 if(debounceCounter < 25000000)
				begin
					debounceCounter = debounceCounter + 1;
				end
				else if(new_coord)
				begin					
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
				end
			end
			else if(y_coord > 819 && y_coord < 1638) begin
				 led = 8'b00000110;
				 square = 6;
				 if(!checkedsquares[6]) begin
					 if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord > 1638 && y_coord < 2457) begin
				 led = 8'b00001001;
				 square = 9;
				 if(!checkedsquares[9]) begin
					 if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord > 2457 && y_coord < 3276) begin
				 led = 8'b000001100;
				 square = 12;
				 if(!checkedsquares[12]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
					start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
			else if(y_coord >3276) begin
				led = 8'b000001111;
				square = 15;
				 
				if(!checkedsquares[15]) begin
					if(debounceCounter < 25000000)
					begin
						debounceCounter = debounceCounter + 1;
					end
					else if(new_coord)
					begin
						start = 1;
						activesquare[square] = ~activesquare[square];
						debounceCounter = 0;
						showcounter = showcounter + 1;
					end
				end
			end
		end	
	end
	else begin
		if(offsetCounter < 25000000) begin
			offsetCounter = offsetCounter + 1;
		end
		else begin	
			
		if(iPhoto == 0) begin		
			if(activesquare[13] && activesquare[15]) begin
				checkedsquares[13] = 1;
				checkedsquares[15] = 1;
			end
			if(activesquare[14] && activesquare[12]) begin
				checkedsquares[14] = 1;
				checkedsquares[12] = 1;
			end
			if(activesquare[10] && activesquare[11]) begin
				checkedsquares[10] = 1;
				checkedsquares[11] = 1;
			end
			if(activesquare[4] && activesquare[9]) begin
				checkedsquares[4] = 1;
				checkedsquares[9] = 1;
			end
			if(activesquare[6] && activesquare[7]) begin
				checkedsquares[6] = 1;
				checkedsquares[7] = 1;
			end
			if(activesquare[5] && activesquare[8]) begin
				checkedsquares[5] = 1;
				checkedsquares[8] = 1;
			end
		end
		else if(iPhoto == 1) begin
			if(activesquare[4] && activesquare[11]) begin
				checkedsquares[4] = 1;
				checkedsquares[11] = 1;
			end
			if(activesquare[5] && activesquare[7]) begin
				checkedsquares[5] = 1;
				checkedsquares[7] = 1;
			end
			if(activesquare[6] && activesquare[12]) begin
				checkedsquares[6] = 1;
				checkedsquares[12] = 1;
			end
			if(activesquare[8] && activesquare[10]) begin
				checkedsquares[8] = 1;
				checkedsquares[10] = 1;
			end
			if(activesquare[9] && activesquare[13]) begin
				checkedsquares[9] = 1;
				checkedsquares[13] = 1;
			end
			if(activesquare[14] && activesquare[15]) begin
				checkedsquares[14] = 1;
				checkedsquares[15] = 1;
			end
		
		end

		if(!checkedsquares[4]) activesquare[4] = 0;
		if(!checkedsquares[5]) activesquare[5] = 0;
		if(!checkedsquares[6]) activesquare[6] = 0;
		if(!checkedsquares[7]) activesquare[7] = 0;
		if(!checkedsquares[8]) activesquare[8] = 0;
		if(!checkedsquares[9]) activesquare[9] = 0;
		if(!checkedsquares[10]) activesquare[10] = 0;
		if(!checkedsquares[11]) activesquare[11] = 0;
		if(!checkedsquares[12]) activesquare[12] = 0;
		if(!checkedsquares[13]) activesquare[13] = 0;
		if(!checkedsquares[14]) activesquare[14] = 0;
		if(!checkedsquares[15]) activesquare[15] = 0;
		showcounter = 0;
		offsetCounter = 0;
		debounceCounter = 25000000;	
			
		end
	end
end
endmodule