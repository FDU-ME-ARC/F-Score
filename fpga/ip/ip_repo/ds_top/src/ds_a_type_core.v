`timescale 1 ns / 1 ps
`include "ds_define.vh"
module ds_a_type_core #
(

	parameter integer FORM_WIDTH = 32,
	parameter integer DATA_WIDTH = 32,
	parameter 		  FRAG_TYPE = `A_TYPE,
	parameter integer RESULT_WID = 64	

)(
	input  	wire 				clk,
	input	wire				rst,
	input 	wire				gen_en,
	input	wire 				ds_done,
	input   wire                start,   //compute start

	input	wire  [31:0]			ds_ctrl,
	input	wire  [31:0]			m_nt,			// slv_reg1
	input	wire  [31:0]			m_cleave_n,		// slv_reg3
	input   wire  [31:0]           	WOE,            // slv_reg5
	input	wire  [31:0] 			mod_left,		
	input	wire  [31:0]			fullmod_left, 	// slv_reg41
    input   wire  [3:0]             pep_judge,
	input	wire  [4:0] 			z_charge,

/* ------------- input pep data ------------- */
	output 	wire  [4:0]					read_addr,
	input 	wire  [DATA_WIDTH*5-1:0] 	pep_data,  
	input	wire  [15:0]			    pep_len, 


/* ------------- input spec data ------------ */
	output	[4 : 0]						spec_bram_addr,
	input	[20 * DATA_WIDTH - 1 : 0]	spec_mz_data,
	input 	[40 * DATA_WIDTH - 1 : 0]	spec_i_data,   
	input	[15 : 0]					spec_len,

	output  [159 : 0] 					para_addr,
	input   [1023 : 0]                  para_data,

/*------------ result output ----------------*/

	output	[63 : 0]					ds_a,
	output  [15 : 0]					match_num_a,
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

	output	wire						at_cmp_done,
	input   wire                        ds_blocked
);

wire   [8 * FORM_WIDTH - 1 : 0]    p_data;
assign    p_data = {32 {8'h01}};

wire   [40 * FORM_WIDTH - 1 : 0]   mz_data;
wire               frag_gen_done;
wire   [4 : 0 ]    res_read_addr;

ds_fwd_frag #
	(
		.DATA_WIDTH (DATA_WIDTH),
		.FORM_WIDTH (FORM_WIDTH),
		.FRAG_TYPE  (`A_TYPE)
	)
ds_at_frag_i(
		.clk			(clk),
		.rst 			(rst),
		.gen_en 		(gen_en),    //gen_en = mass_match &  x_type       
		.ds_done		(ds_done), 
		.start          (start),


		/* register input */
		.ds_ctrl 		(ds_ctrl),   		// slv_reg0
		.m_nt			(m_nt),			// slv_reg2
		.m_cleave_n 	(m_cleave_n),		// slv_reg4
		.mod_left 		(mod_left),		// slv_reg12
		.fullmod_left 	(fullmod_left), 	// slv_reg41
        .pep_judge      (pep_judge),
		/* get data from ds_pepc_store bram */
		
		.pep_addr 		(read_addr),
		.pep_data 		(pep_data),       // pep data from bram
		.pep_len 		(pep_len), 		// pep_len

		/* ds_score interface */
    	.xr_addr 		(res_read_addr),
    	.xr_data		(mz_data), 
    	.store_finish 	(frag_gen_done), 
		/* coefficient register input*/	

		.para_addr     	(para_addr),
		.para_data      (para_data)

	);

ds_frag_compare #(

	.FORM_WIDTH (FORM_WIDTH),
	.DATA_WIDTH (DATA_WIDTH),
	.RESULT_WID (RESULT_WID),
	.FRAG_TYPE  (`A_TYPE)
	
	)
ds_at_compare_i(

	//system input
	.clk 				(clk),
	.rst   				(rst),

	// register parameter
	.ds_ctrl 			(ds_ctrl),         // slv_reg0
	.WOE 				(WOE),             // slv_reg5

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
	.frag_xt_p 			(p_data),
	
	//upload result
	.ds_x 				(ds_a),

	.match_num_x  		(match_num_a),
	

	.match_num0			(match_num0),
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
	.clear 					(at_cmp_done),
	.ds_blocked             (ds_blocked) 
);

endmodule