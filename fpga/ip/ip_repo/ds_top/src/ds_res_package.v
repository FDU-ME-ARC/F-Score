 `timescale 1 ns / 1 ps
 `include "ds_define.vh"

 `define SPEC_UPDATE 8'h0a

 module ds_res_package (

 	input 	wire 								clk,
 	input   wire								m_clk,
 	input 	wire								rst,

 	input 	wire	[31 : 0]					ds_ctrl,
 	input   wire 	[1 : 0]						package_en,
 	input   wire    [39 : 0] 					pep_mass,

 	input   wire    [4 : 0] 					z_charge,    

	input	wire	[31 : 0]  					pro_seq_num,
	input 	wire 	[31 : 0] 					spec_seq_num,
  
	input	wire    [15 : 0]                    pep_start,
	input   wire    [15 : 0]                    pep_end,
	//input   wire    [15 : 0]                    pep_len,
    input   wire    [15 : 0]                    missed_cleaves,
    input   wire    [63 : 0]                   	ds_total,

	input	wire 	[63 : 0]					ds_a,
	input	wire 	[63 : 0]					ds_b,
	input	wire 	[63 : 0]					ds_c,
	input	wire 	[63 : 0]					ds_x,
	input	wire 	[63 : 0]					ds_y,
	input	wire 	[63 : 0]					ds_z,

	input	wire 	[15 : 0]					match_num_a,
	input	wire 	[15 : 0]					match_num_b,
	input	wire 	[15 : 0]					match_num_c,
	input	wire 	[15 : 0]					match_num_x,
	input	wire 	[15 : 0]					match_num_y,
	input	wire 	[15 : 0]					match_num_z,

	input	wire 	[47 : 0]					match_num_0,
	input	wire 	[47 : 0]					match_num_1,
	input	wire 	[47 : 0]					match_num_2,
	input	wire 	[47 : 0]					match_num_3,
	input	wire 	[47 : 0]					match_num_4,	
	input	wire 	[47 : 0]					match_num_5,
	input	wire 	[47 : 0]					match_num_6,
	input	wire 	[47 : 0]					match_num_7,
	input	wire 	[47 : 0]					match_num_8,
	input	wire 	[47 : 0]					match_num_9,	
	input	wire 	[47 : 0]					match_num_10,
	input	wire 	[47 : 0]					match_num_11,
	input	wire 	[47 : 0]					match_num_12,
	input	wire 	[47 : 0]					match_num_13,
	input	wire 	[47 : 0]					match_num_14,
	input	wire 	[47 : 0]					match_num_15,
	input	wire 	[47 : 0]					match_num_16,
	input	wire 	[47 : 0]					match_num_17,
	input	wire 	[47 : 0]					match_num_18,
	input	wire 	[47 : 0]					match_num_19,
	input	wire 	[47 : 0]					match_num_20,
	input	wire 	[47 : 0]					match_num_21,
	input	wire 	[47 : 0]					match_num_22,
	input	wire 	[47 : 0]					match_num_23,
	input	wire 	[47 : 0]					match_num_24,
	input	wire 	[47 : 0]					match_num_25,
	input	wire 	[47 : 0]					match_num_26,
	input	wire 	[47 : 0]					match_num_27,
	input	wire 	[47 : 0]					match_num_28,
	input	wire 	[47 : 0]					match_num_29,

    output 										m_axis_tvalid,
    input  										m_axis_tready, 
    output 			[255 : 0]					m_axis_tdata,
    output 			[31 :0 ] 					m_axis_tkeep,
    output 										m_axis_tlast,

    output                                      axis_prog_full,
    output    wire                              package_done,
 	output    [9:0] 					        fifo_package_count                     
 	);
reg 	[255 : 0]					ds_data_reg;
reg                                 ds_res_valid;
wire                                ds_res_ready;
reg     [31 : 0]                    ds_res_keep;
reg                                 ds_res_last;
wire    [9:0] 					    fifo_count;

assign axis_prog_full = fifo_count > 'h1f4;
assign fifo_package_count = fifo_count;


reg    package_state;

always @(posedge clk or posedge rst) begin
	if (rst)
		package_state <= 1'b0;
	else if (ds_res_last)
		package_state <= 1'b0;
	else if (package_en > 2'b00 & (~ds_res_last))
		package_state <= 1'b1; 
end


parameter     	IDLE 	= 2'b01,
				SEND	= 2'b10;

reg [1 : 0]		next;
reg [1 : 0]    current;

always @(posedge clk or posedge rst) begin
 	if (rst)
 		current <= IDLE;
 	else 
 		current <= next;
 end 


always @(*) begin
	case (current)
	IDLE : 
	begin
		if((~axis_prog_full) & ds_res_ready & package_state)
			next = SEND;
		else 
			next = IDLE;
	end

	SEND :
	begin
		if(ds_res_last)
			next = IDLE;
		else 
			next = SEND;
	end

	default : 
		next = IDLE;
	endcase
end

reg   [7 : 0]    	frame_len;
reg   [3 : 0] 		frame_pointer;

always @(posedge clk or posedge rst) begin
	if (rst)
		ds_res_valid <= 1'b0;
	else if (current == SEND && (~ds_res_last))
		ds_res_valid <= 1'b1;
	else if (current == SEND && ds_res_last)
		ds_res_valid <= 1'b0;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		frame_pointer <= 4'b0;
	else if (ds_res_valid & (~ds_res_last)) 
		frame_pointer <= frame_pointer + 4'b1;		
	else if (ds_res_valid & ds_res_last)
		frame_pointer <= 4'b0;
end

reg    [4 : 0]  		state_num;
reg    [4 : 0]          state_num_q;


always @(*) begin
	if (z_charge <= 5'h1)
		state_num = 5'h2;
	else if((z_charge > 5'h2) & ds_ctrl[9] & ds_ctrl[6])
		state_num = z_charge - 5'h1;
	else 
		state_num = z_charge;
end

always @(posedge clk or posedge rst) begin
	if (rst) 
		state_num_q <= 5'h0;
	else if (package_en)
		state_num_q <= state_num;
	else 
		state_num_q <= state_num_q; 
end


always @(*) begin
	if (ds_res_valid & (package_en >= 2'b10)) begin
		if (state_num_q <= 5'h6)
			frame_len = 8'h3;
		else if (state_num_q <= 5'hb)
			frame_len = 8'h4;
		else if (state_num_q <= 5'h10)
			frame_len = 8'h5;
		else if (state_num_q <= 8'h16)
			frame_len = 8'h6;
		else if (state_num_q <= 8'h1b)
			frame_len = 8'h7;
		else
			frame_len = 8'h8;  
	end
	else 
		frame_len = 8'hff;
end


always @(posedge clk or posedge rst) begin
	if (rst) 
		ds_res_last <= 1'b0;
	else if (((frame_pointer == frame_len[3 : 0] - 1) & ds_res_valid) | ((current == SEND) & (package_en == 2'b01))) 
		ds_res_last <= 1'b1;	
	else
		ds_res_last <= 1'b0;
end

reg  [7:0] process_end;
always @(posedge clk or posedge rst) begin
	if (rst) 
		process_end <= 8'h0;
	else if (package_en == 2'b11)
		process_end <= `SPEC_UPDATE;
	//else if (current == SEND && next == IDLE)
	//	process_end <= 8'h0;
	else 
	   process_end <= 8'h0;
end

//wire  [7 : 0]     frame_length;
//assign frame_length = (package_en == 2'b01) ?  8'h1 : frame_len + 8'b1;

//wire    [15 : 0]                    pep_end;
//assign pep_end = pep_start + pep_len - 16'b1;

always @(*) begin
	if (ds_res_valid) begin
		ds_res_keep <= 32'hffffffff;
		if (package_en == 2'b01)
			ds_data_reg <= {176'h0, 8'h1, `SPEC_UPDATE, 64'h0};
		else begin
			case (frame_pointer)
				4'h0 : ds_data_reg <= {pro_seq_num, spec_seq_num, pep_start, pep_end, ds_total, 2'b0, ds_ctrl[11 : 6], 3'b0, state_num, frame_len+8'h1, process_end, 8'h0, missed_cleaves, pep_mass};
	
				4'h1 : ds_data_reg <= {ds_a, ds_b, ds_c, ds_x};   
	
      			4'h2 : ds_data_reg <= {ds_y, ds_z, match_num_a, match_num_b, match_num_c, match_num_x, match_num_y, match_num_z, match_num_0[47:16]}; 
	
       			4'h3 : ds_data_reg <= {match_num_0[15 : 0], match_num_1, match_num_2, match_num_3, match_num_4, match_num_5};
	
       			4'h4 : ds_data_reg <= {match_num_6, match_num_7, match_num_8, match_num_9, match_num_10, match_num_11[47 : 32]};
	
       			4'h5 : ds_data_reg <= {match_num_11[31 : 0], match_num_12, match_num_13, match_num_14, match_num_15, match_num_16[47:16]};
	
       			4'h6 : ds_data_reg <= {match_num_16[15 : 0], match_num_17, match_num_18, match_num_19, match_num_20, match_num_21};
	
       			4'h7 : ds_data_reg <= {match_num_22, match_num_23, match_num_24, match_num_25, match_num_26, match_num_27[47 : 32]};
	
       			4'h8 : ds_data_reg <= {match_num_27[31 : 0], match_num_28, match_num_29, 128'h0};
	
       			default : ds_data_reg <= 256'h0;
 			endcase
 		end
	end
	else begin
		ds_data_reg <= 256'h0;
		ds_res_keep <= 32'h0;
	end
end

/*always @(posedge clk or posedge rst) begin
	if (ds_res_valid) begin
		$display("Packaging %d : %H", frame_pointer, ds_res_data);
	end
end
*/
//always @(posedge clk or posedge rst) begin
//	if (rst) 
//		package_done <= 1'b0;
//	else if (ds_res_valid & ds_res_last & (current == SEND))
//		package_done <= 1'b1;
//	else 
//		package_done <= 1'b0; 
//end
assign package_done = ds_res_valid & ds_res_last & (current == SEND);
/*
always @(posedge clk or posedge rst) begin
	if (rst) 
		ds_data_reg <= 1'b0;
	else if (frame_pointer == frame_len)
		ds_data_reg <= 1'b1;
	else 
		ds_data_reg <= 1'b0;
end

*/

wire  [255 : 0]      ds_res_data;
ds_convert #(.DATA_WIDTH(8)) ds_convert_res (.data_in(ds_data_reg), .data_out(ds_res_data));


ds_res_package_fifo ds_res_package_fifo_i(
    .m_aclk 				(m_clk),        		// IN
    .s_aclk					(clk), 					// IN
    .s_aresetn 				(~rst),					// IN
    .s_axis_tvalid 			(ds_res_valid),			// IN
    .s_axis_tready 			(ds_res_ready),			// OUT
    .s_axis_tdata 			(ds_res_data),			// IN STD_LOGIC_VECTOR(255 DOWNTO 0);  ds_res_da
    .s_axis_tkeep 			(ds_res_keep),  		// IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_axis_tlast 			(ds_res_last),			// IN STD_LOGIC;
    .m_axis_tvalid 			(m_axis_tvalid),		// OUT STD_LOGIC;
    .m_axis_tready 			(m_axis_tready),		// IN STD_LOGIC;
    .m_axis_tdata 			(m_axis_tdata), 		// OUT STD_LOGIC_VECTOR(255 DOWNTO 0);
    .m_axis_tkeep 			(m_axis_tkeep), 		// OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    .m_axis_tlast 			(m_axis_tlast), 		// OUT STD_LOGIC;
    .axis_wr_data_count  	(fifo_count),
    .axis_rd_data_count 	()		// OUT STD_LOGIC
  );




endmodule
