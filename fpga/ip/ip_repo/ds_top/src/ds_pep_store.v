
`timescale 1 ns / 1 ps

module ds_pep_store #    // pep chain store
	(
		parameter integer	DATA_WIDTH = 32,
		parameter integer	BRAM_DEPTH = 32
	)
	(
		input 	wire 			clk,
		input 	wire 			rst,
	
		//input 	wire 			restore,
		//input 	wire 			restore,

		/* bram write interface */
		//input wire							recv_begin,  //recv_begin = pep_valid & frag_gen_idle & ; 
		input 	wire 							pep_valid,      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
		input 	wire	[5 * DATA_WIDTH-1:0]	pep_data,
		input 	wire  	[DATA_WIDTH-1:0]		pep_keep,
		input 	wire  							pep_last,
	//	input 	wire  	[15:0]					pep_len,

	//	output 	reg 	[15:0]					pep_length,

		/* bram read interface*/
		input 	wire 	[4:0]					read_addr_x,
		input 	wire 	[4:0]					read_addr_y,
		input 	wire 	[4:0]					read_addr_z,
		input 	wire 	[4:0]					read_addr_a,
		input 	wire 	[4:0]					read_addr_b,
		input 	wire 	[4:0]					read_addr_c,


		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_x,
		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_y,
		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_z,
		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_a,
		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_b,
		output 	wire 	[5 * DATA_WIDTH-1:0]	 	data_out_c
		
	);


reg [4:0]	write_addr;

wire [5 * DATA_WIDTH-1 : 0]              pep_data_w;
generate
    genvar i;
    for (i = 0 ; i < DATA_WIDTH; i = i + 1)begin
        assign pep_data_w[5*i +: 5] = pep_keep[i] ? pep_data[5*i +: 5] : 5'h0;
    end
endgenerate


always @(posedge clk or posedge rst)
begin
	if(rst)
		write_addr <= 5'b0;
	else if (pep_last)
		write_addr <= 5'b0;
	else if ((~pep_last) & pep_valid)
		write_addr <= write_addr + 1;
	else 
		write_addr <= write_addr;
end


//always @(posedge clk or posedge rst)
//begin
//	if(rst)
//		pep_length <= 16'h0;
//	else if (pep_valid)
//		pep_length <= pep_len;
//	else 
//		pep_length <= pep_length;
//end



pep_store_bram pep_store_bram_x    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_x),         // [4 : 0]
    .doutb (data_out_x)           // [159 : 0]
);

pep_store_bram pep_store_bram_y    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_y),         // [4 : 0]
    .doutb (data_out_y)           // [159 : 0]
);
pep_store_bram pep_store_bram_z    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_z),         // [4 : 0]
    .doutb (data_out_z)           // [159 : 0]
);
pep_store_bram pep_store_bram_a    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_a),         // [4 : 0]
    .doutb (data_out_a)           // [159 : 0]
);
pep_store_bram pep_store_bram_b    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_b),         // [4 : 0]
    .doutb (data_out_b)           // [159 : 0]
);
pep_store_bram pep_store_bram_c    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (pep_valid),
    .wea (pep_valid),
    .addra (write_addr),        // [4 : 0]
    .dina (pep_data_w),           // [159 : 0]  
    .clkb (clk),
    .enb (~pep_valid),
    .addrb (read_addr_c),         // [4 : 0]
    .doutb (data_out_c)           // [159 : 0]
);


endmodule