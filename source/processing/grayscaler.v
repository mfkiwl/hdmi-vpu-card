//---------------------------------------------------------------------------------------

// Y = 0.299R + 0.587G + 0.114B
// Cb = -0.172R - 0.339G + 0.511B + 128
// Cr = 0.511R - 0.428G - 0.083B + 128
// image_mode = 3

//---------------------------------------------------------------------------------------

module grayscaler(

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

reg[18:0]							temp_sum_Y;

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

wire[17:0]							temp_306R;
wire[17:0]							temp_601G;
wire[17:0]							temp_117B;

//---------------------------------------------------------------------------------------

assign vs_o = (r_image_mode == 8'b0000_0011) ? r_vs_d4 : vs_i;
assign hs_o = (r_image_mode == 8'b0000_0011) ? r_hs_d4 : hs_i;
assign de_o = (r_image_mode == 8'b0000_0011) ? r_de_d4 : de_i;

assign rgb_r_o = (r_image_mode == 8'b0000_0011) ? r_rgb_r_o : rgb_r_i;
assign rgb_g_o = (r_image_mode == 8'b0000_0011) ? r_rgb_g_o : rgb_g_i;
assign rgb_b_o = (r_image_mode == 8'b0000_0011) ? r_rgb_b_o : rgb_b_i;

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
				temp_sum_Y <= 0;			
			end
		else
			begin
				temp_sum_Y <= temp_306R + temp_601G + temp_117B;
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_rgb_r_o <= 0;	
				r_rgb_g_o <= 0;
				r_rgb_b_o <= 0;
			end
		else if(r_image_mode == 8'b0000_0011)
			begin
				r_rgb_r_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
				r_rgb_g_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
				r_rgb_b_o <= ( temp_sum_Y[18] == 1'b0 ) ? temp_sum_Y[17:10] : 255;
			end
	end

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

endmodule