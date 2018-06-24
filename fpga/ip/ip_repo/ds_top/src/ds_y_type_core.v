`timescale 1 ns / 1 ps
`include "ds_define.vh"

module ds_y_type_core #
(

	parameter integer FORM_WIDTH = 32,
	parameter integer DATA_WIDTH = 32,
	parameter 		  FRAG_TYPE = `Y_TYPE,
	parameter integer RESULT_WID = 64	

)(
	input  	wire 				clk,
	input	wire				rst,
	input 	wire				gen_en,
	input	wire 				ds_done,
	input   wire                start,   //compute start


	input	wire  [31:0] 			ds_ctrl,		// slv_reg0
	input	wire  [31:0]			m_ct,			// slv_reg2
	input	wire  [31:0]			m_cleave_c,		// slv_reg4
	input   wire  [31:0]           	WOE,            // slv_reg5
	input	wire  [31:0] 			mod_right,		// slv_reg12
	input	wire  [31:0]			fullmod_right, 	// slv_reg41
    input   wire  [3:0]             pep_judge,
	input	wire  [4:0] 			z_charge,

/* ------------- input pep data ------------- */
	output 	wire  [4:0]					pep_read_addr,
	input 	wire  [DATA_WIDTH*5-1:0] 	pep_data,  
	input	wire  [15:0]			    pep_len, 


/* ------------- input spec data ------------ */
	output	[4 : 0]						spec_bram_addr,
	input	[20 * DATA_WIDTH - 1 : 0]	spec_mz_data,
	input 	[40 * DATA_WIDTH - 1 : 0]	spec_i_data,   
	output	[4 : 0]						spec_bram_addr_1,
	input	[20 * DATA_WIDTH - 1 : 0]	spec_mz_data_1,
	input 	[40 * DATA_WIDTH - 1 : 0]	spec_i_data_1, 
	input	[15 : 0]					spec_len,

	output  [159 : 0] 					para_addr,
	input   [1023 : 0]                  para_data,
/*------------ result output ----------------*/

	output	[63 : 0]					ds_y,
	output	[15 : 0]					match_num_y,
	output	[7 : 0]						match_num0,
	output	[7 : 0]						match_num1,
	output	[7 : 0]						match_num2,
	output	[7 : 0]						match_num3,
	output	[7 : 0]						match_num4,	
	output	[7 : 0]						match_num5,
	output	[7 : 0]						match_num6,
	output	[7 : 0]						match_num7,
	output	[7 : 0]						match_num8,
	output	[7 : 0]						match_num9,	
	output	[7 : 0]						match_num10,
	output	[7 : 0]						match_num11,
	output	[7 : 0]						match_num12,
	output	[7 : 0]						match_num13,
	output	[7 : 0]						match_num14,
	output	[7 : 0]						match_num15,
	output	[7 : 0]						match_num16,
	output	[7 : 0]						match_num17,
	output	[7 : 0]						match_num18,
	output	[7 : 0]						match_num19,
	output	[7 : 0]						match_num20,
	output	[7 : 0]						match_num21,
	output	[7 : 0]						match_num22,
	output	[7 : 0]						match_num23,
	output	[7 : 0]						match_num24,
	output	[7 : 0]						match_num25,
	output	[7 : 0]						match_num26,
	output	[7 : 0]						match_num27,
	output	[7 : 0]						match_num28,
	output	[7 : 0]						match_num29,


`ifdef TIME_COUNT
	output   reg                        dot_time_en,
	output   reg                        frag_time_en,
`endif

	output	wire						yt_cmp_done,
	input   wire                        ds_blocked
);

wire    [4 : 0] 						res_read_addr;
wire	[40 * DATA_WIDTH - 1 : 0]    	mz_data;
wire 	[8 * DATA_WIDTH - 1 : 0] 		p_data_0;


wire    [31 : 0]						y_value_1_reg;
wire    [159 : 0]						x_value_1_reg;
	


ds_bwd_frag #
	(
		.DATA_WIDTH (DATA_WIDTH),
		.FORM_WIDTH (FORM_WIDTH),
		.FRAG_TYPE  (`Y_TYPE)
	)
ds_yt_frag_i(
		.clk			(clk),
		.rst 			(rst),
		.gen_en 		(gen_en),    //gen_en = mass_match &  x_type       
		.ds_done		(ds_done), 
		.start          (start),


		/* register input */
		.ds_ctrl 		(ds_ctrl),   		// slv_reg0
		.m_ct			(m_ct),			// slv_reg2
		.m_cleave_c 	(m_cleave_c),		// slv_reg4
		.mod_right 		(mod_right),		// slv_reg12
		.fullmod_right 	(fullmod_right), 	// slv_reg41
        .pep_judge      (pep_judge),
		/* get data from ds_pepc_store bram */
		
		.pep_addr 		(pep_read_addr),
		.pep_data 		(pep_data),       // pep data from bram
		.pep_len 		(pep_len), 		// pep_len

		/* ds_score interface */
		//input 	wire						xr_en,
    	.xr_addr 		(res_read_addr),
    	.xr_data		(mz_data), 
    	.yr_data		(p_data_0),
    	.y_value_1_reg  (y_value_1_reg),        //width = 32   , when bzero = 0
    	.x_value_1_reg  (x_value_1_reg),        //width = 160  , when bzero = 0
    	.store_finish 	(frag_gen_done), 
		/* coefficient register input*/	
		.para_addr      (para_addr),
		.para_data      (para_data)

	);



wire	[63 : 0]					ds_y_0;
wire	[15 : 0]					match_num_y_0;
wire	[7 : 0]						match_num0_0;


`ifdef TIME_COUNT
//reg                  dot_time_en;
//reg                  frag_time_en;
reg start_r;
reg start_rr;
wire start_pulse;

always @(posedge clk or posedge rst) begin
	if (rst) begin
 		start_r <= 1'b0;
 		start_rr <= 1'b0;
	end
	else begin
		start_r <= start;
		start_rr <= start_r;
	end
end

assign start_pulse = ~start_rr & start_r;


always @(posedge clk or posedge rst) begin
	if (rst)
		dot_time_en <= 1'b0;
	else if (dot_time_en & yt_cmp_done) 
		dot_time_en <= 1'b0;
	else if ((~dot_time_en) & frag_gen_done)
		dot_time_en <= 1'b1; 
	else
		dot_time_en <= dot_time_en;
end

always @(posedge clk or posedge rst) begin
	if (rst)
		frag_time_en <= 1'b0;
	else if (frag_time_en & frag_gen_done)
		frag_time_en <= 1'b0;
	else if ((~frag_time_en) & start_pulse)
		frag_time_en <= 1'b1;
	else
		frag_time_en <= frag_time_en;
end

`endif



ds_frag_compare #(

	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.RESULT_WID (RESULT_WID),
	.FRAG_TYPE (`Y_TYPE)
	
	)
ds_yt_compare_i(

	//system input
	.clk 				(clk),
	.rst   				(rst),

	// register parameter
	.ds_ctrl 			(ds_ctrl),         // slv_reg0
	.WOE 				(WOE),             // slv_reg5

	//.parent_mass_match	(parent_mass_match),
	.start              (start),
	.frag_gen_done 		(frag_gen_done),   //frag_gen_done = ds_ctrl[8] & store_finish_x;


	//spec data input
	.spec_bram_addr 	(spec_bram_addr),  //for both mz and i value
	.spec_mz_data		(spec_mz_data),
	.spec_i_data 		(spec_i_data),     // Q20 form
	.spec_len 			(spec_len),


	//pep frag input
	.frag_bram_addr		(res_read_addr),
	.frag_len 			(pep_len),
	.frag_xt_mz 		(mz_data),     // 
	.frag_xt_p 			(p_data_0),
	
	//upload result
	.ds_x 				(ds_y_0),

	.match_num_x  		(match_num_y_0),
	

	.match_num0			(match_num0_0),
	.match_num1			(match_num1),
	.match_num2			(match_num2),
	.match_num3			(match_num3),
	.match_num4			(match_num4),	
	.match_num5			(match_num5),
	.match_num6			(match_num6),
	.match_num7			(match_num7),
	.match_num8			(match_num8),
	.match_num9			(match_num9),	
	.match_num10		(match_num10),
	.match_num11		(match_num11),
	.match_num12		(match_num12),
	.match_num13		(match_num13),
	.match_num14		(match_num14),	
	.match_num15		(match_num15),	
	.match_num16		(match_num16),
	.match_num17		(match_num17),
	.match_num18		(match_num18),
	.match_num19		(match_num19),	
	.match_num20		(match_num20),	
	.match_num21		(match_num21),
	.match_num22		(match_num22),
	.match_num23		(match_num23),
	.match_num24		(match_num24),	
	.match_num25		(match_num25),	
	.match_num26		(match_num26),
	.match_num27		(match_num27),
	.match_num28		(match_num28),
	.match_num29		(match_num29),	

	.spec_z_charge			(z_charge),
	.clear 					(yt_cmp_done),
	.ds_blocked             (ds_blocked) 
);

wire   [63 : 0] ds_score_1;
wire   [7 : 0]  match_num0_1;

ds_y_seg_compare #(

	.DATA_WIDTH (DATA_WIDTH),
	.FORM_WIDTH (FORM_WIDTH)

)ds_y_seg_compare_i (
	.clk 			(clk),
	.rst 			(rst),
	.start 			(frag_gen_done & (z_charge == 5'h2)),        	// (spec_z_charge == 2) && pep_store_finished
	.WOE 			(WOE),
	.ds_ctrl        (ds_ctrl),  

    .read_addr 		(spec_bram_addr_1),    	// for spec_z_charge = 1
    .spec_mz_data 	(spec_mz_data_1),  	// for spec_z_charge = 1
    .spec_i_data 	(spec_i_data_1),
    .spec_len 		(spec_len),


    .y_value_1_reg 	(y_value_1_reg),
    .x_value_1_reg 	(x_value_1_reg),

	.ds_score 		(ds_score_1),
	.match_num0 	(match_num0_1),

	.ds_done	 	(ds_done),
	.comp_done 		(yt_cmp_done_1)

);

assign ds_y = (z_charge == 5'h2) ? (ds_y_0 + ds_score_1) : ds_y_0 ;
assign match_num0 = (z_charge == 5'h2) ? ((match_num0_1 + match_num0_0 >= 8'h3f) ? 8'h3f : (match_num0_1 + match_num0_0)) : match_num0_0;
assign match_num_y = (z_charge == 5'h2) ? (match_num0_1 + match_num_y_0) : match_num_y_0;


endmodule