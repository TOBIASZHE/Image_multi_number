`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/22 13:08:28
// Design Name: 
// Module Name: vertical_projection
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


module vertical_projection(
	input					clk,
	input					rst_n,
	input					frame_vs_fall,
	input					post_Bit,
	input		[10:0]		hcount,
	input		[10:0]		vcount,

	output	reg	[2:0]		frame_cnt,
	
	output		[10:0]		hcount_l1,
	output		[10:0]		hcount_r1,
	output		[10:0]		hcount_l2,
	output		[10:0]		hcount_r2,
	output		[10:0]		hcount_l3,
	output		[10:0]		hcount_r3,
	output		[10:0]		vcount_l1,
	output		[10:0]		vcount_r1
);

	parameter IDLE   = 3'b001;
	parameter FRAME1 = 3'b010;
	parameter FRAME2 = 3'b100;
	
	parameter H_PIXEL = 319;

	reg [2:0] c_state;
	reg [2:0] n_state;
	
	reg [10:0] i;


	reg [10:0]	hcount_l1_r;
	reg [10:0]	hcount_r1_r;
	reg [10:0]	hcount_l2_r;
	reg [10:0]	hcount_r2_r;
	reg [10:0]	hcount_l3_r;
	reg [10:0]	hcount_r3_r;
	reg [10:0]	vcount_l1_r;
	reg [10:0]	vcount_r1_r;

	
	assign hcount_l1 = hcount_l1_r;
	assign hcount_r1 = hcount_r1_r;
	assign hcount_l2 = hcount_l2_r;
	assign hcount_r2 = hcount_r2_r;
	assign hcount_l3 = hcount_l3_r;
	assign hcount_r3 = hcount_r3_r;
	assign vcount_l1 = vcount_l1_r;
	assign vcount_r1 = vcount_r1_r;

	reg 		h_we;
	reg [10:0]	h_waddr;
	reg [10:0]	h_raddr;
	reg 		h_di;
	
	reg 		v_we;
	reg [10:0]	v_waddr;
	reg [10:0]	v_raddr;
	reg 		v_di;
	
	
	//-----------------------------------------------------------------------------//
	//----------寻找水平投影和垂直投影坐标为0的时候的上升沿和下降沿----------------//
	//-----------------------------------------------------------------------------//
	wire		h_dout;
	reg 		h_dout_r;
	wire		v_dout;
	reg 		v_dout_r;
	
	reg			h_pedge_r;
	reg			h_nedge_r;
	reg			v_pedge_r;
	reg			v_nedge_r;
				
	reg			h_pedge_r0;
	reg			h_nedge_r0;
	reg			v_pedge_r0;
	reg			v_nedge_r0;
	
	always@(posedge clk)begin
		h_dout_r <= h_dout;		//ram输出横坐标
		v_dout_r <= v_dout;		//ram输出纵坐标
	end
	
	wire h_pedge = (h_dout & (!h_dout_r));		//寻找垂直投影为0的点的上升沿
	wire h_nedge = ((!h_dout) & h_dout_r);		//寻找垂直投影为0的点的下降沿
	wire v_pedge = (v_dout & (!v_dout_r));		//寻找水平投影为0的点的上升沿
	wire v_nedge = ((!v_dout) & v_dout_r);		//寻找水平投影为0的点的下降沿
	
	always@(posedge clk)begin
		h_pedge_r <= h_pedge;
		h_nedge_r <= h_nedge;
		v_pedge_r <= v_pedge;
		v_nedge_r <= v_nedge;
		
		h_pedge_r0 <= h_pedge_r;
		h_nedge_r0 <= h_nedge_r;
		v_pedge_r0 <= v_pedge_r;
		v_nedge_r0 <= v_nedge_r;
	end
	
	

	
	
	reg  [3:0] h_pedge_cnt;
	reg  [3:0] h_nedge_cnt;
	reg  [3:0] v_pedge_cnt;
	reg  [3:0] v_nedge_cnt;

	

	//-------------------------------------------------------------
	//frame counter 0 1 0 1
	//-------------------------------------------------------------
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			frame_cnt <='d0;
		else if(frame_cnt == 'd4)
			frame_cnt <='d0;
		else if(frame_vs_fall== 1'b1) //falling edge
			frame_cnt <= frame_cnt + 'd1;
		else
			frame_cnt <= frame_cnt;
	end 


	//FSM1
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			c_state <= IDLE;
		else
			c_state <= n_state;
	end


	//FSM2
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			n_state <= IDLE;
		else case(c_state)
			IDLE:begin
				if(i > H_PIXEL)      // initial ram
					n_state <= FRAME1;
					else 
					n_state <= IDLE;
				end
			FRAME1:begin
				if(frame_cnt == 'd1 || frame_cnt == 'd3)
					n_state <= FRAME2;
					else
					n_state <= FRAME1;
				end
			FRAME2:begin
				if(frame_cnt == 'd0 || frame_cnt == 'd2)
					n_state <= FRAME1;
					else
					n_state <= FRAME2;
				end
		endcase      
	end

	//FMS3
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) begin 
			h_we <= 1'b0;
			h_waddr <= 11'b0;
			h_raddr <= 11'b0;
			h_di <= 0;
			v_we <= 1'b0;
			v_waddr <= 11'b0;
			v_raddr <= 11'b0;
			v_di <= 0;
			i <= 11'd0;
			hcount_l1_r<= 11'b0;
			hcount_r1_r<= 11'b0;
			hcount_l2_r<= 11'b0;
			hcount_r2_r<= 11'b0;
			hcount_l3_r<= 11'b0;
			hcount_r3_r<= 11'b0;
			vcount_l1_r<= 11'b0;
			vcount_r1_r<= 11'b0;
			h_pedge_cnt<=4'b0;
			h_nedge_cnt<=4'b0;
			v_pedge_cnt<=4'b0;
			v_nedge_cnt<=4'b0;
		end
		else begin
			case(c_state)
				IDLE: begin
					if(i > H_PIXEL) begin
						i<=i;
						h_we <= 0;
						h_waddr <= 0;
						h_di <= 0;
						v_we <= 0;
						v_waddr <= 0;
						v_di <= 0;
					end
					else begin
						i <= i +1;
						h_we <= 1;
						h_waddr <= h_waddr +1;
						h_di <= 0;
						v_we <= 1;
						v_waddr <= v_waddr +1;
						v_di <= 0;
					end
				end
				
				//当二值化完成之后，当扫描到的点为黑点时，遍历整幅图像，统计垂直投影和水平投影
				//不是每一条垂直线上的值进行累加，只是垂直线上有黑点，横坐标就用1表示
				FRAME1:begin
					h_raddr <= 0;
					v_raddr <= 0;
					h_pedge_cnt <= 4'b0;
					h_nedge_cnt <= 4'b0;
					v_pedge_cnt <= 4'b0;
					v_nedge_cnt <= 4'b0;
					if((hcount > 5)&& (hcount < 315)&& (!post_Bit)) begin
						h_we <= 1;
						h_waddr <= hcount;
						h_di <= 1;
						v_we <= 1;
						v_waddr <= vcount;
						v_di <= 1;
					end
					else begin
						h_we <= 0;
						h_waddr <= 0;
						h_di <= 0;
						v_we <= 0;
						v_waddr <= 0;
						v_di <= 0;
					end
				end
				
				FRAME2:begin
					if(h_raddr < H_PIXEL) begin 
						i <= 0;
						h_raddr <= h_raddr + 1;
						v_raddr <= v_raddr + 1;
						if(h_pedge) h_pedge_cnt <= h_pedge_cnt +1;
						if(h_pedge_r0 && h_pedge_cnt == 1) hcount_l1_r <= h_raddr-5;
						if(h_pedge_r0 && h_pedge_cnt == 2) hcount_l2_r <= h_raddr-5;
						if(h_pedge_r0 && h_pedge_cnt == 3) hcount_l3_r <= h_raddr-5;
						if(h_nedge) h_nedge_cnt <= h_nedge_cnt +1;
						if(h_nedge_r0 && h_nedge_cnt == 1) hcount_r1_r <= h_raddr;
						if(h_nedge_r0 && h_nedge_cnt == 2) hcount_r2_r <= h_raddr;
						if(h_nedge_r0 && h_nedge_cnt == 3) hcount_r3_r <= h_raddr;
						if(v_pedge) v_pedge_cnt <= v_pedge_cnt +1;
						if(v_pedge_r0 && v_pedge_cnt == 1) vcount_l1_r <= v_raddr-5;
						if(v_nedge) v_nedge_cnt <= v_nedge_cnt +1;
						if(v_nedge_r0 && v_nedge_cnt == 1) vcount_r1_r <= v_raddr;
					end
					else begin
						h_pedge_cnt <= h_pedge_cnt;
						h_nedge_cnt <= h_nedge_cnt;
						v_pedge_cnt <= v_pedge_cnt;
						v_nedge_cnt <= v_nedge_cnt;
						h_raddr <= h_raddr;
						v_raddr <= v_raddr;
						if(i < H_PIXEL) begin
							i <= i + 1;
							h_we <= 1;
							h_waddr <= h_waddr +1;
							h_di <= 0;
							v_we <= 1;
							v_waddr <= v_waddr +1;
							v_di <= 0;
						end	
						else begin
							i<=i;
							h_we <= 0;
							h_waddr <= 0;
							h_di <= 0;
							v_we <= 0;
							v_waddr <= 0;
							v_di <= 0;
						end
					end
				end
			endcase
		end
	end

	ram h_ram_inst(
		.clk		(clk),
		.rst_n		(rst_n),
		.we			(h_we),
		.waddr		(h_waddr),
		.raddr		(h_raddr),
		.di			(h_di),
		.dout		(h_dout)
);
		
	ram v_ram_inst(
		.clk		(clk),
		.rst_n		(rst_n),
		.we			(v_we),
		.waddr		(v_waddr),
		.raddr		(v_raddr),
		.di			(v_di),
		.dout		(v_dout)
);

endmodule 



