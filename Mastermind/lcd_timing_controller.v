module lcd_timing_controller		(
						iCLK, 				// LCD display clock
						iRST_n, 			// systen reset
						// SDRAM SIDE 
						iREAD_DATA1, 		// R and G  color data form sdram 	
						iREAD_DATA2,		// B color data form sdram
						oREAD_SDRAM_EN,		// read sdram data control signal
						//LCD SIDE
						oHD,				// LCD Horizontal sync 
						oVD,				// LCD Vertical sync 	
						oDEN,				// LCD Data Enable
						oLCD_R,				// LCD Red color data 
						oLCD_G,             // LCD Green color data  
						oLCD_B,             // LCD Blue color data  
						// onze vars!!!!
						oStart, 
						nrOfRows, 
						rValue01, 
						rValue02, 
						rValue03, 
						rValue04, 
						WhitePegs, 
						BlackPegs,
						nextRound
						);
//============================================================================
// PARAMETER declarations
//============================================================================
parameter H_LINE = 1056;
parameter Hsync_Blank = 216;
parameter Hsync_Front_Porch = 40;

parameter V_LINE = 525;
parameter Vertical_Back_Porch = 35;
parameter Vertical_Front_Porch = 10;
//onze
parameter y_base = 34;
parameter x_base = 215;
parameter y_offset = 96;
parameter x_offset = 100;
//===========================================================================
// PORT declarations
//===========================================================================
input			iCLK;   
input			iRST_n;
input	[15:0]	iREAD_DATA1;
input	[15:0]	iREAD_DATA2;
output			oREAD_SDRAM_EN;
output	[7:0]	oLCD_R;		
output  [7:0]	oLCD_G;
output  [7:0]	oLCD_B;
output			oHD;
output			oVD;
output			oDEN;

// onze vars
input oStart;
input	[2:0]	nrOfRows;
input	[2:0]	rValue01;	// 0 = leeg, 1-6 zijn de kleuren
input	[2:0]	rValue02;
input	[2:0]	rValue03;
input	[2:0]	rValue04;
input	[2:0]	WhitePegs; // max 4
input	[2:0]	BlackPegs;
input 			nextRound;

wire [2:0] col;
wire [2:0] row;

reg [2:0] colCount = 0;
reg [2:0] rowCount = 0;
reg [1:0] squareFound = 0;

//kleur output
reg [7:0] R_out;
reg [7:0] G_out;
reg [7:0] B_out;

wire [2:0] currentValue; //huidige kleur in col/row

wire [12:0] current_y_center;
wire [12:0] current_x_center;
wire [12:0] current_x_center_small;
wire [12:0] current_y_center_small;

//SPELBORD
reg [83:0] boardState;
reg [64:0] pegState;

reg [2:0] whiteTemp;
reg [2:0] blackTemp;

reg [2:0] pegLoc;
reg [2:0] pegColour;

reg pegsSet = 0;

wire pegCol;
wire pegRow;

						
//=============================================================================
// REG/WIRE declarations
//=============================================================================
reg		[10:0]  x_cnt;  
reg		[9:0]	y_cnt; 
wire	[7:0]	read_red;
wire	[7:0]	read_green;
wire	[7:0]	read_blue; 
wire			display_area;
wire			oREAD_SDRAM_EN;
reg				mhd;
reg				mvd;
reg				oHD;
reg				oVD;
reg				oDEN;
reg		[7:0]	oLCD_R;
reg		[7:0]	oLCD_G;	
reg		[7:0]	oLCD_B;		
//=============================================================================
// Structural coding
//=============================================================================

// This signal control reading data form SDRAM , if high read color data form sdram  .
assign	oREAD_SDRAM_EN = (	(x_cnt>Hsync_Blank-2)&&
							(x_cnt<(H_LINE-Hsync_Front_Porch-1))&&
							(y_cnt>(Vertical_Back_Porch-1))&&
							(y_cnt<(V_LINE - Vertical_Front_Porch))
						 )?  1'b1 : 1'b0;
						
// This signal indicate the lcd display area .
assign	display_area = ((x_cnt>(Hsync_Blank-1)&& //>215
						(x_cnt<(H_LINE-Hsync_Front_Porch))&& //< 1016
						(y_cnt>(Vertical_Back_Porch-1))&& 
						(y_cnt<(V_LINE - Vertical_Front_Porch))
						))  ? 1'b1 : 1'b0;

assign	read_red 	= display_area ? iREAD_DATA1[15:8] : 8'b0;
assign	read_green 	= display_area ? iREAD_DATA1[7:0]: 8'b0;
assign	read_blue 	= display_area ? iREAD_DATA2[7:0] : 8'b0;

//col en row bepalen
assign col = (y_cnt-y_base) / (y_offset);
assign row = (x_cnt-x_base) / (x_offset);

//centrum van hokje
assign current_x_center = (x_base + (x_offset)*row)+50;
assign current_y_center = (y_base + (y_offset)*col)+48;

assign pegCol = (y_cnt < current_y_center ? 0 : 1);
assign pegRow = (x_cnt < current_x_center ? 0 : 1);

assign current_x_center_small = (pegRow == 0 ? current_x_center-25 : current_x_center+25);
assign current_y_center_small = (pegCol == 0 ? current_y_center-24 : current_y_center+24);

assign currentValue = 
(
	//huidige rij
	row == nrOfRows ? 
		(col == 0 ? 
			rValue01[2:0] : 
			(col == 1 ? 
				rValue02[2:0] : 
				(col == 2 ? 
					rValue03[2:0] :	
					(col == 3 ? 
						rValue04[2:0] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[57:56] : pegState[59:58]) :
								(pegCol == 0 ? pegState[61:60] : pegState[63:62])
							) : 1'b0
						)
					)
				)
			) 
		) :
	//oude & nieuwe rijen
	(row == 1 ?
		(col == 0 ? 
			boardState[74:72] : 
			(col == 1 ? 
				boardState[77:75] : 
				(col == 2 ? 
					boardState[80:78] :	
					(col == 3 ? 
						boardState[83:81] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[49:48] : pegState[51:50]) :
								(pegCol == 0 ? pegState[53:52] : pegState[55:54])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 2 ?
		(col == 0 ? 
			boardState[62:60] : 
			(col == 1 ? 
				boardState[65:63] : 
				(col == 2 ? 
					boardState[68:66] :	
					(col == 3 ? 
						boardState[71:69] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[41:40] : pegState[43:42]) :
								(pegCol == 0 ? pegState[45:44] : pegState[47:46])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 3 ?
		(col == 0 ? 
			boardState[50:48] : 
			(col == 1 ? 
				boardState[53:51] : 
				(col == 2 ? 
					boardState[56:54] :	
					(col == 3 ? 
						boardState[59:57] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[33:32] : pegState[35:34]) :
								(pegCol == 0 ? pegState[37:36] : pegState[39:38])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 4 ?
		(col == 0 ? 
			boardState[38:36] : 
			(col == 1 ? 
				boardState[41:39] : 
				(col == 2 ? 
					boardState[44:42] :	
					(col == 3 ? 
						boardState[47:45] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[25:24] : pegState[27:26]) :
								(pegCol == 0 ? pegState[29:28] : pegState[31:30])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 5 ?
		(col == 0 ? 
			boardState[26:24] : 
			(col == 1 ? 
				boardState[29:27] : 
				(col == 2 ? 
					boardState[32:30] :	
					(col == 3 ? 
						boardState[35:33] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[17:16] : pegState[19:18]) :
								(pegCol == 0 ? pegState[21:20] : pegState[23:22])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 6 ?
		(col == 0 ? 
			boardState[14:12] : 
			(col == 1 ? 
				boardState[17:15] : 
				(col == 2 ? 
					boardState[20:18] :	
					(col == 3 ? 
						boardState[23:21] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[9:8] : pegState[11:10]) :
								(pegCol == 0 ? pegState[13:12] : pegState[15:14])
							) : 1'b0
						)
					)
				)
			) 
		) :
	(row == 7 ?
		(col == 0 ? 
			boardState[2:0] : 
			(col == 1 ? 
				boardState[5:3] : 
				(col == 2 ? 
					boardState[8:6] :	
					(col == 3 ? 
						boardState[11:9] : 
						(col == 4 ? 
							(pegRow == 0 ?
								(pegCol == 0 ? pegState[1:0] : pegState[3:2]) :
								(pegCol == 0 ? pegState[5:4] : pegState[7:6])
							) : 1'b0
						)
					)
				)
			) 
		) : 1'b0
	)
	)
	)
	)
	)	
	)	
	)
);

///////////////////////// x  y counter  and lcd hd generator //////////////////
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
		begin
			x_cnt <= 11'd0;	
			mhd  <= 1'd0;  	
		end	
		else if (x_cnt == (H_LINE-1))
		begin
			x_cnt <= 11'd0;
			mhd  <= 1'd0;
		end	   
		else
		begin
			x_cnt <= x_cnt + 11'd1;
			mhd  <= 1'd1;
		end	
	end

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			y_cnt <= 10'd0;
		else if (x_cnt == (H_LINE-1))
		begin
			if (y_cnt == (V_LINE-1))
				y_cnt <= 10'd0;
			else
				y_cnt <= y_cnt + 10'd1;	
		end
	end
////////////////////////////// touch panel timing //////////////////

always@(posedge iCLK  or negedge iRST_n)
	begin
		if (!iRST_n)
			mvd  <= 1'b1;
		else if (y_cnt == 10'd0)
			mvd  <= 1'b0;
		else
			mvd  <= 1'b1;
	end			




//KLEUREN
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
		begin
			R_out = read_red;
			G_out = read_green;
			B_out = read_blue;
		end
		else
		begin
			if (col != 4)
			begin
				//kleur aanpassen aan waarde
				if (currentValue == 1) //RED
				begin 
					R_out = 8'hDE;
					G_out = 8'h12;
					B_out = 8'h12;
				end 
				else if (currentValue == 2) //GREEN
				begin 
					R_out = 8'h56;
					G_out = 8'hbf;
					B_out = 8'h19;
				end 
				else if (currentValue == 3) //BLUE
				begin
					R_out = 8'h1a;
					G_out = 8'h66;
					B_out = 8'hb8;
				end 
				else if (currentValue == 4) //ORANGE
				begin 
					R_out = 8'hf0;
					G_out = 8'h9b;
					B_out = 8'h24;
				end 
				else if (currentValue == 5) //PURPLE
				begin 
					R_out = 8'h8b;
					G_out = 8'h1a;
					B_out = 8'hb8;
				end 
				else if (currentValue == 6) //YELLOW
				begin 
					R_out = 8'hff;
					G_out = 8'hEE;
					B_out = 8'h00;
				end 
				else //LEEG
				begin 
					R_out = read_red;
					G_out = read_green;
					B_out = read_blue;
				end 
			end
			else //kleine pegs
			begin
				if (currentValue == 1) //black
				begin
					R_out = 8'h00;
					G_out = 8'h00;
					B_out = 8'h00;
				end
				else if (currentValue == 2) //white
				begin
					R_out = 8'hff;
					G_out = 8'hff;
					B_out = 8'hff;
				end
				else //LEEG
				begin 
					R_out = read_red;
					G_out = read_green;
					B_out = read_blue;
				end 
			end
		end
	end
				

//NEW ROUND
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				boardState = 84'd0;
				pegState = 63'd0;
				pegsSet = 0;
			end
		else if (nextRound)
			begin
			//KLEINE PEGS locatie bepalen
			if (pegsSet == 0)
				begin
					pegLoc = 0;
					whiteTemp[2:0] = WhitePegs[2:0];
					blackTemp[2:0] = BlackPegs[2:0];
					pegsSet = 1;
				end
			
			if (nrOfRows == 7)
				begin
					boardState[2:0] = rValue01[2:0];
					boardState[5:3] = rValue02[2:0];
					boardState[8:6] = rValue03[2:0];
					boardState[11:9] = rValue04[2:0];
											
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
														
						if (pegLoc == 0)
							pegState[1:0] = pegColour;
						else if (pegLoc == 1)
							pegState[3:2] = pegColour;
						else if (pegLoc == 2)
							pegState[5:4] = pegColour;
						else if (pegLoc == 3)
							pegState[7:6] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 6)
				begin
					boardState[14:12] = rValue01[2:0];
					boardState[17:15] = rValue02[2:0];
					boardState[20:18] = rValue03[2:0];	
					boardState[23:21] = rValue04[2:0];
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
	
						if (pegLoc == 0)
							pegState[9:8] = pegColour;
						else if (pegLoc == 1)
							pegState[11:10] = pegColour;
						else if (pegLoc == 2)
							pegState[13:12] = pegColour;
						else if (pegLoc == 3)
							pegState[15:14] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 5)
				begin
					boardState[26:24] = rValue01[2:0];
					boardState[29:27] = rValue02[2:0];
					boardState[32:30] = rValue03[2:0];
					boardState[35:33] = rValue04[2:0];
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
				
						if (pegLoc == 0)
							pegState[17:16] = pegColour;
						else if (pegLoc == 1)
							pegState[19:18] = pegColour;
						else if (pegLoc == 2)
							pegState[21:20] = pegColour;
						else if (pegLoc == 3)
							pegState[23:22] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 4)
				begin
				
					boardState[38:36] = rValue01[2:0]; 
					boardState[41:39] = rValue02[2:0];
					boardState[44:42] = rValue03[2:0];
					boardState[47:45] = rValue04[2:0];
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
					
						if (pegLoc == 0)
							pegState[25:24] = pegColour;
						else if (pegLoc == 1)
							pegState[27:26] = pegColour;
						else if (pegLoc == 2)
							pegState[29:28] = pegColour;
						else if (pegLoc == 3)
							pegState[31:30] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 3)
				begin
					boardState[50:48] = rValue01[2:0]; 
					boardState[53:51] = rValue02[2:0]; 
					boardState[56:54] = rValue03[2:0];
					boardState[59:57] = rValue04[2:0];
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
					
						if (pegLoc == 0)
							pegState[33:32] = pegColour;
						else if (pegLoc == 1)
							pegState[35:34] = pegColour;
						else if (pegLoc == 2)
							pegState[37:36] = pegColour;
						else if (pegLoc == 3)
							pegState[39:38] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 2)
				begin
					boardState[62:60] = rValue01[2:0];
					boardState[65:63] = rValue02[2:0];
					boardState[68:66] = rValue03[2:0];
					boardState[71:69] = rValue04[2:0];
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
						
						if (pegLoc == 0)
							pegState[41:40] = pegColour;
						else if (pegLoc == 1)
							pegState[43:42] = pegColour;
						else if (pegLoc == 2)
							pegState[45:44] = pegColour;
						else if (pegLoc == 3)
							pegState[47:46] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 1)
				begin
					boardState[74:72] = rValue01[2:0]; 
					boardState[77:75] = rValue02[2:0]; 
					boardState[80:78] = rValue03[2:0];	
					boardState[83:81] = rValue04[2:0]; 
					
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
					
						if (pegLoc == 0)
							pegState[49:48] = pegColour;
						else if (pegLoc == 1)
							pegState[51:50] = pegColour;
						else if (pegLoc == 2)
							pegState[53:52] = pegColour;
						else if (pegLoc == 3)
							pegState[55:54] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
			else if (nrOfRows == 0)
				begin
					if (pegLoc < 4)
					begin 
						if (blackTemp > 0)
						begin
							pegColour = 1;
							blackTemp = blackTemp - 1;
						end
						else if (whiteTemp > 0)
						begin
							pegColour = 2;
							whiteTemp = whiteTemp - 1;
						end
						else 
							pegColour = 0;
				
						if (pegLoc == 0)
							pegState[57:56] = pegColour;
						else if (pegLoc == 1)
							pegState[59:58] = pegColour;
						else if (pegLoc == 2)
							pegState[61:60] = pegColour;
						else if (pegLoc == 3)
							pegState[63:62] = pegColour;
						pegLoc = pegLoc + 1;
					end
				end
		end
		else
			pegsSet = 0;
	end
	

//UITTEKENEN
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				oHD	<= 1'd0;
				oVD	<= 1'd0;
				oDEN <= 1'd0;
				oLCD_R <= 8'd0;
				oLCD_G <= 8'd0;
				oLCD_B <= 8'd0;
			end
		else
			begin
				oHD	<= mhd;
				oVD	<= mvd;
				oDEN <= display_area;	
	
				if (col <= 3)
				begin  				
					//CIRKEL !
					if((x_cnt-current_x_center)*(x_cnt-current_x_center)+(y_cnt-current_y_center)*(y_cnt-current_y_center) <  1681) //41*41
					begin	
						oLCD_R <= R_out;
						oLCD_G <= G_out;
						oLCD_B <= B_out;
					end		
					else
					begin
						oLCD_R <= read_red;
						oLCD_G <= read_green;
						oLCD_B <= read_blue;
					end
				end
				else //kleine pegs
				begin
					if((x_cnt-current_x_center_small)*(x_cnt-current_x_center_small)+(y_cnt-current_y_center_small)*(y_cnt-current_y_center_small) < 169) //13*13
					begin	
						oLCD_R <= R_out;
						oLCD_G <= G_out;
						oLCD_B <= B_out;
					end
					else
					begin
						oLCD_R <= read_red;
						oLCD_G <= read_green;
						oLCD_B <= read_blue;
					end
				end		
			end
	end
						
endmodule











