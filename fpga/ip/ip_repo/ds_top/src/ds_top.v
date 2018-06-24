`timescale 1 ns / 1 ps
`include "ds_define.vh"
  
module ds_top #
(
	// Width of S_AXI data bus
	parameter integer C_S_AXI_DATA_WIDTH	= 32,
	// Width of S_AXI address bus
	parameter integer C_S_AXI_ADDR_WIDTH	= 32,

	parameter integer DATA_WIDTH = 32,

	parameter integer RESULT_WID = 64,
	
	parameter integer FORM_WIDTH = 32


)(
	input										clk,
	input                                       m_clk,
	input										rst,
/*---------   interface with ds_regtister    ----------- */
	input 	wire  								s_axi_aclk,
	input 	wire  								s_axi_aresetn,

	input	wire [C_S_AXI_ADDR_WIDTH-1 : 0]		s_axi_awaddr,
	input	wire  								s_axi_awvalid,
	output 	wire  								s_axi_awready,


	input	wire [C_S_AXI_DATA_WIDTH-1 : 0]		s_axi_wdata, 
	input 	wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	s_axi_wstrb,
	input 	wire  								s_axi_wvalid,
	output 	wire  								s_axi_wready,

	output 	wire [1 : 0] 						s_axi_bresp,
	output 	wire  								s_axi_bvalid,
	input 	wire  								s_axi_bready,

	input 	wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	s_axi_araddr,
	input 	wire  								s_axi_arvalid,
	output 	wire  								s_axi_arready,

	output 	wire [C_S_AXI_DATA_WIDTH-1 : 0]		s_axi_rdata,
	output 	wire [1 : 0]						s_axi_rresp,
	output 	wire  								s_axi_rvalid,
	input 	wire  								s_axi_rready,
	
/*------------ interface with ds_pep_store -------------*/
	output 	  							    pep_ready_s,    
	input   wire                                pep_valid_s, 
	input   wire    [207:0]                     pep_user_s,
	input 	wire	[8* DATA_WIDTH-1:0]			pep_data_s,
	input 	wire  	[DATA_WIDTH-1:0]			pep_keep_s,
	input 	wire  								pep_last_s,
	input	wire                                fifo_empty,
	
/*---------- interface with ds_spec_store -------------*/

	output 	reg 								spec_ready,    
	input   wire                                spec_valid, 
	input   wire 	[255 : 0] 					spec_data,          // spec_data[39 + 64 * i : 64 * i] = spec_i_data,   spec_data[59 + 64 * i : 40 + 64 * i] = spec_mz_data

	input 	wire  	[31 : 0]					spec_keep,
	input 	wire  								spec_last,
	input 	wire  	[15:0]						spec_len,

/*------------------------*/
    input 	wire	[39:0]						spec_mass,
    input 	wire 	[31:0] 						spec_seq_num,

/*--------- interface with ds_package ------------------- */		
	output 										m_axis_tvalid_s, 	
    input 										m_axis_tready_s, 	
    output 	[255 : 0]							m_axis_tdata_s, 	
    output 	[31 : 0]							m_axis_tkeep_s, 	
    output 										m_axis_tlast_s,	
/*--------- added ymc ------------------- */
	output  									process_done,
	input	[4 : 0]								spec_z_charge,
	output [3:0] debug_state,
	output [3:0] debug_state2,  //ymc
	output [1:0] debug_pep_dst,
	output [1:0] debug_package_dst,
    output  [C_S_AXI_DATA_WIDTH-1 : 0] 	debug_package_num

);
    reg                                 package_last;
    reg  								pep_ready;    
	reg                                 pep_ready_r;
    wire                                pep_valid; 
	reg                                 pep_valid_r;
	reg     [207:0]                     pep_user;
	wire	[8* DATA_WIDTH-1:0]			pep_data_s_1;
	wire	[5* DATA_WIDTH-1:0]			pep_data;
	wire  	[DATA_WIDTH-1:0]			pep_keep;
	wire  								pep_last;
	
    reg 								pep_ready_2;  
    reg                                 pep_ready_r_2;	
	wire                                pep_valid_2; 
	reg                                 pep_valid_r_2;
	reg     [207:0]                     pep_user_2;
	wire	[8* DATA_WIDTH-1:0]			pep_data_s_2;
	wire	[5* DATA_WIDTH-1:0]			pep_data_2;
	wire  	[DATA_WIDTH-1:0]			pep_keep_2;
	wire  								pep_last_2;
/*	   
	wire    [1:0]                       pep_valid_s_o; 
	wire    [415:0]                     pep_user_s_o;
	wire	[16* DATA_WIDTH-1:0]		pep_data_s_o;
	wire  	[2* DATA_WIDTH-1:0]			pep_keep_s_o;
	wire  	[1:0]						pep_last_s_o;
*/	
 	wire	[31:0]  					pro_seq_num;
	wire  	[39:0]						pep_mass;
    wire    [15:0]                      pep_len;
    wire    [15:0]                      pep_start;
	wire    [15:0]                      pep_end;
	wire    [31:0]                      mod_left;
	wire    [31:0]                      mod_right;
    wire    [7:0]                       pep_judge;    // {0; 0; 0; 0; IS_C; IS_N; TERM_C; TERM_N}
	wire    [15:0]                      missed_cleaves;

    wire	[31:0]  					pro_seq_num_2;
	wire  	[39:0]						pep_mass_2;
	wire    [15:0]                      pep_len_2;
	wire    [15:0]                      pep_start_2;
	wire    [15:0]                      pep_end_2;
	wire    [31:0]                      mod_left_2;
	wire    [31:0]                      mod_right_2;
	wire    [7:0]                       pep_judge_2;    // {0; 0; 0; 0; IS_C; IS_N; TERM_C; TERM_N}
	wire    [15:0]                      missed_cleaves_2;	

    reg     [1:0]                           pep_dst_s;
	reg     [1:0]                           pep_under_process;
	reg       		ds_rst;
	reg       		ds_rst_2;
	
always @(posedge clk or posedge rst) begin
	if (rst) 
		pep_dst_s <= 2'b01;
	else if (pep_last_s & pep_valid_s & pep_ready_s)
		pep_dst_s <= pep_dst_s + 2'b10;
	else if (pep_ready & (~pep_ready_2))
	    pep_dst_s <= 2'b01;
	else if (pep_ready_2 & (~pep_ready))
        pep_dst_s <= 2'b11;    
	else 
		pep_dst_s <= pep_dst_s;
end	


always @(posedge clk or posedge rst) begin
	if (rst) 
		pep_under_process <= 2'b00;
	else if ((pep_last_s & pep_valid_s & pep_ready_s) & ds_rst & ds_rst_2)
		pep_under_process <= pep_under_process - 2'b01;
	else if ((pep_last_s & pep_valid_s & pep_ready_s) & (~ds_rst) & (~ds_rst_2))
		pep_under_process <= pep_under_process + 2'b01;
	else if ((~(pep_last_s & pep_valid_s & pep_ready_s)) & ds_rst & ds_rst_2)
		pep_under_process <= pep_under_process - 2'b10;
	else if ((~(pep_last_s & pep_valid_s & pep_ready_s)) & ds_rst & (~ds_rst_2))
		pep_under_process <= pep_under_process - 2'b01;
	else if ((~(pep_last_s & pep_valid_s & pep_ready_s)) & (~ds_rst) & ds_rst_2)
		pep_under_process <= pep_under_process - 2'b01;
	else 
		pep_under_process <= pep_under_process;
end

always @(posedge clk or posedge rst) begin
	if (rst | ds_rst) 
		pep_user <= 208'b0;
	else if (pep_dst_s == 2'b01)
		pep_user <= pep_user_s;
	else 
		pep_user <= pep_user;
end	

always @(posedge clk or posedge rst) begin
	if (rst | ds_rst_2) 
		pep_user_2 <= 208'b0;
	else if (pep_dst_s == 2'b11)
		pep_user_2 <= pep_user_s;
	else 
		pep_user_2 <= pep_user_2;
end	

assign  pep_valid      = (pep_dst_s == 2'b01)?pep_valid_s:1'b0;
assign  pep_data_s_1   = (pep_dst_s == 2'b01)?pep_data_s:256'b0;
assign  pep_keep       = (pep_dst_s == 2'b01)?pep_keep_s:32'b0;
assign  pep_last       = (pep_dst_s == 2'b01)?pep_last_s:1'b0;

assign  pep_valid_2      = (pep_dst_s == 2'b11)?pep_valid_s:1'b0;
assign  pep_data_s_2     = (pep_dst_s == 2'b11)?pep_data_s:256'b0;
assign  pep_keep_2       = (pep_dst_s == 2'b11)?pep_keep_s:32'b0;
assign  pep_last_2       = (pep_dst_s == 2'b11)?pep_last_s:1'b0;
	
assign  pep_judge      = pep_user[80+:8];
assign  missed_cleaves = pep_user[64+:16];
assign  mod_left       = pep_user[32+:32];
assign  mod_right      = pep_user[0+:32];
assign  pro_seq_num    = pep_user[176+:32];
assign  pep_len        = pep_user[160+:16];
assign  pep_mass       = pep_user[120+:40];
assign  pep_start      = pep_user[104+:16];
assign  pep_end        = pep_user[88+:16];

assign  pep_judge_2      = pep_user_2[80+:8];
assign  missed_cleaves_2 = pep_user_2[64+:16];
assign  mod_left_2       = pep_user_2[32+:32];
assign  mod_right_2      = pep_user_2[0+:32];
assign  pro_seq_num_2    = pep_user_2[176+:32];
assign  pep_len_2        = pep_user_2[160+:16];
assign  pep_mass_2       = pep_user_2[120+:40];
assign  pep_start_2      = pep_user_2[104+:16];
assign  pep_end_2        = pep_user_2[88+:16];
/*
axis_switch_1_2 axis_switch_1_2_i(
  .aclk(clk),
  .aresetn(~rst),
  .s_axis_tvalid(pep_valid_s),
  .s_axis_tready(pep_ready_r),
 // .s_axis_tready(),
  .s_axis_tdata(pep_data_s),
  .s_axis_tkeep(pep_keep_s),
  .s_axis_tlast(pep_last_s),
  .s_axis_tdest(pep_dst_s),
  .s_axis_tuser(pep_user_s),
  .m_axis_tvalid(pep_valid_s_o),
  .m_axis_tready({pep_ready,pep_ready_2}),
  .m_axis_tdata(pep_data_s_o),
  .m_axis_tkeep(pep_keep_s_o),
  .m_axis_tlast(pep_last_s_o),
  .m_axis_tdest(),
  .m_axis_tuser(pep_user_s_o),//
  .s_decode_err()
);	

assign  pep_valid      = pep_valid_s_o[0];
assign  pep_data_s_1   = pep_data_s_o[0+:256];
assign  pep_keep       = pep_keep_s_o[0+:32];
assign  pep_last       = pep_last_s_o[0];
assign  pep_user       = pep_user_s_o[0+:208];

assign  pep_valid_2      = pep_valid_s_o[1];
assign  pep_data_s_2   = pep_data_s_o[256+:256];
assign  pep_keep_2       = pep_keep_s_o[32+:32];
assign  pep_last_2       = pep_last_s_o[1];
assign  pep_user_2       = pep_user_s_o[208+:208];
	
assign  pep_judge      = pep_user[80+:8];
assign  missed_cleaves = pep_user[64+:16];
assign  mod_left       = pep_user[32+:32];
assign  mod_right      = pep_user[0+:32];
assign  pro_seq_num    = pep_user[176+:32];
assign  pep_len        = pep_user[160+:16];
assign  pep_mass       = pep_user[120+:40];
assign  pep_begin      = pep_user[104+:16];
assign  pep_end        = pep_user[88+:16];

assign  pep_judge_2      = pep_user_2[80+:8];
assign  missed_cleaves_2 = pep_user_2[64+:16];
assign  mod_left_2       = pep_user_2[32+:32];
assign  mod_right_2      = pep_user_2[0+:32];
assign  pro_seq_num_2    = pep_user_2[176+:32];
assign  pep_len_2        = pep_user_2[160+:16];
assign  pep_mass_2       = pep_user_2[120+:40];
assign  pep_begin_2      = pep_user_2[104+:16];
assign  pep_end_2        = pep_user_2[88+:16];
*/
assign pep_data = 
{
pep_data_s_1[32 * 8 - 4 :31 * 8],
pep_data_s_1[31 * 8 - 4 :30 * 8],
pep_data_s_1[30 * 8 - 4 :29 * 8],
pep_data_s_1[29 * 8 - 4 :28 * 8],
pep_data_s_1[28 * 8 - 4 :27 * 8],
pep_data_s_1[27 * 8 - 4 :26 * 8],
pep_data_s_1[26 * 8 - 4 :25 * 8],
pep_data_s_1[25 * 8 - 4 :24 * 8],
pep_data_s_1[24 * 8 - 4 :23 * 8],
pep_data_s_1[23 * 8 - 4 :22 * 8],
pep_data_s_1[22 * 8 - 4 :21 * 8],
pep_data_s_1[21 * 8 - 4 :20 * 8],
pep_data_s_1[20 * 8 - 4 :19 * 8],
pep_data_s_1[19 * 8 - 4 :18 * 8],
pep_data_s_1[18 * 8 - 4 :17 * 8],
pep_data_s_1[17 * 8 - 4 :16 * 8],
pep_data_s_1[16 * 8 - 4 :15 * 8],
pep_data_s_1[15 * 8 - 4 :14 * 8],
pep_data_s_1[14 * 8 - 4 :13 * 8],
pep_data_s_1[13 * 8 - 4 :12 * 8],
pep_data_s_1[12 * 8 - 4 :11 * 8],
pep_data_s_1[11 * 8 - 4 :10 * 8],
pep_data_s_1[10 * 8 - 4 : 9 * 8],
pep_data_s_1[ 9 * 8 - 4 : 8 * 8],
pep_data_s_1[ 8 * 8 - 4 : 7 * 8],
pep_data_s_1[ 7 * 8 - 4 : 6 * 8],
pep_data_s_1[ 6 * 8 - 4 : 5 * 8],
pep_data_s_1[ 5 * 8 - 4 : 4 * 8],
pep_data_s_1[ 4 * 8 - 4 : 3 * 8],
pep_data_s_1[ 3 * 8 - 4 : 2 * 8],
pep_data_s_1[ 2 * 8 - 4 : 1 * 8],
pep_data_s_1[ 1 * 8 - 4 : 0 * 8]
};

assign pep_data_2 = 
{
pep_data_s_2[32 * 8 - 4 :31 * 8],
pep_data_s_2[31 * 8 - 4 :30 * 8],
pep_data_s_2[30 * 8 - 4 :29 * 8],
pep_data_s_2[29 * 8 - 4 :28 * 8],
pep_data_s_2[28 * 8 - 4 :27 * 8],
pep_data_s_2[27 * 8 - 4 :26 * 8],
pep_data_s_2[26 * 8 - 4 :25 * 8],
pep_data_s_2[25 * 8 - 4 :24 * 8],
pep_data_s_2[24 * 8 - 4 :23 * 8],
pep_data_s_2[23 * 8 - 4 :22 * 8],
pep_data_s_2[22 * 8 - 4 :21 * 8],
pep_data_s_2[21 * 8 - 4 :20 * 8],
pep_data_s_2[20 * 8 - 4 :19 * 8],
pep_data_s_2[19 * 8 - 4 :18 * 8],
pep_data_s_2[18 * 8 - 4 :17 * 8],
pep_data_s_2[17 * 8 - 4 :16 * 8],
pep_data_s_2[16 * 8 - 4 :15 * 8],
pep_data_s_2[15 * 8 - 4 :14 * 8],
pep_data_s_2[14 * 8 - 4 :13 * 8],
pep_data_s_2[13 * 8 - 4 :12 * 8],
pep_data_s_2[12 * 8 - 4 :11 * 8],
pep_data_s_2[11 * 8 - 4 :10 * 8],
pep_data_s_2[10 * 8 - 4 : 9 * 8],
pep_data_s_2[ 9 * 8 - 4 : 8 * 8],
pep_data_s_2[ 8 * 8 - 4 : 7 * 8],
pep_data_s_2[ 7 * 8 - 4 : 6 * 8],
pep_data_s_2[ 6 * 8 - 4 : 5 * 8],
pep_data_s_2[ 5 * 8 - 4 : 4 * 8],
pep_data_s_2[ 4 * 8 - 4 : 3 * 8],
pep_data_s_2[ 3 * 8 - 4 : 2 * 8],
pep_data_s_2[ 2 * 8 - 4 : 1 * 8],
pep_data_s_2[ 1 * 8 - 4 : 0 * 8]
};	

    wire										m_axis_tvalid;
    wire 										m_axis_tready;
    wire 	[255 : 0]							m_axis_tdata;	
    wire 	[31 : 0]							m_axis_tkeep;
    wire 										m_axis_tlast;	
/*--------- added ------------------- */	
	wire									    m_axis_tvalid_2;
    wire								        m_axis_tready_2;	
    wire 	[255 : 0]							m_axis_tdata_2;	
    wire 	[31 : 0]							m_axis_tkeep_2;	
    wire 										m_axis_tlast_2;
	
/*--------- state control signal -----------*/
wire			cmp_done;
reg         	submit_done;
//reg 			unmatch; 

reg 	 [3 : 0] current;
reg     [3 : 0] next;


					 wire			cmp_done_2;
reg         	submit_done_2;
//reg 			unmatch; 

reg 	 [3 : 0] current_2;
reg     [3 : 0] next_2;




parameter   [3 : 0]   	setting   	= 4'b0000,
						idling      = 4'b0001,
				    	prepare 	= 4'b0010,     // match module and bram store module
						compute		= 4'b0100,
						pack 	    = 4'b1000;


wire [FORM_WIDTH - 1 : 0]         	ds_ctrl;
wire [FORM_WIDTH - 1 : 0]         	m_nt;
wire [FORM_WIDTH - 1 : 0]         	m_ct;
wire [FORM_WIDTH - 1 : 0]         	m_cleave_n;
wire [FORM_WIDTH - 1 : 0]         	m_cleave_c;
wire [FORM_WIDTH - 1 : 0]         	woe;
wire [FORM_WIDTH - 1 : 0]           parent_err_minus;
wire [FORM_WIDTH - 1 : 0]  			parent_err_plus;
wire [FORM_WIDTH - 1 : 0]           parent_err_minus_ppm;
wire [FORM_WIDTH - 1 : 0]  			parent_err_plus_ppm;
 
//wire [FORM_WIDTH - 1 : 0]          	mod_left;
//wire [FORM_WIDTH - 1 : 0]          	mod_right;
wire [FORM_WIDTH - 1 : 0]          	fullmod_left;
wire [FORM_WIDTH - 1 : 0]          	fullmod_right;

//wire [26 * FORM_WIDTH - 1 : 0]		mod_mass;
//wire [26 * FORM_WIDTH - 1 : 0]		fmod_mass;
//wire [26 * FORM_WIDTH - 1 : 0]		ppt_mass;
//wire [26 * FORM_WIDTH - 1 : 0]		smod_mass;	
//
//assign mod_mass  = {(26 * FORM_WIDTH){1'h0}};
//assign fmod_mass = {(26 * FORM_WIDTH){1'h0}};
//assign ppt_mass  = {(26 * FORM_WIDTH){1'h0}};
//assign smod_mass = {(26 * FORM_WIDTH){1'h0}};

wire [159 : 0] 				rd_addr_x_cb;       
wire [159 : 0] 				rd_addr_y_cb;       
wire [159 : 0] 				rd_addr_z_cb;       
wire [159 : 0] 				rd_addr_a_cb;       
wire [159 : 0] 				rd_addr_b_cb;       
wire [159 : 0] 				rd_addr_c_cb;       
wire [1023 : 0]				rd_data_x_cb;        
wire [1023 : 0]				rd_data_y_cb;        
wire [1023 : 0]				rd_data_z_cb;        
wire [1023 : 0]				rd_data_a_cb;        
wire [1023 : 0]				rd_data_b_cb;        
wire [1023 : 0]				rd_data_c_cb;

wire [159 : 0] 				rd_addr_x_cb_2;       
wire [159 : 0] 				rd_addr_y_cb_2;       
wire [159 : 0] 				rd_addr_z_cb_2;       
wire [159 : 0] 				rd_addr_a_cb_2;       
wire [159 : 0] 				rd_addr_b_cb_2;       
wire [159 : 0] 				rd_addr_c_cb_2;       
wire [1023 : 0]				rd_data_x_cb_2;        
wire [1023 : 0]				rd_data_y_cb_2;        
wire [1023 : 0]				rd_data_z_cb_2;        
wire [1023 : 0]				rd_data_a_cb_2;        
wire [1023 : 0]				rd_data_b_cb_2;        
wire [1023 : 0]				rd_data_c_cb_2;

reg  [C_S_AXI_DATA_WIDTH-1 : 0] 	package_num;


`ifdef   TIME_COUNT
//	wire   [31 : 0]  match_time_reg;
	reg    [31 : 0]  dot_time_reg;
	reg    [31 : 0]  frag_time_reg;

	wire    cnt_reset;
	assign 	cnt_reset = spec_ready & spec_valid & spec_last;
`endif


ds_registers #
	(
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	)
ds_registers_i(
		.clk            (clk),
		.S_AXI_ACLK 	(s_axi_aclk),
		.S_AXI_ARESETN 	(s_axi_aresetn),

		.S_AXI_AWADDR 	(s_axi_awaddr) ,
		.S_AXI_AWVALID 	(s_axi_awvalid),
		.S_AXI_AWREADY 	(s_axi_awready),


		.S_AXI_WDATA 	(s_axi_wdata), 
		.S_AXI_WSTRB 	(s_axi_wstrb),
		.S_AXI_WVALID 	(s_axi_wvalid),
		.S_AXI_WREADY 	(s_axi_wready),

		.S_AXI_BRESP 	(s_axi_bresp), 
		.S_AXI_BVALID 	(s_axi_bvalid),
		.S_AXI_BREADY 	(s_axi_bready),

		.S_AXI_ARADDR 	(s_axi_araddr),
		.S_AXI_ARVALID 	(s_axi_arvalid),
		.S_AXI_ARREADY 	(s_axi_arready),

		.S_AXI_RDATA 	(s_axi_rdata),
		.S_AXI_RRESP 	(s_axi_rresp),
		.S_AXI_RVALID 	(s_axi_rvalid),
		.S_AXI_RREADY 	(s_axi_rready),

		.slv_reg0 		(ds_ctrl),
		.slv_reg1 		(m_nt),
		.slv_reg2 		(m_ct),
		.slv_reg3 		(m_cleave_n),
		.slv_reg4 		(m_cleave_c),
		.slv_reg5 		(woe),
		.slv_reg6 		(parent_err_minus),
		.slv_reg7		(parent_err_plus),
		.slv_reg8 		(parent_err_minus_ppm),
		.slv_reg9 		(parent_err_plus_ppm),
		.slv_reg10		(fullmod_left),
		.slv_reg11		(fullmod_right),
		//.slv_reg12 		(mod_left),
		//.slv_reg13      (mod_right),

`ifdef TIME_COUNT
		.frag_time_reg  (frag_time_reg),
		.dot_time_reg 	(dot_time_reg),
`endif
        .ds_state       (current),
		.package_num    (package_num),

		.rd_addr_x_cb 	(rd_addr_x_cb),				// input	[159 : 0]							
		.rd_addr_y_cb 	(rd_addr_y_cb),				// input	[159 : 0]							
		.rd_addr_z_cb 	(rd_addr_z_cb),				// input	[159 : 0]							
		.rd_addr_a_cb 	(rd_addr_a_cb),				// input	[159 : 0]							
		.rd_addr_b_cb 	(rd_addr_b_cb),				// input	[159 : 0]							
		.rd_addr_c_cb 	(rd_addr_c_cb),				// input	[159 : 0]							

		.rd_data_y_cb 	(rd_data_y_cb),				// output	[1024 : 0]							
		.rd_data_z_cb 	(rd_data_z_cb),				// output	[1024 : 0]							
		.rd_data_x_cb 	(rd_data_x_cb),				// output	[1024 : 0]							
		.rd_data_a_cb 	(rd_data_a_cb),				// output	[1024 : 0]							
		.rd_data_b_cb 	(rd_data_b_cb),				// output	[1024 : 0]							
		.rd_data_c_cb 	(rd_data_c_cb),				// output	[1024 : 0]		

        .rd_addr_x_cb_2 	(rd_addr_x_cb_2),				// input	[159 : 0]							
		.rd_addr_y_cb_2  	(rd_addr_y_cb_2),				// input	[159 : 0]							
		.rd_addr_z_cb_2 	(rd_addr_z_cb_2),				// input	[159 : 0]							
		.rd_addr_a_cb_2 	(rd_addr_a_cb_2),				// input	[159 : 0]							
		.rd_addr_b_cb_2 	(rd_addr_b_cb_2),				// input	[159 : 0]							
		.rd_addr_c_cb_2 	(rd_addr_c_cb_2),				// input	[159 : 0]							

		.rd_data_y_cb_2 	(rd_data_y_cb_2),				// output	[1024 : 0]							
		.rd_data_z_cb_2 	(rd_data_z_cb_2),				// output	[1024 : 0]							
		.rd_data_x_cb_2 	(rd_data_x_cb_2),				// output	[1024 : 0]							
		.rd_data_a_cb_2 	(rd_data_a_cb_2),				// output	[1024 : 0]							
		.rd_data_b_cb_2 	(rd_data_b_cb_2),				// output	[1024 : 0]							
		.rd_data_c_cb_2 	(rd_data_c_cb_2)				// output	[1024 : 0]			

	);


//wire 	[1 : 0]			mass_match;
/*
ds_mass_comparison #
	(

  		//.parent_err_minus  	(40'h0006400000),//100(q20 format)
  		//.parent_err_plus   	(40'h0006400000),//100(q20 format)
  		.isotope_err 		(1),
  		.is_ppm    		 	(1),
  		.is_dalton         	(0),
  		.data_length       	(40)
	)
ds_mass_comparison_i (

//	`ifdef  TIME_COUNT
//		.match_time_cnt 	(match_time_reg),
//		.cnt_reset 			(cnt_reset),
//	`endif

	    .clk 				(clk),
		.rst 				(rst),				
		.spectrum_mh 		(spec_mass),
		.spectrum_mh_ready  (spec_valid & spec_ready),
		.seq_mh 			(pep_mass),
		.seq_mh_ready		(pep_valid & pep_ready),
		.parent_mass_match 	(mass_match),
		.parent_err_minus   ({8'h0, parent_err_minus}),
		.parent_err_plus    ({8'h0, parent_err_plus}),
		.parent_err_minus_ppm ({8'h0, parent_err_minus_ppm}),
		.parent_err_plus_ppm ({8'h0, parent_err_plus_ppm})
	   );
*/

reg 	[15 : 0] 					pep_length;
wire 	[4 : 0] 					pep_read_addr_x;
wire 	[4 : 0] 					pep_read_addr_y;
wire 	[4 : 0] 					pep_read_addr_z;
wire 	[4 : 0] 					pep_read_addr_a;
wire 	[4 : 0] 					pep_read_addr_b;
wire 	[4 : 0] 					pep_read_addr_c;

wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_x;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_y;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_z;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_a;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_b;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_c;

/*added*/
reg 	[15 : 0] 					pep_length_2;
wire 	[4 : 0] 					pep_read_addr_x_2;
wire 	[4 : 0] 					pep_read_addr_y_2;
wire 	[4 : 0] 					pep_read_addr_z_2;
wire 	[4 : 0] 					pep_read_addr_a_2;
wire 	[4 : 0] 					pep_read_addr_b_2;
wire 	[4 : 0] 					pep_read_addr_c_2;

wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_x_2;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_y_2;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_z_2;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_a_2;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_b_2;
wire    [5 * DATA_WIDTH-1:0]	 	pep_bram_data_c_2;
/*added*/

wire    spec_update;
wire    spec_update_1;
wire    spec_update_2;
reg   	pep_store_last;
reg   	pep_store_last_2;
reg   	spec_store_last;
reg   	prepare_done;
reg   	prepare_done_2;
wire            			ds_blocked;
wire            			ds_blocked_2;
wire    [9:0] 					    fifo_count_1;
wire    [9:0] 					    fifo_count_2;

assign pep_ready_s = ((pep_dst_s == 2'b01) & pep_ready) | ((pep_dst_s == 2'b11) & pep_ready_2);

always @(posedge clk or posedge rst) begin
	if (rst) 
		pep_ready <= 1'b0;
	else if (pep_last & pep_valid & pep_ready)
		pep_ready <= 1'b0;
	else if (spec_update)
		pep_ready <= 1'b0;
	else if ((current == prepare) & (~fifo_empty) & (~pep_store_last))
		pep_ready <= 1'b1;
	else 
		pep_ready <= pep_ready;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		pep_ready_2 <= 1'b0;
	else if (pep_last_2 & pep_valid_2 & pep_ready_2)
		pep_ready_2 <= 1'b0;
	else if (spec_update)
		pep_ready_2 <= 1'b0;
	else if ((current_2 == prepare) & (~fifo_empty) & (~pep_store_last_2))
		pep_ready_2 <= 1'b1;
	else 
		pep_ready_2 <= pep_ready_2;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
	   begin
		pep_ready_r <= 1'b0;
		pep_valid_r <= 1'b0;
		pep_ready_r_2 <= 1'b0;
		pep_valid_r_2 <= 1'b0;
	   end
	else
	   begin
		pep_ready_r <= pep_ready;
		pep_valid_r <= pep_valid;
		pep_ready_r_2 <= pep_ready_2;
		pep_valid_r_2 <= pep_valid_2;
	  end
end	


assign  spec_update = fifo_empty & ( ((ds_rst | ds_rst_2) & (pep_under_process == 2'b01)) | (ds_rst & ds_rst_2 & pep_under_process == 2'b10)); 
assign  spec_update_1 = fifo_empty & ((ds_rst & (pep_under_process == 2'b01)) | (ds_rst & ds_rst_2 & pep_under_process == 2'b10)); 
assign  spec_update_2 = fifo_empty & ((ds_rst_2 & (pep_under_process == 2'b01)) | (ds_rst & ds_rst_2 & pep_under_process == 2'b10)); 

reg  spec_update_s;
reg  spec_update_s_1;
reg  spec_update_s_2;

always @(posedge clk or posedge rst) begin
  	if (rst)
  		spec_update_s <= 1'b1;
  	else if (spec_update)
  		 spec_update_s <= 1'b1;
  	else if (spec_last & spec_valid & spec_ready & (current == setting)&(current_2 == setting))
  		spec_update_s <= 1'b0;
  	else
  	    spec_update_s <= spec_update_s;
end  

always @(posedge clk or posedge rst) begin
  	if (rst)
  		spec_update_s_1 <= 1'b1;
  	else if (spec_update_1)
  		 spec_update_s_1 <= 1'b1;
  	else if (spec_last & spec_valid & spec_ready & (current == setting))
  		spec_update_s_1 <= 1'b0;
  	else 
  	    spec_update_s_1 <= spec_update_s_1;
end 

always @(posedge clk or posedge rst) begin
  	if (rst)
  		spec_update_s_2 <= 1'b1;
  	else if (spec_update_2)
  		 spec_update_s_2 <= 1'b1;
  	else if (spec_last & spec_valid & spec_ready & (current_2 == setting))
  		spec_update_s_2 <= 1'b0;
  	else
  	    spec_update_s_2 <= spec_update_s_2;
end 


assign process_done = spec_update_s & (submit_done | submit_done_2);


always @(posedge clk or posedge rst) begin
	if (rst) 
		spec_ready <= 1'b0;
	else if (spec_valid & spec_last & spec_ready)
		spec_ready <= 1'b0;
	else if ((current == setting) & (current_2 == setting) & spec_update_s)
		spec_ready <= 1'b1;
	else 
		spec_ready <= spec_ready;
end

//wire  pep_in_ready;
//assign  pep_in_ready = pep_ready & pep_valid;
/*always @(posedge clk or posedge rst) begin
	if (rst) 
		pep_in_ready <= 1'b0;
	else if (pep_ready & pep_valid) begin
		pep_in_ready <= 1'b1;
	else if(pep_last)
		pep_in_ready <= 1'b0;
	else 
		pep_in_ready <= pep_in_ready;
end
*/

ds_pep_store #    // pep chain store
	(
		.DATA_WIDTH(32),
		.BRAM_DEPTH(32)
	)
ds_pep_store_i(
		.clk 		(clk),
		.rst 		(rst),
	
		/* bram write interface */
		//input wire							recv_begin,  //recv_begin = pep_valid & frag_gen_idle & ; 
		.pep_valid	(pep_valid & pep_ready),      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
		.pep_data	(pep_data),
		.pep_keep	(pep_keep),
		.pep_last	(pep_last),

		/* bram read interface*/
		.read_addr_x  (pep_read_addr_x),
		.read_addr_y  (pep_read_addr_y),
		.read_addr_z  (pep_read_addr_z),
		.read_addr_a  (pep_read_addr_a),
		.read_addr_b  (pep_read_addr_b),
		.read_addr_c  (pep_read_addr_c),
		.data_out_x 	(pep_bram_data_x),
		.data_out_y 	(pep_bram_data_y),
		.data_out_z 	(pep_bram_data_z),
		.data_out_a 	(pep_bram_data_a),
		.data_out_b 	(pep_bram_data_b),
		.data_out_c 	(pep_bram_data_c)		
	);

	/* added*/
	ds_pep_store #    // pep chain store
	(
		.DATA_WIDTH(32),
		.BRAM_DEPTH(32)
	)
ds_pep_store_i_2(
		.clk 		(clk),
		.rst 		(rst),
	
		/* bram write interface */
		//input wire							recv_begin,  //recv_begin = pep_valid & frag_gen_idle & ; 
		.pep_valid	(pep_valid_2 & pep_ready_2),      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
		.pep_data	(pep_data_2),
		.pep_keep	(pep_keep_2),
		.pep_last	(pep_last_2),

		/* bram read interface*/
		.read_addr_x  (pep_read_addr_x_2),
		.read_addr_y  (pep_read_addr_y_2),
		.read_addr_z (pep_read_addr_z_2),
		.read_addr_a  (pep_read_addr_a_2),
		.read_addr_b  (pep_read_addr_b_2),
		.read_addr_c  (pep_read_addr_c_2),
		.data_out_x 	(pep_bram_data_x_2),
		.data_out_y	(pep_bram_data_y_2),
		.data_out_z 	(pep_bram_data_z_2),
		.data_out_a 	(pep_bram_data_a_2),
		.data_out_b 	(pep_bram_data_b_2),
		.data_out_c 	(pep_bram_data_c_2)	
	);
		
   /* added*/
		
		
wire  	[15 : 0] 	spec_length;
wire    [4 : 0]     spec_z_charge_r;
wire 	[4 : 0]		spec_read_addr_a;
wire 	[4 : 0]		spec_read_addr_b;
wire 	[4 : 0]		spec_read_addr_c;
wire 	[4 : 0]		spec_read_addr_x;
wire 	[4 : 0]		spec_read_addr_y;
wire    [4 : 0]     spec_read_addr_y_1;
wire 	[4 : 0]		spec_read_addr_z;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_0;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_0;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_1;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_1;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_3;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_3;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_4;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_4;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_4_1;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_4_1;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_5;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_5;

wire 	[4 : 0]		spec_read_addr_a_2;
wire 	[4 : 0]		spec_read_addr_b_2;
wire 	[4 : 0]		spec_read_addr_c_2;
wire 	[4 : 0]		spec_read_addr_x_2;
wire 	[4 : 0]		spec_read_addr_y_2;
wire    [4 : 0]     spec_read_addr_y_1_2;
wire 	[4 : 0]		spec_read_addr_z_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_0_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_0_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_1_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_1_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_2_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_2_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_3_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_3_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_4_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_4_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_4_1_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_4_1_2;
wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_5_2;
wire 	[40 * DATA_WIDTH - 1 : 0]        data_i_out_5_2;

/*
always @(posedge clk or posedge rst) begin
	if (rst) 
		spec_in_ready <= 1'b0;
	else if (spec_valid & spec_ready) 
		spec_in_ready <= 1'b1;
	else if (spec_last)
		spec_in_ready <= 1'b0;
	else 
		spec_in_ready <= spec_in_ready;
end
*/
ds_spec_store #    // pep chain store
	(
		.DATA_WIDTH (32),
		.BRAM_DEPTH (32)
	)
ds_spec_store_i(
		.clk 		(clk),
		.rst 		(rst),
	
		//.restore 	(ds_done),

		/* bram write interface */
		//input wire							recv_begin,  //recv_begin = pep_valid & frag_gen_idle & ; 
		.spec_valid 	(spec_valid & spec_ready),      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
	    .spec_data      (spec_data),
	    //.spec_mz_data (spec_mz_data),
        //.spec_i_data 	(spec_i_data),
		.spec_keep 		(spec_keep),
		.spec_last 		(spec_last),
		.spec_len 		(spec_len),
		.spec_z_charge  (spec_z_charge),

		.spec_length	(spec_length),
		.spec_z_charge_r    (spec_z_charge_r),
		

		/* bram read interface*/
		.read_addr_0 		(spec_read_addr_a),
		.read_addr_1 		(spec_read_addr_b),
		.read_addr_2 		(spec_read_addr_c),
		.read_addr_3 		(spec_read_addr_x),
		.read_addr_4 		(spec_read_addr_y),
		.read_addr_4_1		(spec_read_addr_y_1), 
		.read_addr_5 		(spec_read_addr_z),


		.data_mz_out_0		(data_mz_out_0),   // a type
		.data_mz_out_1		(data_mz_out_1),   // b type
		.data_mz_out_2		(data_mz_out_2),   // c type
		.data_mz_out_3		(data_mz_out_3),   // x type
		.data_mz_out_4		(data_mz_out_4),   // y type
		.data_mz_out_4_1	(data_mz_out_4_1), 
		.data_mz_out_5		(data_mz_out_5),   // z type
		.data_i_out_0		(data_i_out_0),
		.data_i_out_1		(data_i_out_1),
		.data_i_out_2		(data_i_out_2),
		.data_i_out_3		(data_i_out_3),
		.data_i_out_4		(data_i_out_4),
  		.data_i_out_4_1 	(data_i_out_4_1),
		.data_i_out_5		(data_i_out_5)
 
	);

	ds_spec_store #    // pep chain store
	(
		.DATA_WIDTH (32),
		.BRAM_DEPTH (32)
	)
ds_spec_store_i_2(
		.clk 		(clk),
		.rst 		(rst),
	
		//.restore 	(ds_done),

		/* bram write interface */
		//input wire							recv_begin,  //recv_begin = pep_valid & frag_gen_idle & ; 
		.spec_valid 	(spec_valid & spec_ready),      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
	    .spec_data      (spec_data),
	    //.spec_mz_data (spec_mz_data),
        //.spec_i_data 	(spec_i_data),
		.spec_keep 		(spec_keep),
		.spec_last 		(spec_last),
		.spec_len 		(spec_len),
		.spec_z_charge  (spec_z_charge),

		//.spec_length	(spec_length),
		//.spec_z_charge_r    (spec_z_charge_r),
		.spec_length	(),
		.spec_z_charge_r    (),

		/* bram read interface*/
		.read_addr_0 		(spec_read_addr_a_2),
		.read_addr_1 		(spec_read_addr_b_2),
		.read_addr_2 		(spec_read_addr_c_2),
		.read_addr_3 		(spec_read_addr_x_2),
		.read_addr_4 		(spec_read_addr_y_2),
		.read_addr_4_1		(spec_read_addr_y_1_2), 
		.read_addr_5 		(spec_read_addr_z_2),


		.data_mz_out_0		(data_mz_out_0_2),   // a type
		.data_mz_out_1		(data_mz_out_1_2),   // b type
		.data_mz_out_2		(data_mz_out_2_2),   // c type
		.data_mz_out_3		(data_mz_out_3_2),   // x type
		.data_mz_out_4		(data_mz_out_4_2),   // y type
		.data_mz_out_4_1	(data_mz_out_4_1_2), 
		.data_mz_out_5		(data_mz_out_5_2),   // z type
		.data_i_out_0		(data_i_out_0_2),
		.data_i_out_1		(data_i_out_1_2),
		.data_i_out_2		(data_i_out_2_2),
		.data_i_out_3		(data_i_out_3_2),
		.data_i_out_4		(data_i_out_4_2),
  		.data_i_out_4_1 	(data_i_out_4_1_2),
		.data_i_out_5		(data_i_out_5_2)
 
	);


always @(posedge clk or posedge rst) begin
	if (rst) 	
		pep_store_last <= 1'b0;
	else if ((current == prepare) & pep_last & pep_valid & pep_ready) 
		pep_store_last <= 1'b1;
	else if ((current == prepare) &&  prepare_done)
		pep_store_last <= 1'b0;
	else 
	    pep_store_last <= pep_store_last;
end

always @(posedge clk or posedge rst) begin
	if (rst) 	
		pep_store_last_2 <= 1'b0;
	else if ((current_2 == prepare) & pep_last_2 & pep_valid_2 & pep_ready_2) 
		pep_store_last_2 <= 1'b1;
	else if ((current_2 == prepare) &&  prepare_done_2)
		pep_store_last_2 <= 1'b0;
	else 
	    pep_store_last_2 <= pep_store_last_2;
end

always @(posedge clk or posedge rst) begin
	if (rst) 	
		spec_store_last <= 1'b0;
	else if ((current == setting) & (current_2 == setting) & spec_last & spec_valid & spec_ready) 
		spec_store_last <= 1'b1;
	else if ((current == setting) & (next_2 == idling) & (current_2 == setting) & (next_2 == idling))
		spec_store_last <= 1'b0;
	else
	    spec_store_last <= spec_store_last;
end

reg  [2 : 0]		match_check_delay;
reg  [2 : 0]		match_check_delay_2;

always @(posedge clk or posedge rst) begin
	if (rst)
		match_check_delay <= 3'b0;
	else if ((current == prepare) && pep_store_last) 
		match_check_delay <= match_check_delay + 3'b1;
	else if (~pep_store_last)
		match_check_delay <= 1'b0;
	else
	    match_check_delay <= match_check_delay;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		match_check_delay_2 <= 3'b0;
	else if ((current_2 == prepare) && pep_store_last_2) 
		match_check_delay_2 <= match_check_delay_2 + 3'b1;
	else if (~pep_store_last_2)
		match_check_delay_2 <= 1'b0;
	else
	    match_check_delay_2 <= match_check_delay_2;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		prepare_done <= 1'b0;
	else if ((current == prepare) & pep_store_last )//& (match_check_delay < 3'h6) & (mass_match == 2'b11)) 
		prepare_done <= 1'b1;
	else if ((~ds_blocked) & prepare_done)
		prepare_done <= 1'b0;
	else
		prepare_done <= prepare_done;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		prepare_done_2 <= 1'b0;
	else if ((current_2 == prepare) & pep_store_last_2 )//& (match_check_delay < 3'h6) & (mass_match == 2'b11)) 
		prepare_done_2 <= 1'b1;
	else if ((~ds_blocked_2) & prepare_done_2)
		prepare_done_2 <= 1'b0;
	else
		prepare_done_2 <= prepare_done_2;
end
/*
always @(posedge clk or posedge rst) begin
	if (rst) 
		unmatch <= 1'b0;
	else if ((current == prepare) && ((match_check_delay > 3'h6) || (match_check_delay <= 3'h6 && mass_match == 2'b01)))
		unmatch <= 1'b1;
	else 
		unmatch <= 1'b0;		
end

*/
reg   [31 : 0]      mod_left_r;
reg   [31 : 0]      mod_right_r;
reg   [7 : 0]       pep_judge_r;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mod_left_r <= 32'h0;
		mod_right_r <= 32'h0;
		pep_judge_r <= 8'h0;
	end
	else if (pep_ready & pep_valid) begin
		mod_left_r <= mod_left;
		mod_right_r <= mod_right;
		pep_judge_r <= pep_judge;		
	end
	else begin
		mod_left_r <= mod_left_r;
		mod_right_r <= mod_right_r;
		pep_judge_r <= pep_judge_r;	
	end
end

/*added*/
reg   [31 : 0]      mod_left_r_2;
reg   [31 : 0]      mod_right_r_2;
reg   [7 : 0]       pep_judge_r_2;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mod_left_r_2 <= 32'h0;
		mod_right_r_2 <= 32'h0;
		pep_judge_r_2 <= 8'h0;
	end
	else if (pep_ready_r_2 & pep_valid_r_2) begin
		mod_left_r_2 <= mod_left_2;
		mod_right_r_2 <= mod_right_2;
		pep_judge_r_2 <= pep_judge_2;		
	end
	else begin
		mod_left_r_2 <= mod_left_r_2;
		mod_right_r_2 <= mod_right_r_2;
		pep_judge_r_2 <= pep_judge_r_2;	
	end
end
/*added*/


/*---- State Machine design ----*/

always @(posedge clk or posedge rst)
begin
	if(rst) 
		current <= setting;
	else
		current <= next;
end

always @(*)
begin
	case (current)
	setting : begin                       //0
			if(ds_ctrl[17] & spec_store_last)
				next = idling;
			else 
				next = setting;
			end
	idling 	: begin                       //1
	        if (~ds_ctrl[17])
	            next = setting;
			else if(fifo_empty)            
				next = idling;
			else 
				next = prepare;
			end
	prepare : begin                       //2
			if(prepare_done && (|pep_length))
				next = compute;
//			else if(unmatch) begin
//					if (fifo_empty)
//						//next = setting;
//						next = package;
//					else 
//						next = idling;
//				end
            else if(spec_update)
			    next = setting;
			else 
				next = prepare;
			end
	compute : begin                       //3
			if(cmp_done)
				next = pack;
			else
				next = compute;
			end
	pack : begin
			if (submit_done & spec_update_s)
				next = setting;                       //4
			else if (submit_done & spec_update_s_1)
				next = setting;                       
			else if(submit_done & (~fifo_empty))
				next = prepare;
			else if(submit_done_2 & spec_update_s)
                    next = setting;
		//	else if(m_axis_tlast_s)
        //            next = setting;			
		//	else if(submit_done & fifo_empty)
		//		next = idling;
			else 
				next = pack;
			end
	default : next = setting;
	endcase
end

always @(posedge clk or posedge rst)
begin
	if(rst) 
		current_2 <= setting;
	else
		current_2 <= next_2;
end

always @(*)
begin
	case (current_2)
	setting : begin                       //0
			if(ds_ctrl[17] & spec_store_last)
				next_2 = idling;
			else 
				next_2 = setting;
			end
	idling 	: begin                       //1
	        if (~ds_ctrl[17])
	            next_2 = setting;
			else if(fifo_empty)            
				next_2 = idling;
			else 
				next_2 = prepare;
			end
	prepare : begin                       //2
			if(prepare_done_2 && (|pep_length_2))
				next_2 = compute;
//			else if(unmatch) begin
//					if (fifo_empty)
//						//next = setting;
//						next = package;
//					else 
//						next = idling;
//				end
            else if(spec_update)
			    next_2 = setting;
			else 
				next_2 = prepare;
			end
	compute : begin                       //3
			if(cmp_done_2)
				next_2 = pack;
			else
				next_2 = compute;
			end
	pack : begin
			if (submit_done_2 & spec_update_s)
				next_2 = setting;                       //4
			else if (submit_done_2 & spec_update_s_2)
				next_2 = setting;                       
			else if(submit_done_2 & (~fifo_empty))
				next_2 = prepare;
			else if(submit_done & spec_update_s)
			    next_2 = setting;
		//	else if(m_axis_tlast_s)
        //        next_2 = setting;	
		//	else if(submit_done & fifo_empty)
		//		next = idling;
			else 
				next_2 = pack;
			end
	default : next_2 = setting;
	endcase
end


`ifdef    TIME_COUNT

wire      frag_time_en;
wire      dot_time_en;
always @(posedge clk or posedge rst) begin
	if (rst)
		dot_time_reg <= 32'h0;
	else if (cnt_reset)
		dot_time_reg <= 32'h0;
	else if (dot_time_en)
		dot_time_reg <= dot_time_reg + 32'h1; 	
	else 
		dot_time_reg <= dot_time_reg;	
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		frag_time_reg <= 32'h0;
	else if (cnt_reset)
		frag_time_reg <= 32'h0;
	else if (frag_time_en)
		frag_time_reg <= frag_time_reg + 32'h1;
	else 
		frag_time_reg <= frag_time_reg; 
end

`endif

wire	[63 : 0]			ds_x;
wire	[63 : 0]			ds_y;
wire	[63 : 0]			ds_z;
wire	[63 : 0]			ds_a;
wire	[63 : 0]			ds_b;
wire	[63 : 0]			ds_c;

wire	[15 : 0]			match_num_x;
wire    [15 : 0]			match_num_y;
wire	[15 : 0]			match_num_z;
wire    [15 : 0]			match_num_a;
wire	[15 : 0]			match_num_b;
wire    [15 : 0]			match_num_c;

wire 						xt_cmp_done;
wire 						yt_cmp_done;
wire 						zt_cmp_done;
wire 						at_cmp_done;
wire 						bt_cmp_done;
wire 						ct_cmp_done;

wire   [47 : 0]				match_num_0;
wire   [47 : 0]				match_num_1;
wire   [47 : 0]				match_num_2;
wire   [47 : 0]				match_num_3;
wire   [47 : 0]				match_num_4;
wire   [47 : 0]				match_num_5;
wire   [47 : 0]				match_num_6;
wire   [47 : 0]				match_num_7;
wire   [47 : 0]				match_num_8;
wire   [47 : 0]				match_num_9;
wire   [47 : 0]				match_num_10;
wire   [47 : 0]				match_num_11;
wire   [47 : 0]				match_num_12;
wire   [47 : 0]				match_num_13;
wire   [47 : 0]				match_num_14;
wire   [47 : 0]				match_num_15;
wire   [47 : 0]				match_num_16;
wire   [47 : 0]				match_num_17;
wire   [47 : 0]				match_num_18;
wire   [47 : 0]				match_num_19;
wire   [47 : 0]				match_num_20;
wire   [47 : 0]				match_num_21;
wire   [47 : 0]				match_num_22;
wire   [47 : 0]				match_num_23;
wire   [47 : 0]				match_num_24;
wire   [47 : 0]				match_num_25;
wire   [47 : 0]				match_num_26;
wire   [47 : 0]				match_num_27;
wire   [47 : 0]				match_num_28;
wire   [47 : 0]				match_num_29;

wire    					gen_en_x;    
wire 						gen_en_y;
wire    					gen_en_z;
wire    					gen_en_a;
wire    					gen_en_b;
wire    					gen_en_c;

wire	[63 : 0]			ds_x_2;
wire	[63 : 0]			ds_y_2;
wire	[63 : 0]			ds_z_2;
wire	[63 : 0]			ds_a_2;
wire	[63 : 0]			ds_b_2;
wire	[63 : 0]			ds_c_2;

wire	[15 : 0]			match_num_x_2;
wire    [15 : 0]			match_num_y_2;
wire	[15 : 0]			match_num_z_2;
wire    [15 : 0]			match_num_a_2;
wire	[15 : 0]			match_num_b_2;
wire    [15 : 0]			match_num_c_2;

wire 						xt_cmp_done_2;
wire 						yt_cmp_done_2;
wire 						zt_cmp_done_2;
wire 						at_cmp_done_2;
wire 						bt_cmp_done_2;
wire 						ct_cmp_done_2;

wire   [47 : 0]				match_num_0_2;
wire   [47 : 0]				match_num_1_2;
wire   [47 : 0]				match_num_2_2;
wire   [47 : 0]				match_num_3_2;
wire   [47 : 0]				match_num_4_2;
wire   [47 : 0]				match_num_5_2;
wire   [47 : 0]				match_num_6_2;
wire   [47 : 0]				match_num_7_2;
wire   [47 : 0]				match_num_8_2;
wire   [47 : 0]				match_num_9_2;
wire   [47 : 0]				match_num_10_2;
wire   [47 : 0]				match_num_11_2;
wire   [47 : 0]				match_num_12_2;
wire   [47 : 0]				match_num_13_2;
wire   [47 : 0]				match_num_14_2;
wire   [47 : 0]				match_num_15_2;
wire   [47 : 0]				match_num_16_2;
wire   [47 : 0]				match_num_17_2;
wire   [47 : 0]				match_num_18_2;
wire   [47 : 0]				match_num_19_2;
wire   [47 : 0]				match_num_20_2;
wire   [47 : 0]				match_num_21_2;
wire   [47 : 0]				match_num_22_2;
wire   [47 : 0]				match_num_23_2;
wire   [47 : 0]				match_num_24_2;
wire   [47 : 0]				match_num_25_2;
wire   [47 : 0]				match_num_26_2;
wire   [47 : 0]				match_num_27_2;
wire   [47 : 0]				match_num_28_2;
wire   [47 : 0]				match_num_29_2;

wire    					gen_en_x_2;    
wire 						gen_en_y_2;
wire    					gen_en_z_2;
wire    					gen_en_a_2;
wire    					gen_en_b_2;
wire    					gen_en_c_2;

assign  	gen_en_x = ds_ctrl[8] & (current > setting);
assign 		gen_en_y = ds_ctrl[7] & (current > setting);
assign  	gen_en_z = ds_ctrl[6] & (current > setting);
assign 		gen_en_a = ds_ctrl[11] & (current > setting);
assign 		gen_en_b = ds_ctrl[10] & (current > setting);
assign 		gen_en_c = ds_ctrl[9] & (current > setting);

assign  	gen_en_x_2 = ds_ctrl[8] & (current_2 > setting);
assign 		gen_en_y_2 = ds_ctrl[7] & (current_2 > setting);
assign  	gen_en_z_2 = ds_ctrl[6] & (current_2 > setting);
assign 		gen_en_a_2 = ds_ctrl[11] & (current_2 > setting);
assign 		gen_en_b_2 = ds_ctrl[10] & (current_2 > setting);
assign 		gen_en_c_2 = ds_ctrl[9] & (current_2 > setting);

/*-------------- x type --------------*/

ds_x_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`X_TYPE),
	.RESULT_WID (64)	
)
ds_x_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_x),
	.ds_done 		(ds_rst),
	.start 			(prepare_done),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r),		
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_x),
	.pep_data 		(pep_bram_data_x),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_x),
	.spec_mz_data 	(data_mz_out_3),
	.spec_i_data 	(data_i_out_3),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_x_cb),
	.para_data      (rd_data_x_cb),

/*------------ result output ----------------*/

	.ds_x 			(ds_x),
	.match_num_x 	(match_num_x),
	.match_num0 	(match_num_0[23 : 16]),
    .match_num1     (match_num_1[23 : 16]),
    .match_num2     (match_num_2[23 : 16]),
    .match_num3     (match_num_3[23 : 16]),
    .match_num4     (match_num_4[23 : 16]),    
    .match_num5     (match_num_5[23 : 16]),
    .match_num6     (match_num_6[23 : 16]),
    .match_num7     (match_num_7[23 : 16]),
    .match_num8     (match_num_8[23 : 16]),
    .match_num9     (match_num_9[23 : 16]),    
    .match_num10    (match_num_10[23 : 16]),
    .match_num11    (match_num_11[23 : 16]),
    .match_num12    (match_num_12[23 : 16]),
    .match_num13    (match_num_13[23 : 16]),
    .match_num14    (match_num_14[23 : 16]),    
    .match_num15    (match_num_15[23 : 16]),    
    .match_num16    (match_num_16[23 : 16]),
    .match_num17    (match_num_17[23 : 16]),
    .match_num18    (match_num_18[23 : 16]),
    .match_num19    (match_num_19[23 : 16]),    
    .match_num20    (match_num_20[23 : 16]),    
    .match_num21    (match_num_21[23 : 16]),
    .match_num22    (match_num_22[23 : 16]),
    .match_num23    (match_num_23[23 : 16]),
    .match_num24    (match_num_24[23 : 16]),    
    .match_num25    (match_num_25[23 : 16]),    
    .match_num26    (match_num_26[23 : 16]),
    .match_num27    (match_num_27[23 : 16]),
    .match_num28    (match_num_28[23 : 16]),
    .match_num29    (match_num_29[23 : 16]),	

	.xt_cmp_done 	(xt_cmp_done),
	.ds_blocked     (ds_blocked)
);

ds_y_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`Y_TYPE),
	.RESULT_WID (64)	
)
ds_y_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_y),

	.ds_done 		(ds_rst),
	.start 			(prepare_done),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r),		// slv_reg12
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.pep_read_addr 	(pep_read_addr_y),
	.pep_data 		(pep_bram_data_y),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_y),
	.spec_mz_data 	(data_mz_out_4),
	.spec_i_data 	(data_i_out_4),   
	.spec_len 		(spec_length),
	.spec_bram_addr_1 	(spec_read_addr_y_1),
	.spec_mz_data_1		(data_mz_out_4_1),
	.spec_i_data_1		(data_i_out_4_1), 

	.para_addr          (rd_addr_y_cb),
	.para_data          (rd_data_y_cb),
/*------------ result output ----------------*/

	.ds_y 			(ds_y),
	.match_num_y	(match_num_y),
	.match_num0 	(match_num_0[15 : 8]),
	.match_num1		(match_num_1[15 : 8]),
	.match_num2		(match_num_2[15 : 8]),
	.match_num3		(match_num_3[15 : 8]),
	.match_num4		(match_num_4[15 : 8]),	
	.match_num5		(match_num_5[15 : 8]),
	.match_num6		(match_num_6[15 : 8]),
	.match_num7		(match_num_7[15 : 8]),
	.match_num8		(match_num_8[15 : 8]),
	.match_num9		(match_num_9[15 : 8]),	
	.match_num10	(match_num_10[15 : 8]),
	.match_num11	(match_num_11[15 : 8]),
	.match_num12	(match_num_12[15 : 8]),
	.match_num13	(match_num_13[15 : 8]),
	.match_num14	(match_num_14[15 : 8]),	
	.match_num15	(match_num_15[15 : 8]),	
	.match_num16	(match_num_16[15 : 8]),
	.match_num17	(match_num_17[15 : 8]),
	.match_num18	(match_num_18[15 : 8]),
	.match_num19	(match_num_19[15 : 8]),	
	.match_num20	(match_num_20[15 : 8]),	
	.match_num21	(match_num_21[15 : 8]),
	.match_num22	(match_num_22[15 : 8]),
	.match_num23	(match_num_23[15 : 8]),
	.match_num24	(match_num_24[15 : 8]),	
	.match_num25	(match_num_25[15 : 8]),	
	.match_num26	(match_num_26[15 : 8]),
	.match_num27	(match_num_27[15 : 8]),
	.match_num28	(match_num_28[15 : 8]),
	.match_num29	(match_num_29[15 : 8]),	

`ifdef TIME_COUNT
	.dot_time_en    (dot_time_en),
	.frag_time_en   (frag_time_en),
`endif

	.yt_cmp_done 	(yt_cmp_done),
	.ds_blocked     (ds_blocked)
);

ds_z_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`Z_TYPE),
	.RESULT_WID (64)	
)
ds_z_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_z),
	.ds_done 		(ds_rst),
	.start 			(prepare_done),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r),		// slv_reg12
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_z),
	.pep_data 		(pep_bram_data_z),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_z),
	.spec_mz_data 	(data_mz_out_5),
	.spec_i_data 	(data_i_out_5),   
	.spec_len 		(spec_length),

	.para_addr          (rd_addr_z_cb),
	.para_data          (rd_data_z_cb),	

/*------------ result output ----------------*/

	.ds_z 			(ds_z),
	.match_num_z	(match_num_z),
	.match_num0 	(match_num_0[7 : 0]),
	.match_num1		(match_num_1[7 : 0]),
	.match_num2		(match_num_2[7 : 0]),
	.match_num3		(match_num_3[7 : 0]),
	.match_num4		(match_num_4[7 : 0]),	
	.match_num5		(match_num_5[7 : 0]),
	.match_num6		(match_num_6[7 : 0]),
	.match_num7		(match_num_7[7 : 0]),
	.match_num8		(match_num_8[7 : 0]),
	.match_num9		(match_num_9[7 : 0]),	
	.match_num10	(match_num_10[7 : 0]),
	.match_num11	(match_num_11[7 : 0]),
	.match_num12	(match_num_12[7 : 0]),
	.match_num13	(match_num_13[7 : 0]),
	.match_num14	(match_num_14[7 : 0]),	
	.match_num15	(match_num_15[7 : 0]),	
	.match_num16	(match_num_16[7 : 0]),
	.match_num17	(match_num_17[7 : 0]),
	.match_num18	(match_num_18[7 : 0]),
	.match_num19	(match_num_19[7 : 0]),	
	.match_num20	(match_num_20[7 : 0]),	
	.match_num21	(match_num_21[7 : 0]),
	.match_num22	(match_num_22[7 : 0]),
	.match_num23	(match_num_23[7 : 0]),
	.match_num24	(match_num_24[7 : 0]),	
	.match_num25	(match_num_25[7 : 0]),	
	.match_num26	(match_num_26[7 : 0]),
	.match_num27	(match_num_27[7 : 0]),
	.match_num28	(match_num_28[7 : 0]),
	.match_num29	(match_num_29[7 : 0]),	

	.zt_cmp_done 	(zt_cmp_done),
	.ds_blocked     (ds_blocked)
);

ds_a_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`A_TYPE),
	.RESULT_WID (64)	
)
ds_a_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_a),
	.ds_done 		(ds_rst),
	.start 			(prepare_done),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_a),
	.pep_data 		(pep_bram_data_a),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_a),
	.spec_mz_data 	(data_mz_out_0),
	.spec_i_data 	(data_i_out_0),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_a_cb),
	.para_data      (rd_data_a_cb),	

/*------------ result output ----------------*/

	.ds_a 			(ds_a),
	.match_num_a 	(match_num_a),
	.match_num0 	(match_num_0[47 : 40]),
	.match_num1		(match_num_1[47 : 40]),
	.match_num2		(match_num_2[47 : 40]),
	.match_num3		(match_num_3[47 : 40]),
	.match_num4		(match_num_4[47 : 40]),	
	.match_num5		(match_num_5[47 : 40]),
	.match_num6		(match_num_6[47 : 40]),
	.match_num7		(match_num_7[47 : 40]),
	.match_num8		(match_num_8[47 : 40]),
	.match_num9		(match_num_9[47 : 40]),	
	.match_num10	(match_num_10[47 : 40]),
	.match_num11	(match_num_11[47 : 40]),
	.match_num12	(match_num_12[47 : 40]),
	.match_num13	(match_num_13[47 : 40]),
	.match_num14	(match_num_14[47 : 40]),	
	.match_num15	(match_num_15[47 : 40]),	
	.match_num16	(match_num_16[47 : 40]),
	.match_num17	(match_num_17[47 : 40]),
	.match_num18	(match_num_18[47 : 40]),
	.match_num19	(match_num_19[47 : 40]),	
	.match_num20	(match_num_20[47 : 40]),	
	.match_num21	(match_num_21[47 : 40]),
	.match_num22	(match_num_22[47 : 40]),
	.match_num23	(match_num_23[47 : 40]),
	.match_num24	(match_num_24[47 : 40]),	
	.match_num25	(match_num_25[47 : 40]),	
	.match_num26	(match_num_26[47 : 40]),
	.match_num27	(match_num_27[47 : 40]),
	.match_num28	(match_num_28[47 : 40]),
	.match_num29	(match_num_29[47 : 40]),	

	.at_cmp_done 	(at_cmp_done),
	.ds_blocked     (ds_blocked)
);

ds_b_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`B_TYPE),
	.RESULT_WID (64)	
)
ds_b_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_b),
	//.store_done 	(prepare_done),
	.ds_done 		(ds_rst),
	.start 			(prepare_done),
//	.parent_mass_match (),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.pep_read_addr 	(pep_read_addr_b),
	.pep_data 		(pep_bram_data_b),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_b),
	.spec_mz_data 	(data_mz_out_1),
	.spec_i_data 	(data_i_out_1),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_b_cb),
	.para_data      (rd_data_b_cb),

/*------------ result output ----------------*/

	.ds_b 			(ds_b),
	.match_num_b 	(match_num_b),
	.match_num0 	(match_num_0[39 : 32]),
	.match_num1		(match_num_1[39 : 32]),
	.match_num2		(match_num_2[39 : 32]),
	.match_num3		(match_num_3[39 : 32]),
	.match_num4		(match_num_4[39 : 32]),	
	.match_num5		(match_num_5[39 : 32]),
	.match_num6		(match_num_6[39 : 32]),
	.match_num7		(match_num_7[39 : 32]),
	.match_num8		(match_num_8[39 : 32]),
	.match_num9		(match_num_9[39 : 32]),	
	.match_num10	(match_num_10[39 : 32]),
	.match_num11	(match_num_11[39 : 32]),
	.match_num12	(match_num_12[39 : 32]),
	.match_num13	(match_num_13[39 : 32]),
	.match_num14	(match_num_14[39 : 32]),	
	.match_num15	(match_num_15[39 : 32]),	
	.match_num16	(match_num_16[39 : 32]),
	.match_num17	(match_num_17[39 : 32]),
	.match_num18	(match_num_18[39 : 32]),
	.match_num19	(match_num_19[39 : 32]),	
	.match_num20	(match_num_20[39 : 32]),	
	.match_num21	(match_num_21[39 : 32]),
	.match_num22	(match_num_22[39 : 32]),
	.match_num23	(match_num_23[39 : 32]),
	.match_num24	(match_num_24[39 : 32]),	
	.match_num25	(match_num_25[39 : 32]),	
	.match_num26	(match_num_26[39 : 32]),
	.match_num27	(match_num_27[39 : 32]),
	.match_num28	(match_num_28[39 : 32]),
	.match_num29	(match_num_29[39 : 32]),	

	.bt_cmp_done 	(bt_cmp_done),
	.ds_blocked     (ds_blocked)
);


ds_c_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`B_TYPE),
	.RESULT_WID (64)	
)
ds_c_type_core_i(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_c),
	//.store_done 	(prepare_done),
	.ds_done 		(ds_rst),
	.start 			(prepare_done),
//	.parent_mass_match (),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_c),
	.pep_data 		(pep_bram_data_c),  
	.pep_len 		(pep_length), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_c),
	.spec_mz_data 	(data_mz_out_2),
	.spec_i_data 	(data_i_out_2),   
	.spec_len 		(spec_length),

	.para_addr          (rd_addr_c_cb),
	.para_data          (rd_data_c_cb),

/*------------ result output ----------------*/

	.ds_c 			(ds_c),
	.match_num_c 	(match_num_c),
	.match_num0 	(match_num_0[31 : 24]),
	.match_num1		(match_num_1[31 : 24]),
	.match_num2		(match_num_2[31 : 24]),
	.match_num3		(match_num_3[31 : 24]),
	.match_num4		(match_num_4[31 : 24]),	
	.match_num5		(match_num_5[31 : 24]),
	.match_num6		(match_num_6[31 : 24]),
	.match_num7		(match_num_7[31 : 24]),
	.match_num8		(match_num_8[31 : 24]),
	.match_num9		(match_num_9[31 : 24]),	
	.match_num10	(match_num_10[31 : 24]),
	.match_num11	(match_num_11[31 : 24]),
	.match_num12	(match_num_12[31 : 24]),
	.match_num13	(match_num_13[31 : 24]),
	.match_num14	(match_num_14[31 : 24]),	
	.match_num15	(match_num_15[31 : 24]),	
	.match_num16	(match_num_16[31 : 24]),
	.match_num17	(match_num_17[31 : 24]),
	.match_num18	(match_num_18[31 : 24]),
	.match_num19	(match_num_19[31 : 24]),	
	.match_num20	(match_num_20[31 : 24]),	
	.match_num21	(match_num_21[31 : 24]),
	.match_num22	(match_num_22[31 : 24]),
	.match_num23	(match_num_23[31 : 24]),
	.match_num24	(match_num_24[31 : 24]),	
	.match_num25	(match_num_25[31 : 24]),	
	.match_num26	(match_num_26[31 : 24]),
	.match_num27	(match_num_27[31 : 24]),
	.match_num28	(match_num_28[31 : 24]),
	.match_num29	(match_num_29[31 : 24]),	

	.ct_cmp_done 	(ct_cmp_done),
	.ds_blocked     (ds_blocked)
);

/*added*/
/*-------------- x type --------------*/

ds_x_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`X_TYPE),
	.RESULT_WID (64)	
)
ds_x_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_x_2),
	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r_2),		
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_x_2),
	.pep_data 		(pep_bram_data_x_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_x_2),
	.spec_mz_data 	(data_mz_out_3_2),
	.spec_i_data 	(data_i_out_3_2),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_x_cb_2),
	.para_data      (rd_data_x_cb_2),

/*------------ result output ----------------*/

	.ds_x 			(ds_x_2),
	.match_num_x 	(match_num_x_2),
	.match_num0 	(match_num_0_2[23 : 16]),
    .match_num1     (match_num_1_2[23 : 16]),
    .match_num2     (match_num_2_2[23 : 16]),
    .match_num3     (match_num_3_2[23 : 16]),
    .match_num4     (match_num_4_2[23 : 16]),    
    .match_num5     (match_num_5_2[23 : 16]),
    .match_num6     (match_num_6_2[23 : 16]),
    .match_num7     (match_num_7_2[23 : 16]),
    .match_num8     (match_num_8_2[23 : 16]),
    .match_num9     (match_num_9_2[23 : 16]),    
    .match_num10    (match_num_10_2[23 : 16]),
    .match_num11    (match_num_11_2[23 : 16]),
    .match_num12    (match_num_12_2[23 : 16]),
    .match_num13    (match_num_13_2[23 : 16]),
    .match_num14    (match_num_14_2[23 : 16]),    
    .match_num15    (match_num_15_2[23 : 16]),    
    .match_num16    (match_num_16_2[23 : 16]),
    .match_num17    (match_num_17_2[23 : 16]),
    .match_num18    (match_num_18_2[23 : 16]),
    .match_num19    (match_num_19_2[23 : 16]),    
    .match_num20    (match_num_20_2[23 : 16]),    
    .match_num21    (match_num_21_2[23 : 16]),
    .match_num22    (match_num_22_2[23 : 16]),
    .match_num23    (match_num_23_2[23 : 16]),
    .match_num24    (match_num_24_2[23 : 16]),    
    .match_num25    (match_num_25_2[23 : 16]),    
    .match_num26    (match_num_26_2[23 : 16]),
    .match_num27    (match_num_27_2[23 : 16]),
    .match_num28    (match_num_28_2[23 : 16]),
    .match_num29    (match_num_29_2[23 : 16]),	

	.xt_cmp_done 	(xt_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);

ds_y_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`Y_TYPE),
	.RESULT_WID (64)	
)
ds_y_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_y_2),

	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r_2),		
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.pep_read_addr 	(pep_read_addr_y_2),
	.pep_data 		(pep_bram_data_y_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_y_2),
	.spec_mz_data 	(data_mz_out_4_2),
	.spec_i_data 	(data_i_out_4_2),   
	.spec_len 		(spec_length),
	.spec_bram_addr_1 	(spec_read_addr_y_1_2),
	.spec_mz_data_1		(data_mz_out_4_1_2),
	.spec_i_data_1		(data_i_out_4_1_2), 

	.para_addr          (rd_addr_y_cb_2),
	.para_data          (rd_data_y_cb_2),

/*------------ result output ----------------*/

	.ds_y 			(ds_y_2),
	.match_num_y	(match_num_y_2),
	.match_num0 	(match_num_0_2[15 : 8]),
	.match_num1		(match_num_1_2[15 : 8]),
	.match_num2		(match_num_2_2[15 : 8]),
	.match_num3		(match_num_3_2[15 : 8]),
	.match_num4		(match_num_4_2[15 : 8]),	
	.match_num5		(match_num_5_2[15 : 8]),
	.match_num6		(match_num_6_2[15 : 8]),
	.match_num7		(match_num_7_2[15 : 8]),
	.match_num8		(match_num_8_2[15 : 8]),
	.match_num9		(match_num_9_2[15 : 8]),	
	.match_num10	(match_num_10_2[15 : 8]),
	.match_num11	(match_num_11_2[15 : 8]),
	.match_num12	(match_num_12_2[15 : 8]),
	.match_num13	(match_num_13_2[15 : 8]),
	.match_num14	(match_num_14_2[15 : 8]),	
	.match_num15	(match_num_15_2[15 : 8]),	
	.match_num16	(match_num_16_2[15 : 8]),
	.match_num17	(match_num_17_2[15 : 8]),
	.match_num18	(match_num_18_2[15 : 8]),
	.match_num19	(match_num_19_2[15 : 8]),	
	.match_num20	(match_num_20_2[15 : 8]),	
	.match_num21	(match_num_21_2[15 : 8]),
	.match_num22	(match_num_22_2[15 : 8]),
	.match_num23	(match_num_23_2[15 : 8]),
	.match_num24	(match_num_24_2[15 : 8]),	
	.match_num25	(match_num_25_2[15 : 8]),	
	.match_num26	(match_num_26_2[15 : 8]),
	.match_num27	(match_num_27_2[15 : 8]),
	.match_num28	(match_num_28_2[15 : 8]),
	.match_num29	(match_num_29_2[15 : 8]),	

	.yt_cmp_done 	(yt_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);

ds_z_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`Z_TYPE),
	.RESULT_WID (64)	
)
ds_z_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_z_2),
	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),

	.ds_ctrl  		(ds_ctrl),
	.m_ct 			(m_ct),			// slv_reg2
	.m_cleave_c 	(m_cleave_c),		// slv_reg4
	.WOE 			(woe),            // slv_reg5
	.mod_right 		(mod_right_r_2),		
	.fullmod_right 	(fullmod_right), 	// slv_reg41
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_z_2),
	.pep_data 		(pep_bram_data_z_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_z_2),
	.spec_mz_data 	(data_mz_out_5_2),
	.spec_i_data 	(data_i_out_5_2),   
	.spec_len 		(spec_length),

	.para_addr          (rd_addr_z_cb_2),
	.para_data          (rd_data_z_cb_2),	

/*------------ result output ----------------*/

	.ds_z 			(ds_z_2),
	.match_num_z	(match_num_z_2),
	.match_num0 	(match_num_0_2[7 : 0]),
	.match_num1		(match_num_1_2[7 : 0]),
	.match_num2		(match_num_2_2[7 : 0]),
	.match_num3		(match_num_3_2[7 : 0]),
	.match_num4		(match_num_4_2[7 : 0]),	
	.match_num5		(match_num_5_2[7 : 0]),
	.match_num6		(match_num_6_2[7 : 0]),
	.match_num7		(match_num_7_2[7 : 0]),
	.match_num8		(match_num_8_2[7 : 0]),
	.match_num9		(match_num_9_2[7 : 0]),	
	.match_num10	(match_num_10_2[7 : 0]),
	.match_num11	(match_num_11_2[7 : 0]),
	.match_num12	(match_num_12_2[7 : 0]),
	.match_num13	(match_num_13_2[7 : 0]),
	.match_num14	(match_num_14_2[7 : 0]),	
	.match_num15	(match_num_15_2[7 : 0]),	
	.match_num16	(match_num_16_2[7 : 0]),
	.match_num17	(match_num_17_2[7 : 0]),
	.match_num18	(match_num_18_2[7 : 0]),
	.match_num19	(match_num_19_2[7 : 0]),	
	.match_num20	(match_num_20_2[7 : 0]),	
	.match_num21	(match_num_21_2[7 : 0]),
	.match_num22	(match_num_22_2[7 : 0]),
	.match_num23	(match_num_23_2[7 : 0]),
	.match_num24	(match_num_24_2[7 : 0]),	
	.match_num25	(match_num_25_2[7 : 0]),	
	.match_num26	(match_num_26_2[7 : 0]),
	.match_num27	(match_num_27_2[7 : 0]),
	.match_num28	(match_num_28_2[7 : 0]),
	.match_num29	(match_num_29_2[7 : 0]),	

	.zt_cmp_done 	(zt_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);

ds_a_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`A_TYPE),
	.RESULT_WID (64)	
)
ds_a_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_a_2),
	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r_2),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_a_2),
	.pep_data 		(pep_bram_data_a_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_a_2),
	.spec_mz_data 	(data_mz_out_0_2),
	.spec_i_data 	(data_i_out_0_2),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_a_cb_2),
	.para_data      (rd_data_a_cb_2),	

/*------------ result output ----------------*/

	.ds_a 			(ds_a_2),
	.match_num_a 	(match_num_a_2),
	.match_num0 	(match_num_0_2[47 : 40]),
	.match_num1		(match_num_1_2[47 : 40]),
	.match_num2		(match_num_2_2[47 : 40]),
	.match_num3		(match_num_3_2[47 : 40]),
	.match_num4		(match_num_4_2[47 : 40]),	
	.match_num5		(match_num_5_2[47 : 40]),
	.match_num6		(match_num_6_2[47 : 40]),
	.match_num7		(match_num_7_2[47 : 40]),
	.match_num8		(match_num_8_2[47 : 40]),
	.match_num9		(match_num_9_2[47 : 40]),	
	.match_num10	(match_num_10_2[47 : 40]),
	.match_num11	(match_num_11_2[47 : 40]),
	.match_num12	(match_num_12_2[47 : 40]),
	.match_num13	(match_num_13_2[47 : 40]),
	.match_num14	(match_num_14_2[47 : 40]),	
	.match_num15	(match_num_15_2[47 : 40]),	
	.match_num16	(match_num_16_2[47 : 40]),
	.match_num17	(match_num_17_2[47 : 40]),
	.match_num18	(match_num_18_2[47 : 40]),
	.match_num19	(match_num_19_2[47 : 40]),	
	.match_num20	(match_num_20_2[47 : 40]),	
	.match_num21	(match_num_21_2[47 : 40]),
	.match_num22	(match_num_22_2[47 : 40]),
	.match_num23	(match_num_23_2[47 : 40]),
	.match_num24	(match_num_24_2[47 : 40]),	
	.match_num25	(match_num_25_2[47 : 40]),	
	.match_num26	(match_num_26_2[47 : 40]),
	.match_num27	(match_num_27_2[47 : 40]),
	.match_num28	(match_num_28_2[47 : 40]),
	.match_num29	(match_num_29_2[47 : 40]),	

	.at_cmp_done 	(at_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);

ds_b_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`B_TYPE),
	.RESULT_WID (64)	
)
ds_b_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_b_2),
	//.store_done 	(prepare_done),
	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),
//	.parent_mass_match (),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r_2),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.pep_read_addr 	(pep_read_addr_b_2),
	.pep_data 		(pep_bram_data_b_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_b_2),
	.spec_mz_data 	(data_mz_out_1_2),
	.spec_i_data 	(data_i_out_1_2),   
	.spec_len 		(spec_length),

	.para_addr      (rd_addr_b_cb_2),
	.para_data      (rd_data_b_cb_2),
	

/*------------ result output ----------------*/

	.ds_b 			(ds_b_2),
	.match_num_b 	(match_num_b_2),
	.match_num0 	(match_num_0_2[39 : 32]),
	.match_num1		(match_num_1_2[39 : 32]),
	.match_num2		(match_num_2_2[39 : 32]),
	.match_num3		(match_num_3_2[39 : 32]),
	.match_num4		(match_num_4_2[39 : 32]),	
	.match_num5		(match_num_5_2[39 : 32]),
	.match_num6		(match_num_6_2[39 : 32]),
	.match_num7		(match_num_7_2[39 : 32]),
	.match_num8		(match_num_8_2[39 : 32]),
	.match_num9		(match_num_9_2[39 : 32]),	
	.match_num10	(match_num_10_2[39 : 32]),
	.match_num11	(match_num_11_2[39 : 32]),
	.match_num12	(match_num_12_2[39 : 32]),
	.match_num13	(match_num_13_2[39 : 32]),
	.match_num14	(match_num_14_2[39 : 32]),	
	.match_num15	(match_num_15_2[39 : 32]),	
	.match_num16	(match_num_16_2[39 : 32]),
	.match_num17	(match_num_17_2[39 : 32]),
	.match_num18	(match_num_18_2[39 : 32]),
	.match_num19	(match_num_19_2[39 : 32]),	
	.match_num20	(match_num_20_2[39 : 32]),	
	.match_num21	(match_num_21_2[39 : 32]),
	.match_num22	(match_num_22_2[39 : 32]),
	.match_num23	(match_num_23_2[39 : 32]),
	.match_num24	(match_num_24_2[39 : 32]),	
	.match_num25	(match_num_25_2[39 : 32]),	
	.match_num26	(match_num_26_2[39 : 32]),
	.match_num27	(match_num_27_2[39 : 32]),
	.match_num28	(match_num_28_2[39 : 32]),
	.match_num29	(match_num_29_2[39 : 32]),	

	.bt_cmp_done 	(bt_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);


ds_c_type_core #
(
	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.FRAG_TYPE	(`B_TYPE),
	.RESULT_WID (64)	
)
ds_c_type_core_i_2(
	.clk	 		(clk),
	.rst 			(rst),
	.gen_en 		(gen_en_c_2),
	//.store_done 	(prepare_done),
	.ds_done 		(ds_rst_2),
	.start 			(prepare_done_2),
//	.parent_mass_match (),

	.ds_ctrl  		(ds_ctrl),
	.m_nt 			(m_nt),			
	.m_cleave_n 	(m_cleave_n),		
	.WOE 			(woe),           
	.mod_left 		(mod_left_r_2),		
	.fullmod_left 	(fullmod_left), 	
    .pep_judge      (pep_judge_r_2[3:0]),
	.z_charge 		(spec_z_charge_r),

/* ------------- input pep data ------------- */
	.read_addr 		(pep_read_addr_c_2),
	.pep_data 		(pep_bram_data_c_2),  
	.pep_len 		(pep_length_2), 


/* ------------- input spec data ------------ */
	.spec_bram_addr (spec_read_addr_c_2),
	.spec_mz_data 	(data_mz_out_2_2),
	.spec_i_data 	(data_i_out_2_2),   
	.spec_len 		(spec_length),

	.para_addr          (rd_addr_c_cb_2),
	.para_data          (rd_data_c_cb_2),

/*------------ result output ----------------*/

	.ds_c 			(ds_c_2),
	.match_num_c 	(match_num_c_2),
	.match_num0 	(match_num_0_2[31 : 24]),
	.match_num1		(match_num_1_2[31 : 24]),
	.match_num2		(match_num_2_2[31 : 24]),
	.match_num3		(match_num_3_2[31 : 24]),
	.match_num4		(match_num_4_2[31 : 24]),	
	.match_num5		(match_num_5_2[31 : 24]),
	.match_num6		(match_num_6_2[31 : 24]),
	.match_num7		(match_num_7_2[31 : 24]),
	.match_num8		(match_num_8_2[31 : 24]),
	.match_num9		(match_num_9_2[31 : 24]),	
	.match_num10	(match_num_10_2[31 : 24]),
	.match_num11	(match_num_11_2[31 : 24]),
	.match_num12	(match_num_12_2[31 : 24]),
	.match_num13	(match_num_13_2[31 : 24]),
	.match_num14	(match_num_14_2[31 : 24]),	
	.match_num15	(match_num_15_2[31 : 24]),	
	.match_num16	(match_num_16_2[31 : 24]),
	.match_num17	(match_num_17_2[31 : 24]),
	.match_num18	(match_num_18_2[31 : 24]),
	.match_num19	(match_num_19_2[31 : 24]),	
	.match_num20	(match_num_20_2[31 : 24]),	
	.match_num21	(match_num_21_2[31 : 24]),
	.match_num22	(match_num_22_2[31 : 24]),
	.match_num23	(match_num_23_2[31 : 24]),
	.match_num24	(match_num_24_2[31 : 24]),	
	.match_num25	(match_num_25_2[31 : 24]),	
	.match_num26	(match_num_26_2[31 : 24]),
	.match_num27	(match_num_27_2[31 : 24]),
	.match_num28	(match_num_28_2[31 : 24]),
	.match_num29	(match_num_29_2[31 : 24]),	

	.ct_cmp_done 	(ct_cmp_done_2),
	.ds_blocked     (ds_blocked_2)
);
/*added*/

reg     at_cmp_done_q;
reg     bt_cmp_done_q;
reg     ct_cmp_done_q;
reg     xt_cmp_done_q;
reg     yt_cmp_done_q;
reg     zt_cmp_done_q;

reg     at_cmp_done_q_2;
reg     bt_cmp_done_q_2;
reg     ct_cmp_done_q_2;
reg     xt_cmp_done_q_2;
reg     yt_cmp_done_q_2;
reg     zt_cmp_done_q_2;

always @(posedge clk or posedge rst) begin
	if (rst) 
		at_cmp_done_q <= 1'b0;
	else if (at_cmp_done)
		at_cmp_done_q <= 1'b1;
	else if (cmp_done)
		at_cmp_done_q <= 1'b0;
	else 
		at_cmp_done_q <= at_cmp_done_q; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		bt_cmp_done_q <= 1'b0;
	else if (bt_cmp_done)
		bt_cmp_done_q <= 1'b1;
	else if (cmp_done)
		bt_cmp_done_q <= 1'b0;
	else 
		bt_cmp_done_q <= bt_cmp_done_q; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		ct_cmp_done_q <= 1'b0;
	else if (ct_cmp_done)
		ct_cmp_done_q <= 1'b1;
	else if (cmp_done)
		ct_cmp_done_q <= 1'b0;
	else 
		ct_cmp_done_q <= ct_cmp_done_q; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		xt_cmp_done_q <= 1'b0;
	else if (xt_cmp_done)
		xt_cmp_done_q <= 1'b1;
	else if (cmp_done)
		xt_cmp_done_q <= 1'b0;
	else 
		xt_cmp_done_q <= xt_cmp_done_q; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		yt_cmp_done_q <= 1'b0;
	else if (yt_cmp_done)
		yt_cmp_done_q <= 1'b1;
	else if (cmp_done)
		yt_cmp_done_q <= 1'b0;
	else 
		yt_cmp_done_q <= yt_cmp_done_q; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		zt_cmp_done_q <= 1'b0;
	else if (zt_cmp_done)
		zt_cmp_done_q <= 1'b1;
	else if (cmp_done)
		zt_cmp_done_q <= 1'b0;
	else 
		zt_cmp_done_q <= zt_cmp_done_q; 
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		at_cmp_done_q_2 <= 1'b0;
	else if (at_cmp_done_2)
		at_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		at_cmp_done_q_2 <= 1'b0;
	else 
		at_cmp_done_q_2 <= at_cmp_done_q_2; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		bt_cmp_done_q_2 <= 1'b0;
	else if (bt_cmp_done_2)
		bt_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		bt_cmp_done_q_2 <= 1'b0;
	else 
		bt_cmp_done_q_2 <= bt_cmp_done_q_2; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		ct_cmp_done_q_2 <= 1'b0;
	else if (ct_cmp_done_2)
		ct_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		ct_cmp_done_q_2 <= 1'b0;
	else 
		ct_cmp_done_q_2 <= ct_cmp_done_q_2; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		xt_cmp_done_q_2 <= 1'b0;
	else if (xt_cmp_done_2)
		xt_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		xt_cmp_done_q_2 <= 1'b0;
	else 
		xt_cmp_done_q_2 <= xt_cmp_done_q_2; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		yt_cmp_done_q_2 <= 1'b0;
	else if (yt_cmp_done_2)
		yt_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		yt_cmp_done_q_2<= 1'b0;
	else 
		yt_cmp_done_q_2 <= yt_cmp_done_q_2; 
end
always @(posedge clk or posedge rst) begin
	if (rst) 
		zt_cmp_done_q_2 <= 1'b0;
	else if (zt_cmp_done_2)
		zt_cmp_done_q_2 <= 1'b1;
	else if (cmp_done_2)
		zt_cmp_done_q_2 <= 1'b0;
	else 
		zt_cmp_done_q_2 <= zt_cmp_done_q_2; 
end

assign   cmp_done = (current == compute) & ((ds_ctrl[11 : 6] & { at_cmp_done_q, bt_cmp_done_q, ct_cmp_done_q, xt_cmp_done_q, yt_cmp_done_q, zt_cmp_done_q}) == ds_ctrl[11 : 6]);
assign   cmp_done_2 = (current_2 == compute) & ((ds_ctrl[11 : 6] & { at_cmp_done_q_2, bt_cmp_done_q_2, ct_cmp_done_q_2, xt_cmp_done_q_2, yt_cmp_done_q_2, zt_cmp_done_q_2}) == ds_ctrl[11 : 6]);


always @(posedge clk or posedge rst) begin
	if (rst)
		ds_rst <= 1'b0;
	else if ((current == compute) && cmp_done)
		ds_rst <= 1'b1;
	else 
		ds_rst <= 1'b0;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		ds_rst_2 <= 1'b0;
	else if ((current_2 == compute) && cmp_done_2)
		ds_rst_2 <= 1'b1;
	else 
		ds_rst_2 <= 1'b0;
end

/*------------- package the frame ----------------*/

wire [63 : 0]   ds_total;
assign ds_total = (current == pack) ? (ds_a + ds_b + ds_c + ds_x + ds_y + ds_z) : 64'h0;

wire [63 : 0]   ds_total_2;
assign ds_total_2 = (current_2 == pack) ? (ds_a_2 + ds_b_2 + ds_c_2 + ds_x_2 + ds_y_2 + ds_z_2) : 64'h0;

//reg  [4 : 0]        
//assign  spec_update = fifo_empty & (unmatch | ds_rst); 
reg    [1 : 0]      package_en;
wire   package_done;  
reg    [1 : 0]      package_en_2;
wire   package_done_2;  

always @(posedge clk or posedge rst) begin
 	if (rst) 
 		package_en <= 2'b00;
	else if (fifo_empty & ds_rst & (ds_total == 64'h0) & ds_rst_2 & (ds_total_2 == 64'h0) & (pep_under_process == 2'b10))   
 		package_en <= 2'b01;
 	else if (fifo_empty & ds_rst & (ds_total != 64'h0) & (pep_under_process == 2'b10))                              // send data package  
 		package_en <= 2'b10;
 	else if (fifo_empty & ds_rst & (ds_total == 64'h0) & (pep_under_process == 2'b01))   // send an empty package
 		package_en <= 2'b01;
 	else if (fifo_empty & ds_rst & (ds_total != 64'h0) & (pep_under_process == 2'b01))                              // send data and empty flag package  
 		package_en <= 2'b11;
 	else if (ds_rst & (~fifo_empty) & (ds_total != 64'h0))						 	 // only send data package
 		package_en <= 2'b10;
	//else if (ds_rst & (ds_total == 64'h0))
	//	package_en <= 2'b00;
 	else if (package_done)
 		package_en <= 2'b00;
 	else 
 	    package_en <= package_en;
 	end 
	
always @(posedge clk or posedge rst) begin
 	if (rst) 
 		package_en_2 <= 2'b00;
	//else if (fifo_empty & ds_rst_2 & (ds_total_2 == 64'h0) & (pep_under_process == 2'b10))   
 		//package_en_2 <= 2'b00;
 	else if (fifo_empty & ds_rst_2 & (ds_total_2 != 64'h0) & (pep_under_process == 2'b10))                             
 		package_en_2 <= 2'b10;
 	else if (fifo_empty & ds_rst_2 & (ds_total_2 == 64'h0) & (pep_under_process == 2'b01))   // send an empty package
 		package_en_2 <= 2'b01;
 	else if (fifo_empty & ds_rst_2 & (ds_total_2 != 64'h0) & (pep_under_process == 2'b01))                              // send data and empty flag package  
 		package_en_2 <= 2'b11;
 	else if (ds_rst_2 & (~fifo_empty) & (ds_total_2 != 64'h0))						 	 // only send data package
 		package_en_2 <= 2'b10;
	//else if (ds_rst & (ds_total == 64'h0))
	//	package_en <= 2'b00;
 	else if (package_done_2)
 		package_en_2 <= 2'b00;
 	else
 	    package_en_2 <= package_en_2;
 	end 

	
always @(posedge clk or posedge rst) begin
 	if (rst | (spec_valid & spec_ready & spec_last)) 
 		package_last <= 1'b0;
 	else if (fifo_empty & ds_rst & (pep_under_process == 2'b01))   
 		package_last <= 1'b1;
 	else if (fifo_empty & ds_rst_2 & (pep_under_process == 2'b01))                              
 		package_last <= 1'b1;
 	else if (fifo_empty & ds_rst & ds_rst_2 & (pep_under_process == 2'b10))                       
        package_last <= 1'b1;
 	else
 	    package_last <= package_last;
 	end 

reg 	[39:0]		pep_mass_r;
reg 	[31:0]  	pro_seq_num_r;
reg 	[31:0] 		spec_seq_num_r;
reg 	[15:0]      pep_start_r;
reg 	[15:0]      pep_end_r;
reg     [15:0]      missed_cleaves_r;
//reg     [15:0]      pep_length;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		pep_mass_r <= 40'h0;
		pro_seq_num_r <= 32'h0;
		pep_start_r <= 16'h0;
		pep_end_r <= 16'h0;
		missed_cleaves_r <= 16'h0;
		pep_length <= 16'h0;
	end
	else if (pep_ready_r & pep_valid_r) begin
		pep_mass_r <= pep_mass;
		pro_seq_num_r <= pro_seq_num;
		pep_start_r <= pep_start;
		pep_end_r <= pep_end;
		missed_cleaves_r <= missed_cleaves;		
		pep_length <= pep_end - pep_start + 16'b1;
		//pep_length <= pep_len;
	end
	else begin
		pep_mass_r <= pep_mass_r;
		pro_seq_num_r <= pro_seq_num_r;
		pep_start_r <= pep_start_r;
		pep_end_r <= pep_end_r;	
		missed_cleaves_r <= missed_cleaves_r;	
		pep_length <= pep_length;
	end
end

/*added*/
reg 	[39:0]		pep_mass_r_2;
reg 	[31:0]  	pro_seq_num_r_2;
reg 	[15:0]      pep_start_r_2;
reg 	[15:0]      pep_end_r_2;
reg     [15:0]      missed_cleaves_r_2;


always @(posedge clk or posedge rst) begin
	if (rst) begin
		pep_mass_r_2 <= 40'h0;
		pro_seq_num_r_2 <= 32'h0;
		pep_start_r_2 <= 16'h0;
		pep_end_r_2 <= 16'h0;
		missed_cleaves_r_2 <= 16'h0;
		pep_length_2 <= 16'h0;
	end
	else if (pep_ready_r_2 & pep_valid_r_2) begin
		pep_mass_r_2 <= pep_mass_2;
		pro_seq_num_r_2 <= pro_seq_num_2;
		pep_start_r_2 <= pep_start_2;
		pep_end_r_2 <= pep_end_2;
		missed_cleaves_r_2 <= missed_cleaves_2;		
		pep_length_2 <= pep_end_2 - pep_start_2 + 16'b1;
	//    pep_length_2 <= pep_len_2;
	end
	else begin
		pep_mass_r_2 <= pep_mass_r_2;
		pro_seq_num_r_2 <= pro_seq_num_r_2;
		pep_start_r_2 <= pep_start_r_2;
		pep_end_r_2 <= pep_end_r_2;	
		missed_cleaves_r_2 <= missed_cleaves_r_2;	
		pep_length_2 <= pep_length_2;
	end
end
/*added*/

always @(posedge clk or posedge rst) begin
	if (rst) 
		spec_seq_num_r <= 32'h0;
	else if (spec_ready & spec_valid)
		spec_seq_num_r <= spec_seq_num; 
	else
		spec_seq_num_r <= spec_seq_num_r;
end


ds_res_package ds_res_package_i(

 	.clk  						(clk),
 	.m_clk 						(m_clk),
 	.rst 						(rst),

 	.ds_ctrl 					(ds_ctrl),
 	.package_en 				(package_en),
 	.pep_mass 					(pep_mass_r), 
 	.z_charge                   (spec_z_charge_r),

	.pro_seq_num 				(pro_seq_num_r),
	.spec_seq_num 				(spec_seq_num_r),
	.pep_start 					(pep_start_r),
	.pep_end 					(pep_end_r),
	.missed_cleaves             (missed_cleaves_r),
    .ds_total                   (ds_total),
	.ds_a 						(ds_a),
	.ds_b 						(ds_b),
	.ds_c 						(ds_c),
	.ds_x 						(ds_x),
	.ds_y 						(ds_y),
	.ds_z 						(ds_z),

	.match_num_a				(match_num_a),
	.match_num_b				(match_num_b),
	.match_num_c				(match_num_c),
	.match_num_x				(match_num_x),
	.match_num_y				(match_num_y),
	.match_num_z				(match_num_z),

	.match_num_0 				(match_num_0),
	.match_num_1 				(match_num_1),
	.match_num_2 				(match_num_2),
	.match_num_3 				(match_num_3),
	.match_num_4 				(match_num_4),	
	.match_num_5 				(match_num_5),
	.match_num_6 				(match_num_6),
	.match_num_7 				(match_num_7),
	.match_num_8 				(match_num_8),
	.match_num_9 				(match_num_9),	
	.match_num_10				(match_num_10),
	.match_num_11				(match_num_11),
	.match_num_12				(match_num_12),
	.match_num_13				(match_num_13),
	.match_num_14				(match_num_14),
	.match_num_15				(match_num_15),
	.match_num_16				(match_num_16),
	.match_num_17				(match_num_17),
	.match_num_18				(match_num_18),
	.match_num_19				(match_num_19),
	.match_num_20				(match_num_20),
	.match_num_21				(match_num_21),
	.match_num_22				(match_num_22),
	.match_num_23				(match_num_23),
	.match_num_24				(match_num_24),
	.match_num_25				(match_num_25),
	.match_num_26				(match_num_26),
	.match_num_27				(match_num_27),
	.match_num_28				(match_num_28),
	.match_num_29				(match_num_29),

    .m_axis_tvalid 				(m_axis_tvalid),
    .m_axis_tready 				(m_axis_tready), 
    .m_axis_tdata 				(m_axis_tdata),       //[255 : 0]
    .m_axis_tkeep 				(m_axis_tkeep),		//[31 : 0]
    .m_axis_tlast				(m_axis_tlast),

    .axis_prog_full             (ds_blocked),
    .package_done               (package_done),
	.fifo_package_count         (fifo_count_1)
 	);

/*added*/
ds_res_package ds_res_package_i_2(

 	.clk  						(clk),
 	.m_clk 						(m_clk),
 	.rst 						(rst),

 	.ds_ctrl 					(ds_ctrl),
 	.package_en 				(package_en_2),
 	.pep_mass 					(pep_mass_r_2), 
 	.z_charge                   (spec_z_charge_r),

	.pro_seq_num 				(pro_seq_num_r_2),
	.spec_seq_num 				(spec_seq_num_r),
	.pep_start 					(pep_start_r_2),
	.pep_end 					(pep_end_r_2),
	.missed_cleaves             (missed_cleaves_r_2),
    .ds_total                   (ds_total_2),
	.ds_a 						(ds_a_2),
	.ds_b 						(ds_b_2),
	.ds_c 						(ds_c_2),
	.ds_x 						(ds_x_2),
	.ds_y 						(ds_y_2),
	.ds_z 						(ds_z_2),

	.match_num_a				(match_num_a_2),
	.match_num_b				(match_num_b_2),
	.match_num_c				(match_num_c_2),
	.match_num_x				(match_num_x_2),
	.match_num_y				(match_num_y_2),
	.match_num_z				(match_num_z_2),

	.match_num_0 				(match_num_0_2),
	.match_num_1 				(match_num_1_2),
	.match_num_2 				(match_num_2_2),
	.match_num_3 				(match_num_3_2),
	.match_num_4 				(match_num_4_2),	
	.match_num_5 				(match_num_5_2),
	.match_num_6 				(match_num_6_2),
	.match_num_7 				(match_num_7_2),
	.match_num_8 				(match_num_8_2),
	.match_num_9 				(match_num_9_2),	
	.match_num_10				(match_num_10_2),
	.match_num_11				(match_num_11_2),
	.match_num_12				(match_num_12_2),
	.match_num_13				(match_num_13_2),
	.match_num_14				(match_num_14_2),
	.match_num_15				(match_num_15_2),
	.match_num_16				(match_num_16_2),
	.match_num_17				(match_num_17_2),
	.match_num_18				(match_num_18_2),
	.match_num_19				(match_num_19_2),
	.match_num_20				(match_num_20_2),
	.match_num_21				(match_num_21_2),
	.match_num_22				(match_num_22_2),
	.match_num_23				(match_num_23_2),
	.match_num_24				(match_num_24_2),
	.match_num_25				(match_num_25_2),
	.match_num_26				(match_num_26_2),
	.match_num_27				(match_num_27_2),
	.match_num_28				(match_num_28_2),
	.match_num_29				(match_num_29_2),

    .m_axis_tvalid 				(m_axis_tvalid_2),
    .m_axis_tready 				(m_axis_tready_2), 
    .m_axis_tdata 				(m_axis_tdata_2),       //[255 : 0]
    .m_axis_tkeep 				(m_axis_tkeep_2),		//[31 : 0]
    .m_axis_tlast				(m_axis_tlast_2),

    .axis_prog_full             (ds_blocked_2),
    .package_done               (package_done_2),
	.fifo_package_count         (fifo_count_2)
 	);
/*added*/
/*
axis_switch_2_1 axis_switch_2_1_i(
  .aclk(clk),
  .aresetn(~rst),
  .s_axis_tvalid({m_axis_tvalid,m_axis_tvalid_2}),
  .s_axis_tready({m_axis_tready,m_axis_tready_2}),
  .s_axis_tdata({m_axis_tdata,m_axis_tdata_2}),
  .s_axis_tkeep({m_axis_tkeep,m_axis_tkeep_2}),
  .s_axis_tlast({m_axis_tlast,m_axis_tlast_2}),
  .m_axis_tvalid(m_axis_tvalid_s),
  .m_axis_tready(m_axis_tready_s),
  .m_axis_tdata(m_axis_tdata_s),
  .m_axis_tkeep(m_axis_tkeep_s),
  .m_axis_tlast(m_axis_tlast_s),
  .s_req_suppress(2'b10),
  .s_decode_err()
);
*/
reg [1:0] package_dst;

always @(posedge m_clk or posedge rst) begin
	if (rst) 
		package_dst <= 2'b01;
	else if ((m_axis_tlast & m_axis_tvalid & m_axis_tready) & (fifo_count_1 <  fifo_count_2))
		package_dst <= 2'b10;
	else if ((m_axis_tlast_2 & m_axis_tvalid_2 & m_axis_tready_2) & (fifo_count_1 >  fifo_count_2))
		package_dst <= 2'b01;
	else if ( (package_dst == 2'b01) & (~m_axis_tvalid) )
	    package_dst <= 2'b10;
	else if ( (package_dst == 2'b10) & (~m_axis_tvalid_2) )
        package_dst <= 2'b01;
	else 
		package_dst <= package_dst;
end	

wire m_axis_tlast_tmp;

assign m_axis_tready = (package_dst == 2'b01)?m_axis_tready_s:1'b0;
assign m_axis_tvalid_s = (package_dst == 2'b01)?m_axis_tvalid:m_axis_tvalid_2;
assign m_axis_tdata_s = (package_dst == 2'b01)?m_axis_tdata:m_axis_tdata_2;
assign m_axis_tkeep_s = (package_dst == 2'b01)?m_axis_tkeep:m_axis_tkeep_2;
assign m_axis_tlast_tmp = (package_dst == 2'b01)?m_axis_tlast:m_axis_tlast_2;
assign m_axis_tready_2 = (package_dst == 2'b10)?m_axis_tready_s:1'b0;
assign m_axis_tlast_s = m_axis_tlast_tmp & package_last;

always @(posedge clk or posedge rst) begin
	if (rst)
		submit_done <= 1'b0;
	else if (package_done | (ds_rst & (ds_total == 64'h0) & (~fifo_empty)))
		submit_done <= 1'b1;
	else 
		submit_done <= 1'b0;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		submit_done_2 <= 1'b0;
	else if (package_done_2 | (ds_rst_2 & (ds_total_2 == 64'h0) & (~fifo_empty)))
		submit_done_2 <= 1'b1;
	else 
		submit_done_2 <= 1'b0;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		package_num <= 32'h0;
	else if (m_axis_tready_s & m_axis_tvalid_s & m_axis_tlast_tmp)
		package_num <= package_num + 32'h1;
	else if (spec_update_s & spec_ready & spec_valid & spec_last)
		package_num <= 32'h0;
	else 
	    package_num <= package_num;
end





assign debug_state = next;
assign debug_state2 = next_2;//ymc
assign debug_package_num = package_num;
assign debug_pep_dst = pep_dst_s;
assign debug_package_dst = package_dst;


endmodule
