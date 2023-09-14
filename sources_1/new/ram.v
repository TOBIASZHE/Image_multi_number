`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/22 13:27:07
// Design Name: 
// Module Name: ram
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


module ram(
	input				clk,
	input				rst_n,
	
	input				we,
	input	[10:0]		waddr,
	input	[10:0]		raddr,
	input	[0:0]		di,
	output	[0:0]		dout
);

	reg [0:0] mem [0:319];
	reg [0:0] rdata;
	assign dout = rdata;

	always@(posedge clk or negedge rst_n)begin
		if(1'b0 == rst_n)begin
			rdata <= 0;
		end
		else begin
			rdata <= mem[raddr];
			if(we) 
				mem[waddr] <= di;
		end
	end
		
endmodule
