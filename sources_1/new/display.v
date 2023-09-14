`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/22 10:04:44
// Design Name: 
// Module Name: display
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


module display(
	input 					clk,
	input 					rst_n,
			
	input 					per_frame_vsync,
	input 					per_frame_href,
	input 					per_frame_clken,
	input 					per_img_Bit,
		
	input		[2:0]		frame_cnt,		//帧计数器
	
	//交点
	input					d1_x1_l,
	input					d1_x1_r,
	input					d1_x2_l,
	input					d1_x2_r,
	input		[3:0]		d1_y,
	input		[3:0]		d1_x1,
	input		[3:0]		d1_x2,
	input		[10:0]		d1_h_2,
	input		[10:0]		d1_v_5,
	input		[10:0]		d1_v_3,
	
	input					d2_x1_l,
	input					d2_x1_r,
	input					d2_x2_l,
	input					d2_x2_r,
	input		[3:0]		d2_y,
	input		[3:0]		d2_x1,
	input		[3:0]		d2_x2,
	input		[10:0]		d2_h_2,
	input		[10:0]		d2_v_5,
	input		[10:0]		d2_v_3,
	
	input					d3_x1_l,
	input					d3_x1_r,
	input					d3_x2_l,
	input					d3_x2_r,
	input		[3:0]		d3_y,
	input		[3:0]		d3_x1,
	input		[3:0]		d3_x2,
	input		[10:0]		d3_h_2,
	input		[10:0]		d3_v_5,
	input		[10:0]		d3_v_3,
	
	//边界
	input		[10:0]		hcount_l1,			//左边边界
	input		[10:0]		hcount_r1,			//右边边界
	input		[10:0]		hcount_l2,			//左边边界
	input		[10:0]		hcount_r2,			//右边边界
	input		[10:0]		hcount_l3,			//左边边界
	input		[10:0]		hcount_r3,			//右边边界
	input		[10:0]		vcount_l,			//上边边界
	input		[10:0]		vcount_r,			//下边边界
		
	output 					frame_vs_rise,		//帧上升沿
	output 					frame_vs_fall,		//帧下降沿
	output 					post_Bit_rise,		//二值化数据上升沿
	output 					post_Bit_fall,		//二值化数据下降沿
	output reg	[10:0]		hcount,				//行计数器
	output reg	[10:0]		vcount,				//场计数器
	
	output 					post_frame_vsync,
	output 					post_frame_href,
	output 					post_frame_clken,
	output reg	[7:0]		post_img_Y,
	output reg	[7:0]		disp_data1,			//输出识别的数据
	output reg	[7:0]		disp_data2,			//输出识别的数据
	output reg	[7:0]		disp_data3			//输出识别的数据
);

	//------------------------------------------------//
	//----场信号的边沿，就是一帧信号的起始结束标志----//
	//------------------------------------------------//
	reg frame_vs_r0,frame_vs_r1;
	
	always @(posedge clk) begin
		frame_vs_r0 <= per_frame_vsync;
		frame_vs_r1 <= frame_vs_r0;
	end
	
	assign frame_vs_rise  = (frame_vs_r0 && (!frame_vs_r1)) ? 1'b1 :1'b0;
	assign frame_vs_fall  = ((!frame_vs_r0) && frame_vs_r1) ? 1'b1 :1'b0;
	
	
	//------------------------------------------------//
	//------------------二值化信号的边界--------------//
	//------------------------------------------------//
	reg post_Bit_r0,post_Bit_r1;
	
	always @(posedge clk) begin
		post_Bit_r0 <= per_img_Bit;
		post_Bit_r1 <= post_Bit_r0;
	end
	
	assign post_Bit_rise = (post_Bit_r0 && (!post_Bit_r1)) ? 1'b1:1'b0; 
	assign post_Bit_fall = ((!post_Bit_r0) && post_Bit_r1) ? 1'b1:1'b0;
	
	
	//-------------------------------------------------------------//
	//------对输入的像素进行“行/场方向计数，得到其纵横坐标---------//
	//-------------------------------------------------------------//
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			begin
				hcount <= 11'd0;
				vcount <= 11'd0;
			end
		else
			if(frame_vs_rise)begin
				hcount <= 11'd0;
				vcount <= 11'd0;
			end
			else if(per_frame_clken) begin
				if(hcount < 320 - 1) begin
					hcount <= hcount + 1'b1;
					vcount <= vcount;
				end
				else begin
					hcount <= 11'd0;
					vcount <= vcount + 1'b1;
				end
			end
	end
	
	
	//-------------------------------------------------------------//
	//--------------------------数据显示---------------------------//
	//-------------------------------------------------------------//
	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) 
			post_img_Y <= 8'h00;
			
		//给每个数字画框
		else if (vcount >= vcount_l && vcount <= vcount_r && ( (hcount >= (hcount_l1 -1) && hcount <= hcount_l1 )|| (hcount >= hcount_r1 && hcount <= (hcount_r1 + 1)) ) )
			post_img_Y <= 8'ha1;
		else if (hcount >= hcount_l1 && hcount <= hcount_r1 && ( (vcount >= (vcount_l -1) && vcount <= vcount_l )|| (vcount >= vcount_r && vcount <= (vcount_r + 1)) ) )
			post_img_Y <= 8'ha1;
		else if (vcount >= vcount_l && vcount <= vcount_r && ( (hcount >= (hcount_l2 -1) && hcount <= hcount_l2 )|| (hcount >= hcount_r2 && hcount <= (hcount_r2 + 1)) ) )
			post_img_Y <= 8'ha1;
		else if (hcount >= hcount_l2 && hcount <= hcount_r2 && ( (vcount >= (vcount_l -1) && vcount <= vcount_l )|| (vcount >= vcount_r && vcount <= (vcount_r + 1)) ) )
			post_img_Y <= 8'ha1;
		else if (vcount >= vcount_l && vcount <= vcount_r && ( (hcount >= (hcount_l3 -1) && hcount <= hcount_l3 )|| (hcount >= hcount_r3 && hcount <= (hcount_r3 + 1)) ) )
			post_img_Y <= 8'ha1;
		else if (hcount >= hcount_l3 && hcount <= hcount_r3 && ( (vcount >= (vcount_l -1) && vcount <= vcount_l )|| (vcount >= vcount_r && vcount <= (vcount_r + 1)) ) )
			post_img_Y <= 8'ha1;
		
		//给每个数字的特征提取位置画线
		else if(hcount == d1_h_2)
			post_img_Y <= 8'h11;
		else if(vcount == d1_v_5)
			post_img_Y <= 8'h11;
		else if(vcount == d1_v_3)
			post_img_Y <= 8'h11;
		else if(hcount == d2_h_2)
			post_img_Y <= 8'h11;
		else if(vcount == d2_v_5)
			post_img_Y <= 8'h11;
		else if(vcount == d2_v_3)
			post_img_Y <= 8'h11;
		else if(hcount == d3_h_2)
			post_img_Y <= 8'h11;
		else if(vcount == d3_v_5)
			post_img_Y <= 8'h11;
		else if(vcount == d3_v_3)
			post_img_Y <= 8'h11;
		
		else if(per_img_Bit) 
			post_img_Y <= 8'hff;  //white
		else 
			post_img_Y <= 8'h00;  //dark
	end
	
	
	//------------------------------------------------------------//
	//---------------------------数字识别-------------------------//
	//------------------------------------------------------------//
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			disp_data1 <= 'd10;
		else if((frame_cnt == 3'd2) && frame_vs_rise)
			case({d1_y,d1_x1,d1_x2})
				12'b0010_0010_0010: disp_data1 <= 'd0;
				12'b0001_0001_0001: disp_data1 <= 'd1;
				12'b0011_0001_0001: begin
					case({d1_x1_l,d1_x1_r,d1_x2_l,d1_x2_r})
						4'b0110:disp_data1 <= 'd2;
						4'b1010:disp_data1 <= 'd3;
						4'b1001:disp_data1 <= 'd5;
						default:disp_data1 <= 'd0;
					endcase
				end 
				12'b0010_0001_0010: disp_data1 <= 'd4;
				12'b0011_0010_0001: disp_data1 <= 'd6;
				12'b0010_0001_0001: disp_data1 <= 'd7;
				12'b0011_0010_0010: disp_data1 <= 'd8;
				12'b0011_0001_0010: disp_data1 <= 'd9;
				default: disp_data1 <= 'd0;
			endcase
		else
			disp_data1 <= disp_data1; 
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			disp_data2 <= 'd10;
		else if((frame_cnt == 3'd2) && frame_vs_rise)
			case({d2_y,d2_x1,d2_x2})
				12'b0010_0010_0010: disp_data2 <= 'd0;
				12'b0001_0001_0001: disp_data2 <= 'd1;
				12'b0011_0001_0001: begin
					case({d2_x1_l,d2_x1_r,d2_x2_l,d2_x2_r})
						4'b0110:disp_data2 <= 'd2;
						4'b1010:disp_data2 <= 'd3;
						4'b1001:disp_data2 <= 'd5;
						default:disp_data2 <= 'd0;
					endcase
				end 
				12'b0010_0001_0010: disp_data2 <= 'd4;
				12'b0011_0010_0001: disp_data2 <= 'd6;
				12'b0010_0001_0001: disp_data2 <= 'd7;
				12'b0011_0010_0010: disp_data2 <= 'd8;
				12'b0011_0001_0010: disp_data2 <= 'd9;
				default: disp_data2 <= 'd0;
			endcase
		else
			disp_data2 <= disp_data2; 
	end
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			disp_data3 <= 'd10;
		else if((frame_cnt == 3'd2) && frame_vs_rise)
			case({d3_y,d3_x1,d3_x2})
				12'b0010_0010_0010: disp_data3 <= 'd0;
				12'b0001_0001_0001: disp_data3 <= 'd1;
				12'b0011_0001_0001: begin
					case({d3_x1_l,d3_x1_r,d3_x2_l,d3_x2_r})
						4'b0110:disp_data3 <= 'd2;
						4'b1010:disp_data3 <= 'd3;
						4'b1001:disp_data3 <= 'd5;
						default:disp_data3 <= 'd0;
					endcase
				end 
				12'b0010_0001_0010: disp_data3 <= 'd4;
				12'b0011_0010_0001: disp_data3 <= 'd6;
				12'b0010_0001_0001: disp_data3 <= 'd7;
				12'b0011_0010_0010: disp_data3 <= 'd8;
				12'b0011_0001_0010: disp_data3 <= 'd9;
				default: disp_data3 <= 'd0;
			endcase
		else
			disp_data3 <= disp_data3; 
	end
	
	
	
	assign post_frame_vsync = per_frame_vsync;
	assign post_frame_href  = per_frame_href ;
	assign post_frame_clken = per_frame_clken;



endmodule
