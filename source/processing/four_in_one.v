//---------------------------------------------------------------------------------------

// image_mode = 5

//---------------------------------------------------------------------------------------

module four_in_one(

		//
		clock, reset_n,
		//
		vs_i, hs_i, de_i,
		//
		rgb_r_i, rgb_g_i, rgb_b_i,
		//
		vs_o, hs_o, de_o,
		//
		rgb_r_o, rgb_g_o, rgb_b_o,
		//
		image_mode_i
		
);

//---------------------------------------------------------------------------------------

input								clock;
input								reset_n;

input								vs_i;
input								hs_i;
input								de_i;
input[7:0]							rgb_r_i;
input[7:0]							rgb_g_i;
input[7:0]							rgb_b_i;

input[7:0]							image_mode_i;

output								vs_o;
output								hs_o;
output								de_o;
output[7:0]							rgb_r_o;
output[7:0]							rgb_g_o;
output[7:0]							rgb_b_o;

//---------------------------------------------------------------------------------------

reg[7:0]							r_rgb_r_o;
reg[7:0]							r_rgb_g_o;
reg[7:0]							r_rgb_b_o;
reg[7:0]							r_image_mode;

reg[18:0]							temp_sum_r;
reg[18:0]							temp_sum_g;
reg[18:0]							temp_sum_b;

reg[10:0]							r_pixel_cnt;
reg[10:0]							r_line_cnt;

reg									r_de_d0;
reg									r_de_d1;
reg									r_de_d2;
reg									r_de_d3;
reg									r_de_d4;
reg									r_hs_d0;
reg									r_hs_d1;
reg									r_hs_d2;
reg									r_hs_d3;
reg									r_hs_d4;
reg									r_vs_d0;
reg									r_vs_d1;
reg									r_vs_d2;
reg									r_vs_d3;
reg									r_vs_d4;

//---------------------------------------------------------------------------------------

reg[7:0]							r_rgb_r_d0;
reg[7:0]							r_rgb_g_d0;
reg[7:0]							r_rgb_b_d0;
reg[7:0]							r_rgb_r_d1;
reg[7:0]							r_rgb_g_d1;
reg[7:0]							r_rgb_b_d1;
reg[7:0]							r_rgb_r_d2;
reg[7:0]							r_rgb_g_d2;
reg[7:0]							r_rgb_b_d2;
reg[7:0]							r_rgb_r_d3;
reg[7:0]							r_rgb_g_d3;
reg[7:0]							r_rgb_b_d3;

reg[8:0]							temp_R0;
reg[8:0]							temp_G0;
reg[8:0]							temp_B0;
reg[8:0]							temp_R1;
reg[8:0]							temp_G1;
reg[8:0]							temp_B1;

reg[9:0]							temp_sum_RGB;

reg[18:0]							temp_sum_Y;

//---------------------------------------------------------------------------------------

wire[17:0]							temp_306R;
wire[17:0]							temp_601G;
wire[17:0]							temp_117B;

wire[17:0]							temp_sum_512;

//---------------------------------------------------------------------------------------

assign vs_o = (r_image_mode == 8'b0000_0101) ? r_vs_d4 : vs_i;
assign hs_o = (r_image_mode == 8'b0000_0101) ? r_hs_d4 : hs_i;
assign de_o = (r_image_mode == 8'b0000_0101) ? r_de_d4 : de_i;

assign rgb_r_o = (r_image_mode == 8'b0000_0101) ? r_rgb_r_o : rgb_r_i;
assign rgb_g_o = (r_image_mode == 8'b0000_0101) ? r_rgb_g_o : rgb_g_i;
assign rgb_b_o = (r_image_mode == 8'b0000_0101) ? r_rgb_b_o : rgb_b_i;

//---------------------------------------------------------------------------------------

always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_de_d0 <= 1'b0;
				r_de_d1 <= 1'b0;
				r_de_d2 <= 1'b0;					//sync to temp_xxxx
				r_de_d3 <= 1'b0;                    //sync to temp_sum_Y
				r_de_d4 <= 1'b0;					//sync to output	
			end
		else
			begin
				r_de_d0 <= de_i;
				r_de_d1 <= r_de_d0;
				r_de_d2 <= r_de_d1;
				r_de_d3 <= r_de_d2;
				r_de_d4 <= r_de_d3;
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_hs_d0 <= 1'b0;
				r_hs_d1 <= 1'b0;
				r_hs_d2 <= 1'b0;					
				r_hs_d3 <= 1'b0;                   
				r_hs_d4 <= 1'b0;					
			end
		else
			begin
				r_hs_d0 <= hs_i;
				r_hs_d1 <= r_hs_d0;
				r_hs_d2 <= r_hs_d1;
				r_hs_d3 <= r_hs_d2;
				r_hs_d4 <= r_hs_d3;
			end
	end	
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_vs_d0 <= 1'b0;
				r_vs_d1 <= 1'b0;
				r_vs_d2 <= 1'b0;					
				r_vs_d3 <= 1'b0;                   
				r_vs_d4 <= 1'b0;					
			end
		else
			begin
				r_vs_d0 <= vs_i;
				r_vs_d1 <= r_vs_d0;
				r_vs_d2 <= r_vs_d1;
				r_vs_d3 <= r_vs_d2;
				r_vs_d4 <= r_vs_d3;
			end
	end	

always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_image_mode <= 0;	
			end
		else if(!r_vs_d0 && vs_i)
			begin
				r_image_mode <= image_mode_i;
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				{r_rgb_r_d0, r_rgb_g_d0, r_rgb_b_d0} <= 0;
				{r_rgb_r_d1, r_rgb_g_d1, r_rgb_b_d1} <= 0;
				{r_rgb_r_d2, r_rgb_g_d2, r_rgb_b_d2} <= 0;	
				{r_rgb_r_d3, r_rgb_g_d3, r_rgb_b_d3} <= 0;
			end
		else
			begin
				{r_rgb_r_d0, r_rgb_g_d0, r_rgb_b_d0} <= {rgb_r_i, rgb_g_i, rgb_b_i};
				{r_rgb_r_d1, r_rgb_g_d1, r_rgb_b_d1} <= {r_rgb_r_d0, r_rgb_g_d0, r_rgb_b_d0};
				{r_rgb_r_d2, r_rgb_g_d2, r_rgb_b_d2} <= {r_rgb_r_d1, r_rgb_g_d1, r_rgb_b_d1};
				{r_rgb_r_d3, r_rgb_g_d3, r_rgb_b_d3} <= {r_rgb_r_d2, r_rgb_g_d2, r_rgb_b_d2};
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin

			end
		else if(r_pixel_cnt < 960 && r_line_cnt <= 540)
			begin
				r_rgb_r_o <= 255 - r_rgb_r_d3;
				r_rgb_g_o <= 255 - r_rgb_g_d3;
				r_rgb_b_o <= 255 - r_rgb_b_d3;
			end
		else if(r_pixel_cnt >= 960 && r_line_cnt <= 540)
			begin
				temp_R0 <= r_rgb_r_d2 + 128;
				temp_G0 <= r_rgb_g_d2 + 128;
				temp_B0 <= r_rgb_b_d2 + 128;
				temp_R1 <= (temp_R0 > r_rgb_r_d1) ? temp_R0 - r_rgb_r_d1 : 0;
				temp_G1 <= (temp_G0 > r_rgb_g_d1) ? temp_G0 - r_rgb_g_d1 : 0;
				temp_B1 <= (temp_B0 > r_rgb_b_d1) ? temp_B0 - r_rgb_b_d1 : 0;
				r_rgb_r_o <= (temp_R1[8] == 0) ? temp_R1[7:0] : 255;
				r_rgb_g_o <= (temp_G1[8] == 0) ? temp_G1[7:0] : 255;
				r_rgb_b_o <= (temp_B1[8] == 0) ? temp_B1[7:0] : 255;
			end
		else if(r_pixel_cnt < 960 && r_line_cnt > 540)
			begin
				temp_sum_Y <= temp_306R + temp_601G + temp_117B;
				r_rgb_r_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
				r_rgb_g_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
				r_rgb_b_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
			end
		else if(r_pixel_cnt >= 960 && r_line_cnt > 540)
			begin
				temp_sum_RGB <= rgb_r_i + rgb_g_i + rgb_b_i;
				r_rgb_r_o <= ((( temp_sum_512[17] == 1'b0 ) ? temp_sum_512[16:9] : 255) < 100) ? 0 : 255;
				r_rgb_g_o <= ((( temp_sum_512[17] == 1'b0 ) ? temp_sum_512[16:9] : 255) < 100) ? 0 : 255;
				r_rgb_b_o <= ((( temp_sum_512[17] == 1'b0 ) ? temp_sum_512[16:9] : 255) < 100) ? 0 : 255;
			end
		else
			begin
				
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_pixel_cnt <= 0;	
			end
		else if(de_i)
			begin
				r_pixel_cnt <= r_pixel_cnt + 1'b1;
			end
		else if(r_de_d0 && !de_i)
			r_pixel_cnt <= 0;
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_line_cnt <= 0;	
			end
		else if(r_de_d0 && !de_i)
			begin
				r_line_cnt <= r_line_cnt + 1'b1;
			end
		else if(!r_vs_d0 && vs_i)
				r_line_cnt <= 0;
			
	end
	
//---------------------------------------------------------------------------------------

mult10x8 mult10x8_u0(
	
			.clken(1'b1),
			.clock(clock),
			.dataa(rgb_r_i),
			.datab(306),
			.result(temp_306R)
	
);

mult10x8 mult10x8_u1(
	
			.clken(1'b1),
			.clock(clock),
			.dataa(rgb_g_i),
			.datab(601),
			.result(temp_601G)
	
);

mult10x8 mult10x8_u2(
	
			.clken(1'b1),
			.clock(clock),
			.dataa(rgb_b_i),
			.datab(117),
			.result(temp_117B)
	
);

mult10x8 mult10x8_u3(
	
			.clken(1'b1),
			.clock(clock),
			.dataa(170),
			.datab(temp_sum_RGB),
			.result(temp_sum_512)
	
);

endmodule