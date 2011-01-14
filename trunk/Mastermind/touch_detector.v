module touch_detector(clock, reset, oLEDR, x_coord, y_coord, oLEDG, new_coord, oStart, nrOfRows, 
						Value01, Value02, Value03, Value04, WhitePegs, BlackPegs, nextRound);

parameter touch_delay = 15000000;

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
output 			nextRound;

// --------------------------------------

reg start;
reg next = 0;
reg firsttime = 1;
reg calculate = 0;		// als deze 1 is dan berekenen (geset bij het aanraken van pegs)
reg [24:0] counter = 0;
reg [24:0] calculateCounter = 0;

reg	[2:0]	rowCounter;
reg [31:0]	randomGen;
reg	[11:0]	solution;
reg	[11:0]	colValue;
reg	[11:0]	solutionCOPY;
reg	[11:0]	colValueCOPY;
reg	[2:0]	wPegs;	//white
reg	[2:0]	bPegs;	//black

reg [7:0] 	led;
reg [17:0] 	ledrs;
reg [5:0] 	i;
reg [4:0] 	activeNull;

reg [18:0]	xPos;	// 11 bits + 7 (die we straks extra voorzien)
reg [18:0]	yPos;
reg [18:0]	xPosCOPY;
reg [18:0]	yPosCOPY;

wire [14:0] rowCoord;
wire [14:0] rowCoordTop;

reg button = 0;


// --------------------------------------

assign rowCoord = (100 * rowCounter);
assign rowCoordTop = (100 * (rowCounter + 1));

assign oLEDR = ledrs;
assign oLEDG = led;
assign oStart = start;

assign nrOfRows = rowCounter;
assign Value01 = colValue[2:0];
assign Value02 = colValue[5:3];
assign Value03 = colValue[8:6];
assign Value04 = colValue[11:9];
		
assign WhitePegs = wPegs;
assign BlackPegs = bPegs;
assign nextRound = next;




// ========================================================

always @(posedge clock or negedge reset)// or posedge reset)
begin
	if(!reset) begin			// RESET
		if (firsttime) begin
			randomGen = 32'b00000100011000110001100111111110; // 00000100 01100011 00011001 11111110  (2, 6, 5, 2)
			firsttime = 0;
		end
	end else begin
		randomGen = { randomGen[0] ^ randomGen[1] ^ randomGen[2] ^ randomGen[12], randomGen[31:1]};
	end
end		


always @( posedge clock or negedge reset)
begin
	if (!reset) begin			// RESET
		start = 0;
		next = 0;
		calculateCounter = 0;
		calculate = 0;
		led = 8'b00000000;
		ledrs = 18'b0;
		xPosCOPY = 0;
		yPosCOPY = 0;
		
		rowCounter = 7;         // moet verminderd w
		
		colValue = 12'b0;
		wPegs = 0;
		bPegs = 0;
		
		
		// Zet random waarden in de solutions  - DEBUG DIT ANDERS	
		solution[2:0] = randomGen[1] + randomGen[5] + randomGen[10] + randomGen[15] + randomGen[20]+ randomGen[25];
		solution[5:3] = randomGen[2] + randomGen[6] + randomGen[11] + randomGen[16] + randomGen[21]+ randomGen[26];
		solution[8:6] = randomGen[3] + randomGen[7] + randomGen[12] + randomGen[17] + randomGen[22]+ randomGen[27];
		solution[11:9] = randomGen[4] + randomGen[8] + randomGen[13] + randomGen[18] + randomGen[23]+ randomGen[28];
		
		if (solution[2:0] == 0)
			solution[2:0] = 1;
		if (solution[5:3] == 0)
			solution[5:3] = 1;
		if (solution[8:6] == 0)
			solution[8:6] = 1;
		if (solution[11:9] == 0)
			solution[11:9] = 1;
		
		//LED OUTPUT ------------------------------------------
		ledrs[2:0] = solution[2:0];
		ledrs[5:3] = solution[5:3];
		ledrs[8:6] = solution[8:6];
		ledrs[11:9] = solution[11:9];

	end
	else if(!calculate ) begin	
		start = 1;	
		
		xPos[18:0] = (x_coord * 16) - x_coord + 6'b100000;		// 6'b100000 = 0,5 voor juiste afronding
		// 15 = 480/4096*128 --> 128 is bitshift, minder zwaar dan deling
		// xPos[18:7] te gebruiken waarden, omgekeerde bitshift --> mappen wat op bit 7 staat nr 0; 
		yPos[18:0] = (y_coord * 16) + (y_coord * 8) + y_coord + 6'b100000;
		// 16 + 8 + 1 = 25

		
		//nieuwe ronde
		if (next == 1) begin 
			if (rowCounter != 0 && led != 8'b11111111) //als het spel  niet gedaan is
			begin 
				if(calculateCounter < 25000000) begin //zorg dat waarden even doorgegeven kunnen worden
					calculateCounter = calculateCounter + 1;
				end
				else
				begin	
					calculateCounter = 0;
					rowCounter = rowCounter - 1;		// volgende rij wordt selecteerbaar
					colValue = 12'b0;
					wPegs = 3'b0;
					bPegs = 3'b0;
					next = 0;
				end
			end
		end
		//ronde bezig
		else 
		begin
			if(counter < touch_delay)	// touch toggle
				counter = counter + 1;
			else
			begin
				counter = 0;
				if(yPos[18:7] > rowCoord && yPos[18:7] <=  rowCoordTop) //rij 
				begin
					if( xPos[18:7] > 0 && xPos[18:7] <=  96) 
						begin							// EERSTE KOLOM
							led = 8'b00000001;
							if (xPos != xPosCOPY || yPos != yPosCOPY) 
							begin  // check vorige coord, als zelfde nog in zelfde press
		
								colValue[2:0] = colValue[2:0] + 1; 		// ga nr volgende kleur (als > 6 terug nr eerste)
								if (colValue[2:0] > 6)
									colValue[2:0] = 1;
									
								xPosCOPY <= xPos;
								yPosCOPY <= yPos;
							end	
							//LED OUTPUT ------------------------------------------
							//ledrs[2:0] = colValue[2:0];															
						end
					
					else if( xPos[18:7] > 96 && xPos[18:7] <=  192)
						begin						// TWEEDE KOLOM			
							led = 8'b00000010;
						
							if (xPos != xPosCOPY || yPos != yPosCOPY)
							begin
						
								colValue[5:3] = colValue[5:3] + 1;
								if (colValue[5:3] > 6)
									colValue[5:3] = 1;
							
								xPosCOPY <= xPos;
								yPosCOPY <= yPos;
							end
							//LED OUTPUT ------------------------------------------
							//ledrs[5:3] = colValue[5:3];
						end

					else if( xPos[18:7] > 192 && xPos[18:7] <=  288) 
						begin						// DERDE KOLOM

							led = 8'b00000100;
							
							if (xPos != xPosCOPY || yPos != yPosCOPY)
							begin
								colValue[8:6] = colValue[8:6] + 1;
								if (colValue[8:6] > 6)
									colValue[8:6] = 1;
								
								xPosCOPY <= xPos;
								yPosCOPY <= yPos;	
							end
							//LED OUTPUT ------------------------------------------
							//ledrs[8:6] = colValue[8:6];
						end
						
					else if( xPos[18:7] > 288 && xPos[18:7] <=  384) 
						begin						// VIERDE KOLOM							
							led = 8'b00001000;

							if (xPos != xPosCOPY || yPos != yPosCOPY) 
							begin
								colValue[11:9] = colValue[11:9] + 1;
								if (colValue[11:9] > 6)
									colValue[11:9] = 1;
								
								xPosCOPY <= xPos;
								yPosCOPY <= yPos;
							end
							//LED OUTPUT ------------------------------------------
							//ledrs[11:9] = colValue[11:9];									
						end
						
					else if( xPos[18:7] > 384 && xPos[18:7] <= 480)
						if ((colValue[2:0] != 0) && (colValue[5:3] != 0) && (colValue[8:6] != 0) && (colValue[11:9] != 0))
							calculate = 1;
						
				end
			end
		end	
	end // if(!calculate)
	
	else begin   // Als calculate true is
		// Calculate white pegs
		solutionCOPY = solution;
		colValueCOPY = colValue;
		activeNull = 4'b1111;
		
		for (i = 0; i <= 16; i = i + 1) // check op dezelfde kleur
		begin
			if (i == 4 || i == 8 || i == 12) begin
				solutionCOPY = solutionCOPY >> 3;
				colValueCOPY = colValue;
				if (!activeNull[0])
					colValueCOPY[2:0] = 3'b0;
				if (!activeNull[1])
					colValueCOPY[5:3] = 3'b0;
				if (!activeNull[2])
					colValueCOPY[8:6] = 3'b0;
				if (!activeNull[3])
					colValueCOPY[11:9] = 3'b0;
					
				// zet hier colValue dingen nr 0 - DEBUG
			end
			
			if ( (solutionCOPY[2:0] == colValueCOPY[2:0]) && (solutionCOPY[2:0] != 0)) begin
				wPegs = wPegs + 1;
				solutionCOPY[2:0] = 3'b0;
				
				if ( i[1:0] == 2'b00 ) begin
					activeNull[0] =0;
				end 
				else if ( i[1:0] == 2'b01 ) begin
					activeNull[1] = 0;
				end 
				else if ( i[1:0] == 2'b10 ) begin
					activeNull[2] = 0;
				end 
				else if ( i[1:0] == 2'b11 ) begin
					activeNull[3] = 0;
				end 
				
			end
			
			colValueCOPY = colValueCOPY >> 3;
		end
		
		// Calculate black pegs
		solutionCOPY = solution;
		colValueCOPY = colValue;

		for (i = 0; i <= 3; i = i + 1) 
		begin
			if (solutionCOPY[2:0] == colValueCOPY[2:0]) begin
				if (wPegs != 0)
					wPegs = wPegs - 1;
				if (bPegs != 4)
					bPegs = bPegs + 1;
			end
			colValueCOPY = colValueCOPY >> 3;
			solutionCOPY = solutionCOPY >> 3;
		end
		
		//gewonnen
		if (bPegs == 4) begin
			led[7:0] = 8'b11111111;
		end
		else begin
			led[7:0] = 8'b00001111;
		end
		
		//LED OUTPUT ------------------------------------------
		ledrs[14:12] = wPegs[2:0];
		ledrs[17:15] = bPegs[2:0];
		
		// Reset booleans
		calculateCounter = 0;
		calculate = 0;
		
		// Zorg dat de codes een tijdje doorgegeven kunnen worden.
		next = 1;		
	end
end
endmodule