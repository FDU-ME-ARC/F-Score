`timescale 1 ns / 1 ps
`include "ds_define.vh"

module ds_y_seg_compare #
(
	parameter DATA_WIDTH = 32,
	parameter FORM_WIDTH = 32

)(
	input 										clk,
	input 										rst,
	input  										start,        	// (spec_z_charge == 2) && pep_store_finished
	input   [FORM_WIDTH - 1 : 0]        		WOE,
	input   [FORM_WIDTH - 1 : 0] 				ds_ctrl,  

    output  reg [4 : 0]                         read_addr,    	// for spec_z_charge = 1
    input   [20 * DATA_WIDTH - 1 : 0]       	spec_mz_data,  	// for spec_z_charge = 1
    input   [40 * DATA_WIDTH - 1 : 0]       	spec_i_data,
    input 	[15 : 0]							spec_len,


    input   [31 : 0]		 					y_value_1_reg,
    input   [159 : 0]		 		        	x_value_1_reg,

	output	reg [63 : 0]						ds_score,
	output	reg [7 : 0]							match_num0,

	input                                   	ds_done,
	output  reg                               	comp_done

);

parameter   		init = 3'b001,
					comp = 3'b010,
					free = 3'b100;

reg  [2 : 0]  		state;

reg 		start_r;
always @(posedge clk or posedge rst) begin
	if (rst) 
		start_r <= 1'b0;
	else if (start) 
		start_r <= 1'b1;
	else 
		start_r <= 1'b0;
end


always @(posedge clk or posedge rst) begin
	if (rst)
		state <= init;
	else begin
		case (state)
		init : begin
			if (start_r)
				state <= comp;
			else 
				state <= init;
		end
		comp : begin
			if (comp_done)
				state <= free;
			else 
				state <= comp;
		end
		free : begin
			if (ds_done)
				state <= init;
			else 
				state <= free;
		end
		default : state = init;
		endcase
	end 
end

reg  [4 : 0]   spec_pointer;
reg  [1 : 0]   pep_pointer;


//wire    spec_next;
//wire    spec_read_next;
//
//assign  spec_next = (state == comp) & (spec_pointer == 5'b0);
//
//ds_sample next_gen_i(.clk(clk), .rst(rst), .sig_in(spec_next), .sig_out(spec_read_next));
//
//always @(posedge clk or posedge rst) begin
//	if (rst) 
//		read_addr <= 5'h0;
//	else if (spec_read_next)
//		read_addr <= read_addr + 5'h1;
//	else if (comp_done)
//		read_addr <= 5'h0;
//	else
//		read_addr <= read_addr;
//end

reg 	[20 * DATA_WIDTH - 1 : 0]    spec_mz_tmp;
reg  	[40 * DATA_WIDTH - 1 : 0]	 spec_i_tmp;
wire    [39 : 0] 					 spec_i_value [0 : 31];
wire    [19 : 0] 					 spec_mz_value[0 : 31];
reg     [19 : 0]					 pep_mz_value[0 : 3];
wire    [7  : 0] 					 pep_p_value[0 : 3];
wire    [71 : 0]					 pep_mz_value_i[0 : 3];
wire 	[31 : 0]					 m_proton;
assign 	m_proton = ds_ctrl[1] ? `M_PROTON_1 : `M_PROTON_0;



generate
	genvar i;
	for(i = 0 ; i < 32; i = i + 1) begin
		assign spec_i_value[i] = spec_i_tmp[40 * i +: 40];
		assign spec_mz_value[i] = spec_mz_tmp[20 * i +: 20];
	end
endgenerate

generate
	genvar j;
	for(j = 0; j < 4; j = j + 1) begin
	//	assign pep_mz_value_i[j] = ((x_value_1_reg[40 * j +: 40] >> 1) * WOE) + (m_proton * WOE);
		assign pep_p_value[j] = y_value_1_reg[8 * j +: 8];
	end	
endgenerate


mult_40_32 mult_pep_i_0(.CLK(clk), .A({1'b0, x_value_1_reg[39 : 1  ]}), .B(WOE), .CE(start), .P(pep_mz_value_i[0]));
mult_40_32 mult_pep_i_1(.CLK(clk), .A({1'b0, x_value_1_reg[79 : 41 ]}), .B(WOE), .CE(start), .P(pep_mz_value_i[1]));
mult_40_32 mult_pep_i_2(.CLK(clk), .A({1'b0, x_value_1_reg[119: 81 ]}), .B(WOE), .CE(start), .P(pep_mz_value_i[2]));
mult_40_32 mult_pep_i_3(.CLK(clk), .A({1'b0, x_value_1_reg[159: 121]}), .B(WOE), .CE(start), .P(pep_mz_value_i[3]));
/*
always @(posedge clk or posedge rst) begin
	if (rst) begin
		pep_mz_value_i[0] <= 64'h0;
		pep_mz_value_i[1] <= 64'h0;
		pep_mz_value_i[2] <= 64'h0;
		pep_mz_value_i[3] <= 64'h0;
	end
	else if (start) begin
		pep_mz_value_i[0] <= (x_value_1_reg[39 : 0] >> 1) * WOE;
		pep_mz_value_i[1] <= (x_value_1_reg[79 : 40] >> 1) * WOE;
		pep_mz_value_i[2] <= (x_value_1_reg[119 : 80] >> 1) * WOE;
		pep_mz_value_i[3] <= (x_value_1_reg[159 : 120] >> 1) * WOE;		
	end
	else begin
		pep_mz_value_i[0] <= pep_mz_value_i[0];
		pep_mz_value_i[1] <= pep_mz_value_i[1];
		pep_mz_value_i[2] <= pep_mz_value_i[2];
		pep_mz_value_i[3] <= pep_mz_value_i[3];		
	end
end
*/
wire [63 : 0] coef_1_r;
mult_32_32 coef_gen(.CLK(clk), .A(m_proton), .B(WOE), .CE(start), .P(coef_1_r));

wire [63 : 0] pep_mz_value_q [0 :3];
assign pep_mz_value_q[0] = pep_mz_value_i[0][63 : 0] + coef_1_r;
assign pep_mz_value_q[1] = pep_mz_value_i[1][63 : 0] + coef_1_r;
assign pep_mz_value_q[2] = pep_mz_value_i[2][63 : 0] + coef_1_r;
assign pep_mz_value_q[3] = pep_mz_value_i[3][63 : 0] + coef_1_r;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		pep_mz_value[0] <= 20'h0;
		pep_mz_value[1] <= 20'h0;
		pep_mz_value[2] <= 20'h0;
		pep_mz_value[3] <= 20'h0;
	end
	else if (start_r) begin
		pep_mz_value[0] <= pep_mz_value_q[0][59 : 40];
		pep_mz_value[1] <= pep_mz_value_q[1][59 : 40];
		pep_mz_value[2] <= pep_mz_value_q[2][59 : 40];
		pep_mz_value[3] <= pep_mz_value_q[3][59 : 40];
	end 
	else begin
		pep_mz_value[0] <= pep_mz_value[0]; 
		pep_mz_value[1] <= pep_mz_value[1];
		pep_mz_value[2] <= pep_mz_value[2];
		pep_mz_value[3] <= pep_mz_value[3];
	end
end



wire   spec_end;
wire   [4 : 0]  spec_deep;
assign spec_deep = (spec_len >> 5) + (spec_len[4 : 0] == 5'h0 ? 5'b0 : 5'b1);
assign spec_end = (state == comp) & (read_addr == spec_deep);

wire   [47 : 0] ds_score_tmp;
reg   match_en;
always @(posedge clk or posedge rst) begin
	if (rst) begin
	//	ds_score <= 64'h0;
		spec_pointer <= 5'h0;
		pep_pointer <= 2'h0;
		match_num0 <= 8'h0;	
		comp_done <= 1'b0;
		match_en <= 1'b0;
		read_addr <= 5'b0;
	end
	else if ((state == init) &  start_r) begin
	//	ds_score <= 64'h0;
		spec_pointer <= 5'h0;
		pep_pointer <= 2'h0;
		match_num0 <= 8'h0;	
		spec_mz_tmp <= spec_mz_data;
		spec_i_tmp  <= spec_i_data;
		read_addr <= read_addr + 5'b1;
		match_en <= 1'b0;

	end
	else if ((state == comp) & (~comp_done)) begin
		if(pep_mz_value[pep_pointer] == spec_mz_value[spec_pointer])begin
	//		ds_score <= ds_score + pep_p_value[pep_pointer] * spec_i_value[spec_pointer];
			match_num0 <= match_num0 + 8'h1;
			match_en <= 1'b1;
			//pep next
			if(pep_pointer < 2'd3) begin
				pep_pointer <= pep_pointer + 5'b1;
			end
			else begin
				comp_done <= 1'b1;
				read_addr <= 5'b0;
			end

			//spec next
			if(spec_pointer < 5'd31 ) begin
				spec_pointer <= spec_pointer + 5'b1;
			end
			else if (spec_end) begin   //spec_end need to be define
				comp_done <= 1'b1;
				read_addr <= 5'b0;
			end
			else begin
 				spec_pointer <= 5'h0;
				spec_mz_tmp <= spec_mz_data;
				spec_i_tmp <= spec_i_data;
				read_addr <= read_addr + 5'b1;
			end
		end
		else if(pep_mz_value[pep_pointer] < spec_mz_value[spec_pointer]) begin
			match_en <= 1'b0;
			if(pep_pointer < 2'd3)
				pep_pointer <= pep_pointer + 2'b1;
			else begin
				comp_done <= 1'b1;
				read_addr <= 5'b0;
			end
		end
		else begin
			match_en <= 1'b0;
			if(spec_pointer < 5'd31 ) begin
				spec_pointer <= spec_pointer + 5'b1;
			end
			else if (spec_end) begin   //spec_end need to be define
				comp_done <= 1'b1;
				read_addr <= 5'b0;
			end
			else begin
 				spec_pointer <= 5'h0;
				spec_mz_tmp <= spec_mz_data;
				spec_i_tmp <= spec_i_data;
				read_addr <= read_addr + 5'b1;
			end			
		end
	end
	else if ((state == free) & ds_done) begin
		match_en <= 1'b0;
		comp_done <= 1'b0;
		read_addr <= 5'b0;
	end
end
wire match_calc;
assign match_calc = (state == comp) & (~comp_done) & (pep_mz_value[pep_pointer] == spec_mz_value[spec_pointer]);
mult_40_8 ds_x_calc(.CLK(clk), .A(spec_i_value[spec_pointer]), .B(pep_p_value[pep_pointer]), .CE(match_calc), .P(ds_score_tmp));

always @(posedge clk or posedge rst) begin
    if (rst) 
        ds_score <= 64'h0;
    else if ((state == init) &  start_r)
        ds_score <= 64'h0;
    else if (match_en) 
        ds_score <= ds_score + {16'h0, ds_score_tmp};
    else 
        ds_score <= ds_score;
end

endmodule


