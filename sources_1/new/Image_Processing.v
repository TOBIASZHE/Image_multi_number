`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 10:35:33
// Design Name: 
// Module Name: Image_Processing
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


module Image_Processing(
	input 					clk,
	input 					rst_n,
			
	input 					per_frame_vsync,
	input 					per_frame_href,
	input 					per_frame_clken,
	input 		[7:0]		per_img_red,
	input 		[7:0]		per_img_green,
	input 		[7:0]		per_img_blue,
		
	output 					post_frame_vsync,
	output 					post_frame_href,
	output 					post_frame_clken,
	output 		[7:0]		post_img_Y,
	output		[2:0]		frame_cnt,			//帧计数器
	output 		[7:0]		disp_data1,
	output 		[7:0]		disp_data2,
	output 		[7:0]		disp_data3
);


	wire 					post0_frame_vsync;
	wire 					post0_frame_href ;
	wire 					post0_frame_clken;
	wire 					post1_frame_vsync;
	wire 					post1_frame_href ;
	wire 					post1_frame_clken;
			
	wire [7:0]				post0_img_Y ;
	wire [7:0]				post0_img_Cb;
	wire [7:0]				post0_img_Cr;
	wire					post1_img_Bit;
	
	
	//交点
	wire					d1_x1_l;
	wire					d1_x1_r;
	wire					d1_x2_l;
	wire					d1_x2_r;
	wire		[3:0]		d1_y;
	wire		[3:0]		d1_x1;
	wire		[3:0]		d1_x2;
	wire		[10:0]		d1_h_2;
	wire		[10:0]		d1_v_5;
	wire		[10:0]		d1_v_3;
	
	wire					d2_x1_l;
	wire					d2_x1_r;
	wire					d2_x2_l;
	wire					d2_x2_r;
	wire		[3:0]		d2_y;
	wire		[3:0]		d2_x1;
	wire		[3:0]		d2_x2;
	wire		[10:0]		d2_h_2;
	wire		[10:0]		d2_v_5;
	wire		[10:0]		d2_v_3;
	
	wire					d3_x1_l;
	wire					d3_x1_r;
	wire					d3_x2_l;
	wire					d3_x2_r;
	wire		[3:0]		d3_y;
	wire		[3:0]		d3_x1;
	wire		[3:0]		d3_x2;
	wire		[10:0]		d3_h_2;
	wire		[10:0]		d3_v_5;
	wire		[10:0]		d3_v_3;
	
	//边界
	wire		[11:0]		hcount_l1;
	wire		[11:0]		hcount_r1;
	wire		[11:0]		hcount_l2;
	wire		[11:0]		hcount_r2;
	wire		[11:0]		hcount_l3;
	wire		[11:0]		hcount_r3;
	wire		[11:0]		vcount_l1;
	wire		[11:0]		vcount_r1;
	
	wire 					frame_vs_rise;		//帧上升沿
	wire 					frame_vs_fall;		//帧下降沿
	wire 					post_Bit_rise;		//二值化数据上升沿
	wire 					post_Bit_fall;		//二值化数据下降沿
	
	wire 		[10:0]		hcount;				//行计数
	wire 		[10:0]		vcount;				//场计数
	
	
	
	//-----------------------------------------------//
	//-------------------RGB->Ycbcr------------------//
	//-----------------------------------------------//
	
	RGB888_YCbCr444 RGB888_YCbCr444_inst(
		//global clock
		.clk				(clk				),			//cmos video pixel clock
		.rst_n				(rst_n				),			//system reset
	
		//Image data prepred to be processd
		.per_frame_vsync	(per_frame_vsync	),			//Prepared Image data vsync valid signal
		.per_frame_href		(per_frame_href		),			//Prepared Image data href vaild  signal
		.per_frame_clken	(per_frame_clken	),			//Prepared Image data output/capture enable clock
		.per_img_red		(per_img_red		),			//Prepared Image red data input
		.per_img_green		(per_img_green		),			//Prepared Image green data input
		.per_img_blue		(per_img_blue		),			//Prepared Image blue data input
		
		//Image data has been processd
		.post_frame_vsync	(post0_frame_vsync	),			//Processed Image frame data valid signal
		.post_frame_href	(post0_frame_href	),			//Processed Image hsync data valid signal
		.post_frame_clken	(post0_frame_clken	),			//Processed Image data output/capture enable clock
		.post_img_Y			(post0_img_Y		),			//Processed Image brightness output
		.post_img_Cb		(post0_img_Cb		),			//Processed Image blue shading output
		.post_img_Cr		(post0_img_Cr		)			//Processed Image red shading output
);
	
	
	
	
	//-------------------------------------------------//
	//---------------------二值化----------------------//
	//-------------------------------------------------//
	
	Binary Binary_inst(
		//global clock
		.clk				(clk				),			//cmos video pixel clock
		.rst_n				(rst_n				),			//global reset
		
		//Image data prepred to be processd	
		.per_frame_vsync	(post0_frame_vsync	),			//Prepared Image data vsync valid signal
		.per_frame_href		(post0_frame_href 	),			//Prepared Image data href vaild  signal
		.per_frame_clken	(post0_frame_clken	),			//Prepared Image data output/capture enable clock
		.per_img_Y			(post0_img_Y		),			//Prepared Image brightness input
		
		//Image data has been processd	
		.post_frame_vsync	(post1_frame_vsync	),			//Processed Image data vsync valid signal
		.post_frame_href	(post1_frame_href 	),			//Processed Image data href vaild  signal
		.post_frame_clken	(post1_frame_clken	),			//Processed Image data output/capture enable clock
		.post_img_Bit		(post1_img_Bit		)			//Processed Image Bit flag outout(1: Value, 0:inValid)
);
	
	
	
	
	//-------------------------------------------------//
	//-----------------------显示----------------------//
	//-------------------------------------------------//
	
	display display_inst(
		.clk				(clk				),
		.rst_n				(rst_n				),
	
		.per_frame_vsync	(post1_frame_vsync	),
		.per_frame_href		(post1_frame_href 	),
		.per_frame_clken	(post1_frame_clken	),
		.per_img_Bit		(post1_img_Bit		),
	
		.frame_cnt			(frame_cnt			),			//帧计数器
	
	//交点
		.d1_x1_l			(d1_x1_l			),
		.d1_x1_r			(d1_x1_r			),
		.d1_x2_l			(d1_x2_l			),
		.d1_x2_r			(d1_x2_r			),
		.d1_y				(d1_y				),
		.d1_x1				(d1_x1				),
		.d1_x2				(d1_x2				),
		.d1_h_2				(d1_h_2				),
		.d1_v_5				(d1_v_5				),
		.d1_v_3				(d1_v_3				),
		
		.d2_x1_l			(d2_x1_l			),
		.d2_x1_r			(d2_x1_r			),
		.d2_x2_l			(d2_x2_l			),
		.d2_x2_r			(d2_x2_r			),
		.d2_y				(d2_y				),
		.d2_x1				(d2_x1				),
		.d2_x2				(d2_x2				),
		.d2_h_2				(d2_h_2				),
		.d2_v_5				(d2_v_5				),
		.d2_v_3				(d2_v_3				),
		
		.d3_x1_l			(d3_x1_l			),
		.d3_x1_r			(d3_x1_r			),
		.d3_x2_l			(d3_x2_l			),
		.d3_x2_r			(d3_x2_r			),
		.d3_y				(d3_y				),
		.d3_x1				(d3_x1				),
		.d3_x2				(d3_x2				),
		.d3_h_2				(d3_h_2				),
		.d3_v_5				(d3_v_5				),
		.d3_v_3				(d3_v_3				),
	//边界
		.hcount_l1			(hcount_l1			),			//左边界
		.hcount_r1			(hcount_r1			),			//右边界
		.hcount_l2			(hcount_l2			),			//左边界
		.hcount_r2			(hcount_r2			),			//右边界
		.hcount_l3			(hcount_l3			),			//左边界
		.hcount_r3			(hcount_r3			),			//右边界
		.vcount_l			(vcount_l1			),			//上边界
		.vcount_r			(vcount_r1			),			//下边界
	
		.frame_vs_rise		(frame_vs_rise		),			//帧上升沿
		.frame_vs_fall		(frame_vs_fall		),			//帧下降沿
		.post_Bit_rise		(post_Bit_rise		),			//二值化数据上升沿
		.post_Bit_fall		(post_Bit_fall		),			//二值化数据下降沿
		.hcount				(hcount				),			//行计数
		.vcount				(vcount				),			//场计数
	
		.post_frame_vsync	(post_frame_vsync	),
		.post_frame_href	(post_frame_href	),
		.post_frame_clken	(post_frame_clken	),
		.post_img_Y			(post_img_Y			),
		.disp_data1			(disp_data1			),			//输出识别的数字
		.disp_data2			(disp_data2			),			//输出识别的数字
		.disp_data3			(disp_data3			)			//输出识别的数字
);
	
	
	
	
	//------------------------------------------------//
	//------------------数字投影提取------------------//
	//------------------------------------------------//
	vertical_projection vertical_projection_inst(
		.clk				(clk				),
		.rst_n				(rst_n				),
		.frame_vs_fall		(frame_vs_fall		),
		.post_Bit			(post1_img_Bit		),
		.hcount				(hcount				),
		.vcount				(vcount				),

		.frame_cnt			(frame_cnt			),
	
		.hcount_l1			(hcount_l1			),
		.hcount_r1			(hcount_r1			),
		.hcount_l2			(hcount_l2			),
		.hcount_r2			(hcount_r2			),
		.hcount_l3			(hcount_l3			),
		.hcount_r3			(hcount_r3			),
		.vcount_l1			(vcount_l1			),
		.vcount_r1			(vcount_r1			)
);
	
	
	//------------------------------------------------//
	//------------------数字特征提取------------------//
	//------------------------------------------------//
	//digital 1
	digital_recognition digital_recognition_inst1(
		.clk				(clk				),
		.frame_vs			(post1_frame_vsync	),
		.rst_n				(rst_n				),
		.post_Bit			(post1_img_Bit		),			//threshold value
		.hcount				(hcount				),
		.vcount				(vcount				),
		.hcount_l			(hcount_l1			),			//数字1的左右边界
		.hcount_r			(hcount_r1			),
		.vcount_l			(vcount_l1			),			//数字1的上下边界
		.vcount_r			(vcount_r1			),
		.post_Bit_rise		(post_Bit_rise		),
		.post_Bit_fall		(post_Bit_fall		),
		.frame_vs_rise		(frame_vs_rise		),
		.frame_vs_fall		(frame_vs_fall		),
		.frame_cnt			(frame_cnt			),
		.x1_l				(d1_x1_l			),
		.x1_r				(d1_x1_r			),
		.x2_l				(d1_x2_l			),
		.x2_r				(d1_x2_r			),
		.y					(d1_y				),
		.x1					(d1_x1				),
		.x2					(d1_x2				),
		.h_2				(d1_h_2				),
		.v_5				(d1_v_5				),
		.v_3				(d1_v_3				)
);

	//digital 2
	digital_recognition digital_recognition_inst2(
		.clk				(clk				),
		.frame_vs			(post1_frame_vsync	),
		.rst_n				(rst_n				),
		.post_Bit			(post1_img_Bit		),			//threshold value
		.hcount				(hcount				),
		.vcount				(vcount				),
		.hcount_l			(hcount_l2			),			//数字2的左右边界
		.hcount_r			(hcount_r2			),
		.vcount_l			(vcount_l1			),			//数字2的上下边界
		.vcount_r			(vcount_r1			),
		.post_Bit_rise		(post_Bit_rise		),
		.post_Bit_fall		(post_Bit_fall		),
		.frame_vs_rise		(frame_vs_rise		),
		.frame_vs_fall		(frame_vs_fall		),
		.frame_cnt			(frame_cnt			),
		.x1_l				(d2_x1_l			),
		.x1_r				(d2_x1_r			),
		.x2_l				(d2_x2_l			),
		.x2_r				(d2_x2_r			),
		.y					(d2_y				),
		.x1					(d2_x1				),
		.x2					(d2_x2				),
		.h_2				(d2_h_2				),
		.v_5				(d2_v_5				),
		.v_3				(d2_v_3				)
);
	
	
	//digital 3
	digital_recognition digital_recognition_inst3(
		.clk				(clk				),
		.frame_vs			(post1_frame_vsync	),
		.rst_n				(rst_n				),
		.post_Bit			(post1_img_Bit		),			//threshold value
		.hcount				(hcount				),
		.vcount				(vcount				),
		.hcount_l			(hcount_l3			),			//数字2的左右边界
		.hcount_r			(hcount_r3			),
		.vcount_l			(vcount_l1			),			//数字2的上下边界
		.vcount_r			(vcount_r1			),
		.post_Bit_rise		(post_Bit_rise		),
		.post_Bit_fall		(post_Bit_fall		),
		.frame_vs_rise		(frame_vs_rise		),
		.frame_vs_fall		(frame_vs_fall		),
		.frame_cnt			(frame_cnt			),
		.x1_l				(d3_x1_l			),
		.x1_r				(d3_x1_r			),
		.x2_l				(d3_x2_l			),
		.x2_r				(d3_x2_r			),
		.y					(d3_y				),
		.x1					(d3_x1				),
		.x2					(d3_x2				),
		.h_2				(d3_h_2				),
		.v_5				(d3_v_5				),
		.v_3				(d3_v_3				)
);
	
	
endmodule
	
	