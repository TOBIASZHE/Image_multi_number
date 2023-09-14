`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/21 09:31:00
// Design Name: 
// Module Name: digital_recognition
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


module digital_recognition(
	input						clk,
	input						frame_vs,
	input						rst_n,
	input						post_Bit,	//threshold value
	input			[10:0]		hcount,
	input			[10:0]		vcount,
	input			[10:0]		hcount_l,
	input			[10:0]		hcount_r,
	input			[10:0]		vcount_l,
	input			[10:0]		vcount_r,
	input						post_Bit_rise,
	input						post_Bit_fall,
	input						frame_vs_rise,
	input						frame_vs_fall,
	input			[2:0]		frame_cnt,
	output	reg					x1_l,
	output	reg					x1_r,
	output	reg					x2_l,
	output	reg					x2_r,
	output	reg		[3:0]		y,
	output	reg		[3:0]		x1,
	output	reg		[3:0]		x2,
	output	reg		[10:0]		h_2,
	output	reg		[10:0]		v_5,
	output	reg		[10:0]		v_3
	
);

	
	wire       y_flag;
	reg        y_flag_r0;
	reg        y_flag_r1;
	wire       y_flag_fall;
	reg        wr_y_en;
	reg        rd_y_en;
	reg [10:0] y_cnt;
	
	reg frame_vs_rise_r0;
	reg frame_vs_rise_r1;
	reg frame_vs_rise_r2;
	
	reg [10:0] hcount_l_r;
	reg [10:0] hcount_r_r;
	reg [10:0] vcount_l_r;
	reg [10:0] vcount_r_r;
	
	// reg [10:0] h_2; //(hcount_l + hcount_r)/2
	// reg [10:0] v_5; //(vcount_r - vcount_l)*2/5 + vcount_l
	// reg [10:0] v_3; //(vcount_r - vcount_l)*2/3 + vcount_l
	
	reg [10:0] h_2_r; //(hcount_l + hcount_r)/2
	reg [10:0] v_5_r; //(vcount_r - vcount_l)*2/5 + vcount_l
	reg [10:0] v_3_r; //(vcount_r - vcount_l)*2/3 + vcount_l
	
	//-------------------------------------------------
	//pipiline
	//-------------------------------------------------
	always @(posedge clk ) begin
		frame_vs_rise_r0 <= frame_vs_rise;
		frame_vs_rise_r1 <= frame_vs_rise_r0;
		frame_vs_rise_r2 <= frame_vs_rise_r1;
	end
	//-------------------------------------------------
	// 1/2 x            2/5 y             2/3 y
	//-------------------------------------------------
	always @(posedge clk or negedge rst_n) begin  
		if(!rst_n) begin
			h_2 <= 11'd0;
			v_5 <= 11'd0;
			v_3 <= 11'd0;
			h_2_r <= 11'd0;
			v_5_r <= 11'd0;
			v_3_r <= 11'd0;
			hcount_l_r <= 11'b0;
			hcount_r_r <= 11'b0;
			vcount_l_r <= 11'b0;
			vcount_r_r <= 11'b0;
		end
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise) begin
				hcount_l_r <= hcount_l;
				hcount_r_r <= hcount_r;
				vcount_l_r <= vcount_l;
				vcount_r_r <= vcount_r;
			end
			else if(frame_vs_rise_r0) begin
				h_2_r <=  (hcount_r_r + hcount_l_r)>>1;
				//(vcount_r - vcount_l)*2/5 + vcount_l
				//(vcount_r - vcount_l)*2/3 + vcount_l
				v_5_r <=  ( (vcount_r_r - vcount_l_r) )/4 + vcount_l_r;
				v_3_r <=  ( (vcount_r_r - vcount_l_r)*2 )/3 + vcount_l_r;
			end
			else if(frame_vs_rise_r1) begin
				h_2 <= h_2_r;
				v_5 <= v_5_r;
				v_3 <= v_3_r;
			end
		end
		else 
			;
	end

	//----------------------------------------------------
	// x1 
	//----------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x1 <= 4'd0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				x1 <= 4'd0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_5))begin
				if(post_Bit_fall)
					x1 <= x1 + 4'd1;
				else
					x1 <= x1;
			end
		end
		else
			x1 <= x1;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x1_l <= 1'b0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				x1_l <= 1'b0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_5) && (hcount > h_2)) //left
				if(post_Bit_fall)
					x1_l <= 1'b1;
				else
					x1_l <= x1_l;
		end
		else
			x1_l <= x1_l;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x1_r <= 1'b0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				x1_r <= 1'b0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_5) && (hcount < h_2)) 
				if(post_Bit_fall)
					x1_r <= 1'b1;
				else
					x1_r <= x1_r;
		end
		else
			x1_r <= x1_r;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x2 <= 4'd0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise) //frame_vs rising edge 
				x2 <= 4'd0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_3)) 
				if(post_Bit_fall)
					x2 <= x2 + 4'd1;
				else
					x2 <= x2;
		end
		else
			x2 <= x2;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x2_l <= 1'b0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				x2_l <= 1'b0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_3) && (hcount > h_2))
				if(post_Bit_fall)
					x2_l <= 1'b1;
				else
					x2_l <= x2_l;
		end
		else
			x2_l <= x2_l;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			x2_r <= 1'b0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				x2_r <= 1'b0;
			else if((hcount > hcount_l) && (hcount < hcount_r) && (vcount == v_3) && (hcount < h_2))
				if(post_Bit_fall)
					x2_r <= 1'b1;
				else
					x2_r <= x2_r;
		end
		else
			x2_r <= x2_r;
	end


	//----------------------------------------------------
	// y 
	//----------------------------------------------------
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			y_cnt <= 11'd0;
		else if(frame_cnt == 3'd3) begin
			if(frame_vs_rise)//frame_vs rising edge 
				y_cnt <= 11'd240;
			else if(frame_vs)
				y_cnt <=  y_cnt - 11'd1;
			else if(y_cnt == 11'd0)
				y_cnt <=  y_cnt;
		end
		else
			;
	end


	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			rd_y_en <= 1'b0;
		else if(frame_cnt == 3'd0) begin
			if(frame_vs && (y_cnt > 0))
				rd_y_en <= 1'b1;
			else
				rd_y_en <= 1'b0;
		end
		else
			;
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			wr_y_en <= 1'b0;
		else if(frame_cnt == 3'd3) begin 
			if(hcount == h_2)
				wr_y_en <= 1'b1;
			else
				wr_y_en <= 1'b0;
		end
		else
			;
	end

	always @(posedge clk ) begin
		y_flag_r0 <= y_flag;
		y_flag_r1 <= y_flag_r0;
	end

	assign y_flag_fall = (!y_flag_r0 && y_flag_r1) ? 1'b1:1'b0;

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)
			y <= 4'd0;
		else if(frame_cnt == 3'd0) begin
			if(frame_vs_rise)//frame_vs rising edge 
				y <= 4'd0;
			else  if(y_flag_fall)
				y <= y + 4'd1;
			else
				y <= y;
		end
		else
		;
	end

	
	fifo_generator_2 fifo_generator_2_inst(
		.clk		(clk		),			// input wire clk
		.din		(post_Bit	),			// input wire [0 : 0] din
		.wr_en		(wr_y_en	),			// input wire wr_en
		.rd_en		(rd_y_en	),			// input wire rd_en
		.dout		(y_flag		),			// output wire [0 : 0] dout
		.full		(			),			// output wire full
		.empty		(			)			// output wire empty
);


endmodule 
