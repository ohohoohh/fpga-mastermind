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
						//out
						xPOS,
						yPOS
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
parameter y_offset = 97;
parameter x_offset = 101;
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
output [10:0] xPOS;
output [9:0] yPOS;

input oStart;
input	[2:0]	nrOfRows;
input	[2:0]	rValue01;	// 0 = leeg, 1-6 zijn de kleuren
input	[2:0]	rValue02;
input	[2:0]	rValue03;
input	[2:0]	rValue04;
input	[2:0]	WhitePegs; // max 4
input	[2:0]	BlackPegs;

reg [2:0] col = 0;
reg [2:0] row = 0;

reg [2:0] colCount = 0;
reg [2:0] rowCount = 0;
reg [1:0] squareFound = 0;

//kleur output
reg [7:0] R_out;
reg [7:0] G_out;
reg [7:0] B_out;

wire [2:0] currentValue; //huidige kleur in col/row

reg [12:0] current_y_base;
reg [12:0] current_x_base;

assign xPOS = x_cnt;
assign POS = y_cnt;

						
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

assign currentValue = (col == 0 ? rValue01[2:0] : 
							(col == 1 ? rValue02[2:0] :
									(col == 2 ? rValue03[2:0] :
											(col == 3 ? rValue04[2:0] : 1'b0))));

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
			//currentValue = row; //TEST (WEGDOEN!!!!)
		
			//kleur aanpassen aan waarde
			if (currentValue == 1) //RED
			begin 
				R_out = 8'hff;
				G_out = 8'h00;
				B_out = 8'h00;
			end 
			else if (currentValue == 2) //GREEN
			begin 
				R_out = 8'h00;
				G_out = 8'hff;
				B_out = 8'h00;
			end 
			else if (currentValue == 3) //BLUE
			begin 
				R_out = 8'h00;
				G_out = 8'h00;
				B_out = 8'hff;
			end 
			else if (currentValue == 4) //ORANGE
			begin 
				R_out = 8'hff;
				G_out = 8'ha5;
				B_out = 8'h00;
			end 
			else if (currentValue == 5) //PURPLE
			begin 
				R_out = 8'h80;
				G_out = 8'h00;
				B_out = 8'h80;
			end 
			else if (currentValue == 6) //YELLOW
			begin 
				R_out = 8'hff;
				G_out = 8'hff;
				B_out = 8'h00;
			end 
			else //LEEG
			begin 
				R_out = read_red;
				G_out = read_green;
				B_out = read_blue;
			end 
		end
	end
				

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
				
				//col en row bepalen
				col = (y_cnt-y_base) / (y_offset-1);
				row = (x_cnt-x_base) / (x_offset-1);
			
				//centrum van hokje
				current_x_base = (x_base + (x_offset-1)*row)+50; //eerst 	nrOfRows
				current_y_base = (y_base + (y_offset-1)*col)+48;
				
				if (col <= 3)
				begin  
					//CIRKEL !
					if((x_cnt-current_x_base)*(x_cnt-current_x_base)+(y_cnt-current_y_base)*(y_cnt-current_y_base) <  1681) //41*41
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
					oLCD_R <= read_red;
					oLCD_G <= read_green;
					oLCD_B <= read_blue;
				end		
			end
	end
						
endmodule











