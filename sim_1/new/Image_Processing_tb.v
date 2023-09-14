`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 10:37:50
// Design Name: 
// Module Name: Image_Processing_tb
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


module Image_Processing_tb;
 
	integer iBmpFileId;                 //����BMPͼƬ
	integer oBmpFileId;                 //���BMPͼƬ
	integer oTxtFileId;                 //����TXT�ı�
			
	integer iIndex = 0;                 //���BMP��������
	integer pixel_index = 0;            //��������������� 
			
	integer iCode;      
			
	integer iBmpWidth;                  //����BMP ���
	integer iBmpHight;                  //����BMP �߶�
	integer iBmpSize;                   //����BMP �ֽ���
	integer iDataStartIndex;            //����BMP ��������ƫ����
		
	reg [ 7:0] rBmpData [0:2000000];    //���ڼĴ�����BMPͼƬ�е��ֽ����ݣ�����54�ֽڵ��ļ�ͷ��
	reg [ 7:0] Vip_BmpData [0:2000000]; //���ڼĴ���Ƶͼ����֮�� ��BMPͼƬ ���� 
	reg [7:0] rBmpWord;                //���BMPͼƬʱ���ڼĴ����ݣ���wordΪ��λ����4byte��
	
	reg [ 7:0] pixel_data;              //�����Ƶ��ʱ����������
	
	reg clk;
	reg rst_n;
	
	reg [ 7:0] vip_pixel_data [0:230400];   //320x240x3

	
	//����50MHzʱ��
	initial clk = 0;
	always #10 clk = ~clk;

	
	//��λ�ź�
	initial begin
		rst_n   = 0;
		#100;
		rst_n   = 1;
	end 
	
	
	
	//--------------------------------------------------//
	//------------��ȡ�ⲿ��ͼƬ�ļ���λ��--------------//
	//--------------------------------------------------//
	initial begin
		//�ֱ�� ����/���BMPͼƬ���Լ������Txt�ı�
		//    1     ����ͼƬ���֣���Ҫ����
		iBmpFileId = $fopen("C:\\Users\\lys\\Desktop\\course\\Image_processing\\Image_multi_number\\picture\\789.bmp","rb");
		oBmpFileId = $fopen("C:\\Users\\lys\\Desktop\\course\\Image_processing\\Image_multi_number\\picture\\pic.bmp","wb+");
		oTxtFileId = $fopen("C:\\Users\\lys\\Desktop\\course\\Image_processing\\Image_multi_number\\picture\\pic.txt","w+");
	
		//������BMPͼƬ���ص�������
		iCode = $fread(rBmpData,iBmpFileId);
	
		//����BMPͼƬ�ļ�ͷ�ĸ�ʽ���ֱ�����ͼƬ�� ��� /�߶� /��������ƫ���� /ͼƬ�ֽ���
		iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
		iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
		iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
		iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
		
		//�ر�����BMPͼƬ
		$fclose(iBmpFileId);
		
		//�������е�����д�����Txt�ı���
		$fwrite(oTxtFileId,"%p",rBmpData);
		//�ر�Txt�ı�
		$fclose(oTxtFileId);
			
		
		//�ӳ�2ms���ȴ���һ֡VIP�������
		#8000000
		//����ͼ�����BMPͼƬ���ļ�ͷ����������
		for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
			if(iIndex < 54)
					Vip_BmpData[iIndex] = rBmpData[iIndex];
			else
					Vip_BmpData[iIndex] = vip_pixel_data[iIndex-54];
		end
		
		//�������е�����д�����BMPͼƬ��    
		for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
			rBmpWord = Vip_BmpData[iIndex];
			$fwrite(oBmpFileId,"%c",rBmpWord);
		end
		//�ر����BMPͼƬ
		$fclose(oBmpFileId); 
	end
	
	
	
	
	//--------------------------------------------------//
	//-------------------ͼ�����ⲿIP-----------------//
	//--------------------------------------------------//
	
	//ģ�������ͷ������ݺ�ʱ��
	wire		cmos_vsync;
	reg			cmos_href;
	wire        cmos_clken;
	reg	[23:0]	cmos_data;
	
	//  2  ͼ�����֣���Ҫ����
	wire 		per_frame_vsync	=	cmos_vsync;
	wire 		per_frame_href	=	cmos_href;
	wire 		per_frame_clken	=	cmos_clken;
	wire [7:0]	per_img_red		=	cmos_data[23:16];
	wire [7:0]	per_img_green	=	cmos_data[15: 8];
	wire [7:0]	per_img_blue	=	cmos_data[ 7: 0];
	
	wire		post_frame_vsync;
	wire		post_frame_href;
	wire		post_frame_clken;
	wire [7:0]	post_img_Y;
	wire [2:0]	frame_cnt;
	wire [7:0]	disp_data1;
	wire [7:0]	disp_data2;
	wire [7:0]	disp_data3;
	
	Image_Processing Image_Processing_inst(
		.clk				(clk),
		.rst_n				(rst_n),
	
		.per_frame_vsync	(per_frame_vsync),
		.per_frame_href		(per_frame_href),
		.per_frame_clken	(per_frame_clken),
		.per_img_red		(per_img_red),
		.per_img_green		(per_img_green),
		.per_img_blue		(per_img_blue),
		
		.post_frame_vsync 	(post_frame_vsync),
		.post_frame_href	(post_frame_href),
		.post_frame_clken 	(post_frame_clken),
		.post_img_Y			(post_img_Y),
		.frame_cnt			(frame_cnt),
		.disp_data1			(disp_data1),
		.disp_data2			(disp_data2),
		.disp_data3			(disp_data3)
);



	//--------------------------------------------------//
	//--------------------ͼ���������------------------//
	//--------------------------------------------------//
	
	wire 			vip_out_frame_vsync;   
	wire 			vip_out_frame_href ;   
	wire 			vip_out_frame_clken;    
	wire [7:0]		vip_out_img_R;   
	wire [7:0]		vip_out_img_G;   
	wire [7:0]		vip_out_img_B;  
	
	//  3  ���ͼ�����ݣ���Ҫ���ĵĵط�
	assign vip_out_frame_vsync = post_frame_vsync;   
	assign vip_out_frame_href  = post_frame_href ;   
	assign vip_out_frame_clken = post_frame_clken;    
	assign vip_out_img_R       = post_img_Y;   
	assign vip_out_img_G       = post_img_Y;   
	assign vip_out_img_B       = post_img_Y;  



	//--------------------------------------------------//
	//----------------��������ͷ�����ʱ��--------------//
	//--------------------------------------------------//
	reg [31:0]  cmos_index;
	
	parameter [10:0] IMG_HDISP = 11'd320;
	parameter [10:0] IMG_VDISP = 11'd240;
	
	localparam H_SYNC = 11'd5;		
	localparam H_BACK = 11'd5;		
	localparam H_DISP = IMG_HDISP;	
	localparam H_FRONT = 11'd5;		
	localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	
	
	localparam V_SYNC = 11'd1;		
	localparam V_BACK = 11'd0;		
	localparam V_DISP = IMG_VDISP;	
	localparam V_FRONT = 11'd1;		
	localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;
	
	//ˮƽ������
	reg	[10:0]	hcnt;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			hcnt <= 11'd0;
		else
			hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 11'd0;
	end
	
	//��ֱ������
	reg	[10:0]	vcnt;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			vcnt <= 11'd0;		
		else begin
			if(hcnt == H_TOTAL - 1'b1)
				vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 11'd0;
			else
				vcnt <= vcnt;
		end
	end
	
	//��ͬ��
	reg	cmos_vsync_r;
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cmos_vsync_r <= 1'b0;			//H: Vaild, L: inVaild
		else begin
			if(vcnt <= V_SYNC - 1'b1)
				cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
			else
				cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
		end
	end
	
	assign	cmos_vsync	= cmos_vsync_r;
	
	//Image data href vaild  signal
	wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
										&& hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
							? 1'b1 : 1'b0;
			
	reg			cmos_href_r;      
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cmos_href_r <= 0;
		else begin
			if(frame_valid_ahead)
				cmos_href_r <= 1;
			else
				cmos_href_r <= 0;
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n)
			cmos_href <= 0;
		else
			cmos_href <= cmos_href_r;
	end
	
	assign cmos_clken = cmos_href;
	
	//������������Ƶ��ʽ�����������
	wire [10:0] x_pos;
	wire [10:0] y_pos;
	
	assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
	assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;
	
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			cmos_index   <=  0;
			cmos_data    <=  24'd0;
		end
		else begin
			cmos_index   <=  y_pos * 960  + x_pos*3 + 54;        //  3*(y*320 + x) + 54
			cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
		end
	end

	//��ʱ�������£��������ж�����������
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			pixel_data  <=  8'd0;
			pixel_index <=  0;
		end
		else begin
			pixel_data  <=  rBmpData[pixel_index];
			pixel_index <=  pixel_index+1;
		end
	end
	
	

	//-------------------------------------------//
	//----------ͼ����֮�����������-----------//
	//-------------------------------------------//
	
	reg [31:0] vip_cnt;
	
	reg         vip_vsync_r;    //�Ĵ�VIP����ĳ�ͬ�� 
	reg         vip_out_en;     //�Ĵ�VIP����ͼ���ʹ���źţ���ά��һ֡��ʱ��

	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			vip_vsync_r   <=  1'b0;
		else 
			vip_vsync_r   <=  per_frame_vsync;
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			vip_out_en    <=  1'b1;
		//else if(vip_vsync_r & (!per_frame_vsync))  //��һ֡����֮��ʹ������
		else if((frame_cnt > 'd3))
			vip_out_en    <=  1'b0;
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			vip_cnt <=  32'd0;
		end
		else if(vip_out_en && (frame_cnt > 'd2)) begin
			if(vip_out_frame_href & vip_out_frame_clken) begin
					vip_cnt <=  vip_cnt + 3;
					vip_pixel_data[vip_cnt+0] <= vip_out_img_R;
					vip_pixel_data[vip_cnt+1] <= vip_out_img_G;
					vip_pixel_data[vip_cnt+2] <= vip_out_img_B;
			end
		end
	end
	
	
endmodule 

