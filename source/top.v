//---------------------------------------------------------------------------------------

module top(
		
		//
		CLK_50M, nRESET, 
		//
		LED_YG, LED_BLUE, LED_YELLOW, LED_RED, 
		//
		FPGA_K0, FPGA_K1,
		//
		FPGA_TX1, FPGA_RX1, FPGA_2102RST,
		//
		TX_D, TX_IDCK, TX_DE, TX_HSYNC, TX_VSYNC, TX_PO1, TX_RST,
		TXCEC, TXHPD,
		//
		RX_D, RX_OCK_INV, RX_SCDT, RX_CTL, RX_DE, RX_VSYNC, RX_HSYNC,
		RX_ODCK, DDC_RX_SDA, DDC_RX_SCL, RXHPD, RXCEC,
		//
		EN_CIS1V5, EN_CISA3V0, EN_CIS2V8, CIS_RST,
		CIS_VSYNC, CIS_PWDN, CIS_HREF, CIS_STROBE, CIS_XCLK, CIS_PCLK,
		CIS_Y,
		//
		mem_cs_n, mem_cke, mem_addr, mem_ba, mem_ras_n, mem_cas_n, mem_we_n,
		mem_clk, mem_clk_n, mem_dm, mem_dq, mem_dqs, mem_odt,
		//
		MCU_SDA0_3V3, MCU_SCL0_3V3, MCU_INT0, MCU_INT1, MCU_SCK, MCU_MISO, 
		MCU_MOSI, MCU_NSS, 
		//
		SD_DAT, SD_CMD, SD_CLK, SD_DET,
		//
		iXHis_LVDS, iXHis_SE0, iXHis_RX_CLK

        );
		
//---------------------------------------------------------------------------------------

// 
input				CLK_50M;
input				nRESET;

//
output				LED_YG;
output				LED_YELLOW;
output				LED_BLUE;
output				LED_RED;

//
input				FPGA_K0;
input				FPGA_K1;

//
output				FPGA_TX1;
input				FPGA_RX1;
output				FPGA_2102RST;

//
output	[23:0]		TX_D;
output				TX_IDCK;
output				TX_DE;
output				TX_HSYNC;
output				TX_VSYNC;
input				TX_PO1;
output				TX_RST;
output				TXCEC;
input				TXHPD;

//
input	[23:0]		RX_D;
output				RX_OCK_INV;
input				RX_SCDT;
input	[2:0]		RX_CTL;
input				RX_DE;
input				RX_VSYNC;
input				RX_HSYNC;
input				RX_ODCK;
output				DDC_RX_SCL;
inout				DDC_RX_SDA;
output				RXHPD;
input				RXCEC;

//
output				EN_CIS1V5;
output				EN_CISA3V0;
output				EN_CIS2V8;
output				CIS_RST;
input				CIS_VSYNC;
output				CIS_PWDN;
input				CIS_HREF;
input				CIS_STROBE;
output				CIS_XCLK;
input				CIS_PCLK;
input	[7:0]       CIS_Y;

//
output  	  		mem_cs_n;
output  	  		mem_cke;
output  [12:0]  	mem_addr;
output  [2:0]  		mem_ba;
output  			mem_ras_n;
output  			mem_cas_n;
output  			mem_we_n; 
inout  				mem_clk;
inout  				mem_clk_n;
output  [3:0]  		mem_dm;
inout  	[31:0]  	mem_dq; 
inout  	[3:0]  		mem_dqs; 
output				mem_odt;

//
inout 				MCU_SDA0_3V3;
input				MCU_SCL0_3V3;
output				MCU_INT0;
output 				MCU_INT1; 
input				MCU_SCK;
output				MCU_MISO;
input				MCU_MOSI; 
input				MCU_NSS;

//
inout	[3:0]    	SD_DAT; 
output				SD_CMD; 
output				SD_CLK; 
input				SD_DET;

//
output				iXHis_SE0;
input	[14:0]	    iXHis_LVDS;
input	            iXHis_RX_CLK;			
//---------------------------------------------------------------------------------------

wire  				mem_cs_n;
wire  				mem_cke;
wire	[12:0]  	mem_addr;
wire	[2:0]  		mem_ba;
wire  				mem_ras_n;
wire  				mem_cas_n;
wire  				mem_we_n;
wire  				mem_clk;
wire  				mem_clk_n;
wire	[3:0]  		mem_dm;
wire	[31:0]		mem_dq;
wire	[3:0]  		mem_dqs;

//
wire 								phy_clk;
wire	[23:0]						local_address;
wire 								local_write_req;
wire 								local_read_req;
wire	[MEM_DATA_BITS - 1:0]		local_wdata;
wire	[MEM_DATA_BITS/8 - 1:0]		local_be;
wire	[2:0]						local_size;
wire 								local_ready;
wire	[MEM_DATA_BITS - 1:0]		local_rdata;
wire 								local_rdata_valid;
wire 								local_wdata_req;
wire 								local_init_done;
wire 								wr_burst_finish;
wire 								rd_burst_finish;
wire	[23:0] 						wr_burst_addr;
wire	[23:0] 						rd_burst_addr;
wire 								wr_burst_data_req;
wire 								rd_burst_data_valid;
wire	[9:0] 						wr_burst_len;
wire	[9:0] 						rd_burst_len;
wire 								wr_burst_req;
wire 								rd_burst_req;
wire	[MEM_DATA_BITS - 1:0] 		wr_burst_data;
wire	[MEM_DATA_BITS - 1:0] 		rd_burst_data;
wire 								local_burstbegin;
wire 								rst_n;

//
wire 								vga_out_hs_tmp0;
reg 								vga_out_hs_tmp1;
reg 								vga_out_hs_tmp2;
wire 								vga_out_vs_tmp0;
reg 								vga_out_vs_tmp1;
reg 								vga_out_vs_tmp2;
wire 								vga_out_de_tmp0;
reg 								vga_out_de_tmp1;
reg 								vga_out_de_tmp2;
wire	[15:0] 						fifo_q;
reg		[23:0] 						fifo_q_d0;

//---------------------------------------------------------------------------------------

parameter MEM_DATA_BITS = 64;

//---------------------------------------------------------------------------------------

wire	[7:0]		s_image_mode;

wire	[7:0]		ssr_0;
wire	[7:0]		ssg_0;
wire	[7:0]		ssb_0;
wire				ssv_0;
wire				ssh_0;
wire				ssde_0;
wire	[7:0]		ssr_1;
wire	[7:0]		ssg_1;
wire	[7:0]		ssb_1;
wire				ssv_1;
wire				ssh_1;
wire				ssde_1;
wire	[7:0]		ssr_2;
wire	[7:0]		ssg_2;
wire	[7:0]		ssb_2;
wire				ssv_2;
wire				ssh_2;
wire				ssde_2;
wire	[7:0]		ssr_3;
wire	[7:0]		ssg_3;
wire	[7:0]		ssb_3;
wire				ssv_3;
wire				ssh_3;
wire				ssde_3;
wire	[7:0]		ssr_4;
wire	[7:0]		ssg_4;
wire	[7:0]		ssb_4;
wire				ssv_4;
wire				ssh_4;
wire				ssde_4;

//---------------------------------------------------------------------------------------

assign 				FPGA_2102RST = 1'b1;
assign 				TX_RST = 1'b1;
assign				RX_OCK_INV = 1'b1;

assign				DDC_RX_SCL = 1'bz;
assign				DDC_RX_SDA = 1'bz;

assign				MCU_INT0 = 1'b0;

//---------------------------------------------------------------------------------------

reset reset_m0(

			.clk(CLK_50M),
			.rst_n(rst_n)

);

tfp410_pll	tfp410_pll_u0(
				
			.inclk0(CLK_50M),
			.c0(TX_IDCK)
	
);

color_bar vga_color_bar(
			
			.clk(TX_IDCK),
			.rst(~rst_n),
			.hs(vga_out_hs_tmp0),
			.vs(vga_out_vs_tmp0),
			.de(vga_out_de_tmp0)		
			
);

always@(posedge TX_IDCK)
	begin
		vga_out_hs_tmp1 <= vga_out_hs_tmp0;
		vga_out_vs_tmp1 <= vga_out_vs_tmp0;
		vga_out_de_tmp1 <= vga_out_de_tmp0;
		vga_out_hs_tmp2 <= vga_out_hs_tmp1;
		vga_out_vs_tmp2 <= vga_out_vs_tmp1;
		vga_out_de_tmp2 <= vga_out_de_tmp1;	
		fifo_q_d0 <= {fifo_q[15:11], 3'b000, fifo_q[10:5], 2'b00, fifo_q[4:0], 3'b000};
	end
	
assign TX_HSYNC = vga_out_hs_tmp2;
assign TX_VSYNC = vga_out_vs_tmp2;
assign TX_DE = vga_out_de_tmp2;
assign TX_D = fifo_q_d0;

negative negative_u0(

				.clock(RX_ODCK), 
				.reset_n(nRESET),
				.vs_i(RX_VSYNC), 
				.hs_i(RX_HSYNC), 
				.de_i(RX_DE),
				.rgb_r_i(RX_D[23:16]),
				.rgb_g_i(RX_D[15:8]), 
				.rgb_b_i(RX_D[7:0]),
				.vs_o(ssv_0), 
				.hs_o(ssh_0), 
				.de_o(ssde_0),
				.rgb_r_o(ssr_0),
				.rgb_g_o(ssg_0),
				.rgb_b_o(ssb_0),
				.image_mode_i(s_img_mode),
		
);

emboss emboss_u0(

				.clock(RX_ODCK), 
				.reset_n(nRESET),
				.vs_i(ssv_0), 
				.hs_i(ssh_0), 
				.de_i(ssde_0),
				.rgb_r_i(ssr_0),
				.rgb_g_i(ssg_0), 
				.rgb_b_i(ssb_0),
				.vs_o(ssv_1), 
				.hs_o(ssh_1), 
				.de_o(ssde_1),
				.rgb_r_o(ssr_1),
				.rgb_g_o(ssg_1),
				.rgb_b_o(ssb_1),
				.image_mode_i(s_img_mode),
		
);

grayscaler grayscaler_u0(

				.clock(RX_ODCK), 
				.reset_n(nRESET),
				.vs_i(ssv_1), 
				.hs_i(ssh_1), 
				.de_i(ssde_1),
				.rgb_r_i(ssr_1),
				.rgb_g_i(ssg_1), 
				.rgb_b_i(ssb_1),
				.vs_o(ssv_2), 
				.hs_o(ssh_2), 
				.de_o(ssde_2),
				.rgb_r_o(ssr_2),
				.rgb_g_o(ssg_2),
				.rgb_b_o(ssb_2),
				.image_mode_i(s_img_mode),
		
);

white_black white_black_u0(

				.clock(RX_ODCK), 
				.reset_n(nRESET),
				.vs_i(ssv_2), 
				.hs_i(ssh_2), 
				.de_i(ssde_2),
				.rgb_r_i(ssr_2),
				.rgb_g_i(ssg_2), 
				.rgb_b_i(ssb_2),
				.vs_o(ssv_3), 
				.hs_o(ssh_3), 
				.de_o(ssde_3),
				.rgb_r_o(ssr_3),
				.rgb_g_o(ssg_3),
				.rgb_b_o(ssb_3),
				.image_mode_i(s_img_mode),
		
);

four_in_one four_in_one_u0(

				.clock(RX_ODCK), 
				.reset_n(nRESET),
				.vs_i(ssv_3), 
				.hs_i(ssh_3), 
				.de_i(ssde_3),
				.rgb_r_i(ssr_3),
				.rgb_g_i(ssg_3), 
				.rgb_b_i(ssb_3),
				.vs_o(ssv_4), 
				.hs_o(ssh_4), 
				.de_o(ssde_4),
				.rgb_r_o(ssr_4),
				.rgb_g_o(ssg_4),
				.rgb_b_o(ssb_4),
				.image_mode_i(s_img_mode),
		
);

vin_frame_buffer_ctrl vin_frame_buffer_ctrl_m0(

			.rst_n(rst_n),
			.vin_clk(RX_ODCK),
			.vin_vs(ssv_4),
			.vin_de(ssde_4),
			.vin_data({ssr_4[7:3], ssg_4[7:2], ssb_4[7:3]}),
			.vin_width(12'd480),
			.vin_height(),
			.mem_clk(phy_clk),
			.wr_burst_req(wr_burst_req),
			.wr_burst_len(wr_burst_len),
			.wr_burst_addr(wr_burst_addr),
			.wr_burst_data_req(wr_burst_data_req),
			.wr_burst_data(wr_burst_data),
			.burst_finish(wr_burst_finish),
			
);

vout_frame_buffer_ctrl vout_frame_buffer_ctrl_m0(

			.rst_n(rst_n),
			.vout_clk(TX_IDCK),
			.vout_vs(vga_out_vs_tmp0),
			.vout_rd_req(vga_out_de_tmp0),
			.vout_data(fifo_q),
			.vout_width(12'd480),
			.vout_height(),
			.mem_clk(phy_clk),
	
			.rd_burst_req(rd_burst_req),
			.rd_burst_len(rd_burst_len),
			.rd_burst_addr(rd_burst_addr),
			.rd_burst_data_valid(rd_burst_data_valid),
			.rd_burst_data(rd_burst_data),
			.burst_finish(rd_burst_finish)
			
);

ddr2 ddr_m0(

			.local_address(local_address),
			.local_write_req(local_write_req),
			.local_read_req(local_read_req),
			.local_wdata(local_wdata),
			.local_be(local_be),
			.local_size(local_size),
			.global_reset_n(rst_n),
	
			.pll_ref_clk(CLK_50M),
			.soft_reset_n(1'b1),
			.local_ready(local_ready),
			.local_rdata(local_rdata),
			.local_rdata_valid(local_rdata_valid),
			.reset_request_n(),
			.mem_cs_n(mem_cs_n),
			.mem_cke(mem_cke),
			.mem_addr(mem_addr),
			.mem_ba(mem_ba),
			.mem_ras_n(mem_ras_n),
			.mem_cas_n(mem_cas_n),
			.mem_we_n(mem_we_n),
			.mem_dm(mem_dm),

			.local_burstbegin(local_burstbegin),
			.local_init_done(local_init_done),
			.reset_phy_clk_n(),
			.phy_clk(phy_clk),
			.aux_full_rate_clk(),
			.aux_half_rate_clk(),
			.mem_clk(mem_clk),
			.mem_clk_n(mem_clk_n),
			.mem_dq(mem_dq),
			.mem_dqs(mem_dqs),
			.mem_odt(mem_odt)
			
);

mem_burst_v2 mem_burst_m0(

			.rst_n(rst_n),
			.mem_clk(phy_clk),
			.rd_burst_req(rd_burst_req),
			.wr_burst_req(wr_burst_req),
			.rd_burst_len(rd_burst_len),
			.wr_burst_len(wr_burst_len),
			.rd_burst_addr(rd_burst_addr),
			.wr_burst_addr(wr_burst_addr),
			.rd_burst_data_valid(rd_burst_data_valid),
			.wr_burst_data_req(wr_burst_data_req),
			.rd_burst_data(rd_burst_data),
			.wr_burst_data(wr_burst_data),
			.rd_burst_finish(rd_burst_finish),
			.wr_burst_finish(wr_burst_finish),
	
			.local_init_done(local_init_done),
			.local_ready(local_ready),
			.local_burstbegin(local_burstbegin),
			.local_wdata(local_wdata),
			.local_rdata_valid(local_rdata_valid),
			.local_rdata(local_rdata),
			.local_write_req(local_write_req),
			.local_read_req(local_read_req),
			.local_address(local_address),
			.local_be(local_be),
			.local_size(local_size)
	
);

wire[7:0] s_img_mode;

SPI0_Crl SPI0_Crl_m0(
		
		.clock(CLK_50M), 
		.reset_n(nRESET),
		.MCU_SCK_i(MCU_SCK), 
		.MCU_MISO_o(MCU_MISO), 
		.MCU_MOSI_i(MCU_MOSI), 
		.MCU_NSS_i(MCU_NSS),
		.base_ch0_hsync(), 
		.base_ch1_hsync(),
		.base_ch2_hsync(),
		.base_ch0_vsync(), 
		.base_ch1_vsync(),
		.base_ch2_vsync(),
		.width_ch0(), 
		.width_ch1(), 
		.width_ch2(),
		.chx_load_en(),
		.img_mode(s_img_mode)

);

//---------------------------------------------------------------------------------------

endmodule