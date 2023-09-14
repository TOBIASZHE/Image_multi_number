`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/20 10:53:39
// Design Name: 
// Module Name: Binary
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Binary
(
		//global clock
		input					clk,  				//cmos video pixel clock
		input					rst_n,				//global reset
	
		//Image data prepred to be processd
		input					per_frame_vsync,	//Prepared Image data vsync valid signal
		input					per_frame_href,		//Prepared Image data href vaild  signal
		input					per_frame_clken,	//Prepared Image data output/capture enable clock
		input		[7:0]		per_img_Y,			//Prepared Image brightness input
		
		//Image data has been processd
		output	reg				post_frame_vsync,	//Processed Image data vsync valid signal
		output	reg				post_frame_href,	//Processed Image data href vaild  signal
		output	reg				post_frame_clken,	//Processed Image data output/capture enable clock
		output					post_img_Bit			//Processed Image Bit flag outout(1: Value, 0:inValid)
		
);

	//图像二值化 step1
	// always @(posedge clk or negedge rst_n) begin
		// if(!rst_n) 
			// post_img_Bit <= 1'b0;
		// else if(per_img_Y > 128) 
			// post_img_Bit <= 1'b0;
		// else
			// post_img_Bit <= 1'b1;
	// end
	assign post_img_Bit = (per_img_Y > 16)?1'b1:1'b0;
	
	
	//------------------------------------------
	//lag 1 clocks signal sync  
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			begin
				post_frame_vsync <= 1'b0;
				post_frame_href  <= 1'b0;
				post_frame_clken <= 1'b0;
			end
		else
			begin
				post_frame_vsync <= per_frame_vsync;
				post_frame_href  <= per_frame_href;
				post_frame_clken <= per_frame_clken;
			end
	end
	
	
endmodule

