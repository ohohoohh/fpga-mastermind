module touch_detector(clock, reset, oLEDR, x_coord, y_coord, oLEDG, new_coord, oStart, nrOfRows, 
						Value01, Value02, Value03, Value04, WhitePegs, BlackPegs);
// TODO
// - maak random functie --> DEZE WERKT NIET 100% zie eerste always
// - pegs !!!!!
// - DEBUG MET LEDS


input clock;
input reset;
input [11:0] x_coord; // gemapt op 480, max 4096
input [11:0] y_coord; // gemapt op 800, max 4096
input new_coord;

// --------------------------------------

output oStart;
output 	[17:0] 	oLEDR;	// 16 rode leds (zijn meer MOGELIJK DEBUG)
output 	[7:0] 	oLEDG;		// 8 groene leds

output	[2:0]	nrOfRows;
output	[2:0]	Value01;	// 0 = leeg, 1-6 zijn de kleuren
output	[2:0]	Value02;
output	[2:0]	Value03;
output	[2:0]	Value04;
output	[2:0]	WhitePegs; // max 4
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


reg			nextRound;
reg [31:0]	randomGen;
reg	[2:0]	solution01;
reg	[2:0]	solution02;
reg	[2:0]	solution03;
reg	[2:0]	solution04;
reg [7:0] 	led;
reg [17:0] 	ledrs;	

wire [18:0]	xPos;	// 11 bits + 7 (die we straks extra voorzien)
wire [18:0]	yPos;


// --------------------------------------

assign oLEDR = ledrs;
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



// ========================================================

always @(posedge clock)// or posedge reset)
begin
	if(!reset) begin			// RESET
		randomGen = 35;
	end else begin
		randomGen = { randomGen[0] ^ randomGen[1] ^ randomGen[2] ^ randomGen[12], randomGen[31:1]};
	end
end		


always @( posedge clock)
begin
	if(!reset) begin			// RESET
		start = 0;
		calculate = 0;
		led = 8'b00000000;
		
		rowCounter = 7;         // moet vermindert w
		colValue01 = 0;
		colValue02 = 0;
		colValue03 = 0;
		colValue04 = 0;
		
		wPegs = 0;
		bPegs = 0;
		
		// Zet random waarden in de solutions  - DEBUG DIT ANDERS	
		solution01 = randomGen[1] + randomGen[5] + randomGen[10] + randomGen[15] + randomGen[20]+ randomGen[25];
		solution02 = randomGen[2] + randomGen[6] + randomGen[11] + randomGen[16] + randomGen[21]+ randomGen[26];
		solution03 = randomGen[3] + randomGen[7] + randomGen[12] + randomGen[17] + randomGen[22]+ randomGen[27];
		solution04 = randomGen[4] + randomGen[8] + randomGen[13] + randomGen[18] + randomGen[23]+ randomGen[28];
		
		if (solution01 == 0)
			solution01 = 1;
		if (solution02 == 0)
			solution02 = 1;
		if (solution03 == 0)
			solution03 = 1;
		if (solution04 == 0)
			solution04 = 1;
		
		ledrs[2:0] = solution01;
		ledrs[5:3] = solution02;
		ledrs[8:6] = solution03;
		ledrs[11:9] = solution04;
		//ledrs[17:12] = 6'b101010;

	end
	else if(!calculate) begin	
		start = 1;	
		wPegs = 0;
		bPegs = 0;
		
		if( xPos[18:7] > 0 && xPos[18:7] <=  96) begin							// EERSTE KOLOM
			if( yPos[18:7] > (100 * rowCounter) && yPos[18:7] <=  (100 * (rowCounter + 1))) begin
				if(counter < 2500000)	// touch toggle
				begin
					counter = counter + 1;
				end
				else
				begin
					led = 8'b00000001;
					
					
					colValue01 = colValue01 + 1; 		// ga nr volgende kleur (als > 6 terug nr eerste)
					if (colValue01 > 6)
						colValue01 = 1;
				end
								
			end
		end
		
		if( xPos[18:7] > 96 && xPos[18:7] <=  192) begin						// TWEEDE KOLOM
			if( yPos[18:7] > (100 * rowCounter) && yPos[18:7] <=  (100 * (rowCounter + 1))) begin
				if(counter < 2500000)
				begin
					counter = counter + 1;
				end
				else
				begin
					led = 8'b00000010;
					
					colValue02 = colValue02 + 1;
					if (colValue02 > 6)
						colValue02 = 1;
				end
								
			end
		end
		
		if( xPos[18:7] > 192 && xPos[18:7] <=  288) begin						// DERDE KOLOM
			if( yPos[18:7] > (100 * rowCounter) && yPos[18:7] <=  (100 * (rowCounter + 1))) begin
				if(counter < 2500000)
				begin
					counter = counter + 1;
				end
				else
				begin
					led = 8'b00000100;
					
					colValue03 = colValue03 + 1;
					if (colValue03 > 6)
						colValue03 = 1;
				end
								
			end
		end
		
		if( xPos[18:7] > 288 && xPos[18:7] <=  384) begin						// VIERDE KOLOM
			if( yPos[18:7] > (100 * rowCounter) && yPos[18:7] <=  (100 * (rowCounter + 1))) begin
				if(counter < 2500000)
				begin
					counter = counter + 1;
				end
				else
				begin
					led = 8'b00001000;
					
					colValue04 = colValue04 + 1;
					if (colValue04 > 6)
						colValue04 = 1;
				end
								
			end
		end
		
		if( xPos[18:7] > 384 && xPos[18:7] <=  480) begin						// PEGS !!!!!
			if( yPos[18:7] > (100 * rowCounter) && yPos[18:7] <=  (100 * (rowCounter + 1))) begin
				if(counter < 2500000)
				begin
					counter = counter + 1;
				end
				else
				begin
					if ((colValue01 != 0) && (colValue02 != 0) && (colValue03 != 0) && (colValue04 != 0))
						calculate = 1;
				end
								
			end
		end
		
	end // if(!calculate)
	
	
	else begin   // Als calculate true is
		if(calculateCounter < 25000000) begin
			calculateCounter = calculateCounter + 1;
		end
		else begin	
		
			// TODO Calculate pegs
		
			calculateCounter = 0;
			calculate = 0;
			
			rowCounter = rowCounter - 1;		// volgende rij wordt selecteerbaar
			
			led = 8'b00001111;
			
			// toch hier een bool voor next round en de rest hier onder pas zetten in het volgende deel
			colValue01 = 0;
			colValue02 = 0;
			colValue03 = 0;
			colValue04 = 0;
			
		end
	end
end
endmodule