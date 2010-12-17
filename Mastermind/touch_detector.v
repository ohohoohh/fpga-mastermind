module touch_detector(clock, reset, oLEDR, x_coord, y_coord, oLEDG, new_coord, oStart, nrOfRows, 
						Value01, Value02, Value03, Value04, WhitePegs, BlackPegs);
// TODO
// - maak random functie
// - maak x-y coord filter
// - vul value en rowCounter
// - pegs !!!!!
// - DEBUG MET LEDS


input clock;
input reset;
input [11:0] x_coord; // gemapt op 480, max 4096
input [11:0] y_coord; // gemapt op 800, max 4096
input new_coord;

// --------------------------------------

output oStart;
output [15:0] oLEDR;	// 16 rode leds (zijn meer MOGELIJK DEBUG)
output [7:0] oLEDG;		// 8 groene leds

output	[2:0]	nrOfRows;
output	[2:0]	Value01;
output	[2:0]	Value02;
output	[2:0]	Value03;
output	[2:0]	Value04;
output	[2:0]	WhitePegs;
output	[2:0]	BlackPegs;

// --------------------------------------

reg start;
reg calculate = 0;		// als deze 1 is dan berekenen (geset bij het aanraken van pegs)
reg [24:0] counter = 2500000;
reg [24:0] calculateCounter = 0;

reg	[2:0]	rowCounter;
reg	[2:0]	colValue01;
reg	[2:0]	colValue02;
reg	[2:0]	colValue03;
reg	[2:0]	colValue04;
reg	[2:0]	wPegs;	//white
reg	[2:0]	bPegs;	//black

wire [18:0]	xPos;	// 11 bits + 7 (die we straks extra voorzien)
wire [18:0]	yPos;


reg [7:0] led;		// DEBUG


// --------------------------------------

assign oLEDR = activesquare;
assign oLEDG = led;
assign oStart = start;

assign nrOfRows = rowCounter;
assign Value01 = colValue01;
assign Value02 = colValue02;
assign Value03 = colValue03;
assign Value04 = colValue04;
assign WhitePegs = wPegs;
assign BlackPegs = bPegs;

assign xPos[18:0] = (x_coord * 16) - x_coord + 6'b100000;		// 6'b100000 = 0,5 voor juiste afronding
// maal 15 maar sneller op FPGA, 15 = 480/4096*128 --> 128 is bitshift, minder zwaar dan deling
// xPos[18:7] te gebruiken waarden, omgekeerde bitshift --> mappen wat op bit 7 staat nr 0; 
assign yPos[18:0] = (y_coord * 16) + (y_coord * 8) + y_coord + 6'b100000;
// 16 + 8 + 1 = 25

// DIT MAG STRAKS WEG =====================================
reg [15:0] activesquare;

reg [16:0] checkedsquares = 17'b0;
reg [3:0] square;
reg [24:0] offsetCounter = 0;
reg [1:0] showcounter = 0;



// ========================================================

always @( posedge clock)
begin
	if(!reset) begin			// RESET
		start = 0;
		calculate = 0;
		rowCounter = 1;	// terug nr row 1 niet 0 (die bestaat niet)
		colValue01 = 0;
		colValue02 = 0;
		colValue03 = 0;
		colValue04 = 0;
		wPegs = 0;
		bPegs = 0;
	end
	else if(!calculate) begin	
	
		if( xPos[18:7] > 0 && xPos[18:7] <=  96) begin							// EERSTE KOLOM
			if( yPos[18:7] > (100 * (rowCounter - 1)) && yPos[18:7] <=  (100 * rowCounter)) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					// DEBUG 
					led = 8'b00000001;
					/*
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
					*/
				end
								
			end
		end
		
		if( xPos[18:7] > 96 && xPos[18:7] <=  192) begin						// TWEEDE KOLOM
			if( yPos[18:7] > (100 * (rowCounter - 1)) && yPos[18:7] <=  (100 * rowCounter)) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					// DEBUG 
					led = 8'b00000010;
					/*
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
					*/
				end
								
			end
		end
		
		if( xPos[18:7] > 192 && xPos[18:7] <=  288) begin						// DERDE KOLOM
			if( yPos[18:7] > (100 * (rowCounter - 1)) && yPos[18:7] <=  (100 * rowCounter)) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					// DEBUG 
					led = 8'b00000100;
					/*
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
					*/
				end
								
			end
		end
		
		if( xPos[18:7] > 288 && xPos[18:7] <=  384) begin						// VIERDE KOLOM
			if( yPos[18:7] > (100 * (rowCounter - 1)) && yPos[18:7] <=  (100 * rowCounter)) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					// DEBUG 
					led = 8'b00001000;
					/*
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
					*/
				end
								
			end
		end
		
		if( xPos[18:7] > 384 && xPos[18:7] <=  480) begin						// PEGS !!!!!
			if( yPos[18:7] > (100 * (rowCounter - 1)) && yPos[18:7] <=  (100 * rowCounter)) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					// DEBUG 
					led = 8'b00001111;
					/*
					activesquare = 16'b0;
					checkedsquares = 16'b0;
					start = 0;
					debounceCounter = 0;
					showcounter = 0;
					*/
				end
								
			end
		end
		
	end // if(!calculate)
	
	
	else begin   // Als calculate true is
		if(calculateCounter < 25000000) begin
			calculateCounter = calculateCounter + 1;
		end
		else begin	
		/*
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
		debounceCounter = 25000000;	
		*/
		calculateCounter = 0;
		end
	end
end
endmodule