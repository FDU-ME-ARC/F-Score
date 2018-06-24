`timescale 1ns / 1ps

module ds_spec_store #    // pep chain store
	(
		parameter integer	DATA_WIDTH = 32,
		parameter integer	BRAM_DEPTH = 32
	)
	(
		input 	wire 			clk,
		input 	wire 			rst,

		/* bram write interface */
		input 	wire 							spec_valid,      // @(posedge) pep_ready <= (state == INIT) & pep_valid & parent_mass_match;  
		input   wire    [255 : 0] 				spec_data,
		input 	wire  	[31 : 0]		        spec_keep,
		input 	wire  							spec_last,
		input 	wire  	[15 : 0]				spec_len,
        input   wire    [4 : 0]                 spec_z_charge,

		output 	reg 	[15:0]					spec_length,
        output  reg     [4 : 0]                 spec_z_charge_r,
		/* bram read interface*/
		input 	wire 	[4:0]							read_addr_0,
		input 	wire 	[4:0]							read_addr_1,
		input 	wire 	[4:0]							read_addr_2,
		input 	wire 	[4:0]							read_addr_3,
		input 	wire 	[4:0]							read_addr_4,
        input   wire    [4:0]                           read_addr_4_1,    // for spec_z_charge = 1
		input 	wire 	[4:0]							read_addr_5, 

		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_0,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_0,
		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_1,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_1,
		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_2,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_2,
 		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_3,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_3,
 		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_4,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_4,
        output  wire    [20 * DATA_WIDTH - 1 : 0]       data_mz_out_4_1,  // for spec_z_charge = 1
        output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_4_1,
 		output 	wire 	[20 * DATA_WIDTH - 1 : 0]	 	data_mz_out_5,
		output  wire    [40 * DATA_WIDTH - 1 : 0]        data_i_out_5 
 
	);


	reg [7 : 0]	write_addr;

always @(posedge clk or posedge rst)
begin
	if(rst)
		write_addr <= 8'b0;
	else if (spec_last)
		write_addr <= 8'b0;
	else if (~spec_last & spec_valid)
		write_addr <= write_addr + 1;
	else 
		write_addr <= write_addr;
end


always @(posedge clk or posedge rst)
begin
	if(rst)
		spec_length <= 16'h0;
	else if (spec_valid)
		spec_length <= spec_len;
	else 
		spec_length <= spec_length;
end


always @(posedge clk or posedge rst) begin
    if (rst)
        spec_z_charge_r <= 5'b0;
    else if (spec_valid)
        spec_z_charge_r <= spec_z_charge;
    else
        spec_z_charge_r <= spec_z_charge_r;
end


wire   	[40 * 4 - 1 : 0]     spec_i_data;
wire   	[20 * 4 - 1 : 0] 	 spec_mz_data;
wire    [8 * DATA_WIDTH - 1 : 0]     spec_data_r;
wire    [8 * DATA_WIDTH - 1 : 0]     spec_data_w;

generate
    genvar i;
    for (i = 0; i < DATA_WIDTH; i = i+1)
        assign spec_data_w[i*8 +: 8] = spec_keep[i] ? spec_data[i*8 +: 8] : 8'h0;
endgenerate

ds_convert_64 #(.DATA_WIDTH(8)) spec_convert(.data_in(spec_data_w), . data_out(spec_data_r));

assign 	spec_i_data = {spec_data_r[231 : 192], spec_data_r[167 : 128], spec_data_r[103 : 64], spec_data_r[39 : 0]};
assign 	spec_mz_data = {spec_data_r[251 : 232], spec_data_r[187 : 168], spec_data_r[123 : 104], spec_data_r[59 : 40]};

spec_mz_bram spec_mz_store_bram_a    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_0),     // [4 : 0]
    .doutb (data_mz_out_0)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_a    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_0),     // [4 : 0]
    .doutb (data_i_out_0)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_b    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_1),     // [4 : 0]
    .doutb (data_mz_out_1)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_b   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_1),     // [4 : 0]
    .doutb (data_i_out_1)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_c    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_2),     // [4 : 0]
    .doutb (data_mz_out_2)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_c   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_2),     // [4 : 0]
    .doutb (data_i_out_2)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_x    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_3),     // [4 : 0]
    .doutb (data_mz_out_3)    // [20 * 32 - 1 : 0]
); 
spec_i_bram spec_i_store_bram_x   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_3),     // [4 : 0]
    .doutb (data_i_out_3)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_y    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_4),     // [4 : 0]
    .doutb (data_mz_out_4)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_y   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_4),     // [4 : 0]
    .doutb (data_i_out_4)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_z    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_5),     // [4 : 0]
    .doutb (data_mz_out_5)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_z   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_5),     // [4 : 0]
    .doutb (data_i_out_5)     // [40 * 32 - 1 : 0]
);

spec_mz_bram spec_mz_store_bram_y_1    //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_mz_data),   // [20 * 4 - 1 : 0]
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_4_1),     // [4 : 0]
    .doutb (data_mz_out_4_1)    // [20 * 32 - 1 : 0]
);
spec_i_bram spec_i_store_bram_y_1   //NO_CHANGE MODE 
(
    .clka(clk),
    .ena (spec_valid),
    .wea (spec_valid),
    .addra (write_addr),    // [7 : 0]
    .dina (spec_i_data),    // [40 * 4 - 1 : 0] 
    .clkb (clk),
    .enb (~spec_valid),
    .addrb (read_addr_4_1),     // [4 : 0]
    .doutb (data_i_out_4_1)     // [40 * 32 - 1 : 0]
);


endmodule

