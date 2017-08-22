//---------------------------------------------------------------------------------------

// image_mode = 1

//---------------------------------------------------------------------------------------

module negative(

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

/////////////////////////////////////////////////////////////////////////////////////////

reg[7:0]							r_rgb_r_o;
reg[7:0]							r_rgb_g_o;
reg[7:0]							r_rgb_b_o;

reg									r_de_d0;
reg									r_hs_d0;
reg									r_vs_d0;

reg[7:0]							r_image_mode;

//---------------------------------------------------------------------------------------

assign vs_o = r_vs_d0;
assign hs_o = r_hs_d0;
assign de_o = r_de_d0;

assign rgb_r_o = r_rgb_r_o;
assign rgb_g_o = r_rgb_g_o;
assign rgb_b_o = r_rgb_b_o;

//---------------------------------------------------------------------------------------

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
				r_de_d0 <= 1'b0;					//sync to temp_xxxx
			end
		else
			begin
				r_de_d0 <= de_i;
			end
	end
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_hs_d0 <= 1'b0;					//sync to temp_xxxx
			end
		else
			begin
				r_hs_d0 <= hs_i;
			end
	end	
	
always@(posedge clock or negedge reset_n)
	begin
		if(!reset_n)
			begin
				r_vs_d0 <= 1'b0;					//sync to temp_xxxx
			end
		else
			begin
				r_vs_d0 <= vs_i;
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
		else if(de_i)
			begin
			    if(r_image_mode == 8'b0000_0001)
					begin
						r_rgb_r_o <= 255 - rgb_r_i;
						r_rgb_g_o <= 255 - rgb_g_i;
						r_rgb_b_o <= 255 - rgb_b_i;
					end
				else
					begin
						r_rgb_r_o <= rgb_r_i;
						r_rgb_g_o <= rgb_g_i;
						r_rgb_b_o <= rgb_b_i;
					end
			end
	end		

endmodule