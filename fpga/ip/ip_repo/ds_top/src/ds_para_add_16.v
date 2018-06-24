`timescale 1 ns / 1 ps
`include "ds_define.vh"

module ds_para_add_16 #(

	parameter	DATA_WIDTH 	= 32,		/* calculate base width*/
	parameter	CODE_WIDTH 	= 5,
	parameter	FORM_WIDTH 	= 32,    /* coeficient width*/
	parameter	GEN_TYPE 	= `A_TYPE

)(
	input                               clk,
	input                               rst,

	input   [511 : 0] 					para_chain,	
	input	[CODE_WIDTH * 16 - 1 : 0]	vadd,	
	input 								mass_type,
	input                               add_en,
  
/*------------accelerate interface-----------*/
	input	[47 : 0]					carry_in,
	input								prompt,        		// ds_ctrl[12]
	input								seq_mode, 			// ds_ctrl[13]

	output	 [47 : 0]					vout_0,
	output	 [47 : 0]					vout_1,
	output	 [47 : 0]					vout_2,
	output	 [47 : 0]					vout_3,
	output	 [47 : 0]					vout_4,
	output	 [47 : 0]					vout_5,
	output	 [47 : 0]					vout_6,
	output	 [47 : 0]					vout_7,
	output	 [47 : 0]					vout_8,
	output	 [47 : 0]					vout_9,
	output	 [47 : 0]					vout_10,
	output	 [47 : 0]					vout_11,
	output	 [47 : 0]					vout_12,
	output	 [47 : 0]					vout_13,
	output	 [47 : 0]					vout_14,
	output	 [47 : 0]					vout_15

);

wire	[FORM_WIDTH - 1 : 0]	AA_MASS		[0 : 26];
wire	[FORM_WIDTH - 1 : 0]	MOD_MASS	[0 : 15];
//wire	[FORM_WIDTH - 1 : 0]	FMOD_MASS	[0 : 15];
//wire	[FORM_WIDTH - 1 : 0]	PPT_MASS	[0 : 15];
//wire	[FORM_WIDTH - 1 : 0]	SMOD_MASS	[0 : 15];
//wire	[FORM_WIDTH - 1 : 0]	BASIC_MASS  [0 : 15];
wire    [47 : 0]                mass_tmp    [0 : 15];

assign	AA_MASS[0]  = 32'h0;
assign	AA_MASS[1]  = mass_type ? `Q_A_1 : `Q_A_0;
assign	AA_MASS[2]  = mass_type ? `Q_B_1 : `Q_B_0;
assign	AA_MASS[3]  = mass_type ? `Q_C_1 : `Q_C_0;
assign	AA_MASS[4]  = mass_type ? `Q_D_1 : `Q_D_0;
assign	AA_MASS[5]  = mass_type ? `Q_E_1 : `Q_E_0;
assign	AA_MASS[6]  = mass_type ? `Q_F_1 : `Q_F_0;
assign	AA_MASS[7]  = mass_type ? `Q_G_1 : `Q_G_0;
assign	AA_MASS[8]  = mass_type ? `Q_H_1 : `Q_H_0;
assign	AA_MASS[9]  = mass_type ? `Q_I_1 : `Q_I_0;
assign	AA_MASS[10] = mass_type ? `Q_J_1 : `Q_J_0;
assign	AA_MASS[11] = mass_type ? `Q_K_1 : `Q_K_0;
assign	AA_MASS[12] = mass_type ? `Q_L_1 : `Q_L_0;
assign	AA_MASS[13] = mass_type ? `Q_M_1 : `Q_M_0;
assign	AA_MASS[14] = mass_type ? `Q_N_1 : `Q_N_0;
assign	AA_MASS[15] = mass_type ? `Q_O_1 : `Q_O_0;
assign	AA_MASS[16] = mass_type ? `Q_P_1 : `Q_P_0;
assign	AA_MASS[17] = mass_type ? `Q_Q_1 : `Q_Q_0;
assign	AA_MASS[18] = mass_type ? `Q_R_1 : `Q_R_0;
assign	AA_MASS[19] = mass_type ? `Q_S_1 : `Q_S_0;
assign	AA_MASS[20] = mass_type ? `Q_T_1 : `Q_T_0;
assign	AA_MASS[21] = mass_type ? `Q_U_1 : `Q_U_0;
assign	AA_MASS[22] = mass_type ? `Q_V_1 : `Q_V_0;
assign	AA_MASS[23] = mass_type ? `Q_W_1 : `Q_W_0;
assign	AA_MASS[24] = mass_type ? `Q_X_1 : `Q_X_0;
assign	AA_MASS[25] = mass_type ? `Q_Y_1 : `Q_Y_0;
assign	AA_MASS[26] = mass_type ? `Q_Z_1 : `Q_Z_0;


generate
	genvar ii;
		for(ii = 0; ii < 16; ii = ii + 1) begin
			assign MOD_MASS[ii] = para_chain[32*ii +: 32];
			//assign FMOD_MASS[ii] = para_chain[128*ii+32 +: 32];
			//assign PPT_MASS[ii] = para_chain[128*ii+64 +: 32];
			//assign SMOD_MASS[ii] = para_chain[128*ii+96 +: 32];
			assign mass_tmp[ii] = MOD_MASS[ii] + AA_MASS[vadd[ii*5 +: 5]];
		end
endgenerate

/*
reg		[47 : 0]		mass_tmp [0 : 15];

integer index;
always @ (*)
begin
	case ({seq_mode, prompt})
	2'b00:
		for (index = 0; index < 16; index = index + 1) begin
			mass_tmp[index] =  BASIC_MASS[index];// AA_MASS[vadd[(index * 5) +: 5]] + MOD_MASS[vadd[(index * 5) +: 5]] + FMOD_MASS[vadd[(index * 5) +: 5]];
			end
	2'b01:
		for (index = 0; index < 16; index = index + 1) begin
			mass_tmp[index] =  BASIC_MASS[index] + PPT_MASS[index]; //AA_MASS[vadd[(index * 5) +: 5]] + MOD_MASS[vadd[(index * 5) +: 5]] + FMOD_MASS[vadd[(index * 5) +: 5]] + PPT_MASS[vadd[(index * 5) +: 5]];
			end	
	2'b10:
		for (index = 0; index < 16; index = index + 1) begin
			mass_tmp[index] =  BASIC_MASS[index] + SMOD_MASS[index]; //A AA_MASS[vadd[(index * 5) +: 5]] + MOD_MASS[vadd[(index * 5) +: 5]] + FMOD_MASS[vadd[(index * 5) +: 5]] + SMOD_MASS[vadd[(index * 5) +: 5]];
			end	
	2'b11:
		for (index = 0; index < 16; index = index + 1) begin
			mass_tmp[index] =  BASIC_MASS[index] + SMOD_MASS[index] + PPT_MASS[index];//AA_MASS[vadd[(index * 5) +: 5]] + MOD_MASS[vadd[(index * 5) +: 5]] + FMOD_MASS[vadd[(index * 5) +: 5]] + PPT_MASS[vadd[(index * 5) +: 5]] + SMOD_MASS[vadd[(index * 5) +: 5]];
			end	
	default:
		for (index = 0; index < 16; index = index + 1) begin
			mass_tmp[index] = 48'h0;
			end	
	endcase
end
*/


/*-------------- calculate value  -------------*/

	
reg  	[47 : 0]		layer1 [0 : 15];
wire	[47 : 0]		layer2 [0 : 7];
wire    [47 : 0] 		layer3 [0 : 7];
reg 	[47 : 0]		layer4 [0 : 15];

//--- calculate layer 1
/*
generate
	genvar i;
	for(i=0; i< 8; i=i+1) begin: calc_layer1
		assign layer1[i] = mass_tmp[2*i][47:0] + mass_tmp[2*i + 1][47:0];
	end
endgenerate
*/
always @(posedge clk or posedge rst) begin: calc_layer1
	if (rst) begin
		layer1[0] 	<= 48'h0;
		layer1[1] 	<= 48'h0;
		layer1[2] 	<= 48'h0;
		layer1[3] 	<= 48'h0;
		layer1[4] 	<= 48'h0;
		layer1[5] 	<= 48'h0;
		layer1[6] 	<= 48'h0;
		layer1[7] 	<= 48'h0;		
		layer1[8] 	<= 48'h0; 
		layer1[9] 	<= 48'h0;
		layer1[10]	<= 48'h0;
		layer1[11]	<= 48'h0;
		layer1[12]	<= 48'h0;
		layer1[13]	<= 48'h0;
		layer1[14]	<= 48'h0;
		layer1[15]	<= 48'h0;
	end
	else if (add_en) begin
		layer1[0] 	<= mass_tmp[0];
		layer1[1] 	<= mass_tmp[0] + mass_tmp[1];
		layer1[2] 	<= mass_tmp[2];
		layer1[3] 	<= mass_tmp[2] + mass_tmp[3];
		layer1[4] 	<= mass_tmp[4];
		layer1[5] 	<= mass_tmp[4] + mass_tmp[5];
		layer1[6] 	<= mass_tmp[6];
		layer1[7] 	<= mass_tmp[6] + mass_tmp[7];
		layer1[8] 	<= mass_tmp[8];
		layer1[9] 	<= mass_tmp[8] + mass_tmp[9];
		layer1[10]	<= mass_tmp[10];
		layer1[11]	<= mass_tmp[10] + mass_tmp[11];
		layer1[12]	<= mass_tmp[12];
		layer1[13]	<= mass_tmp[12] + mass_tmp[13];
		layer1[14]	<= mass_tmp[14];
		layer1[15]	<= mass_tmp[14] + mass_tmp[15];
	end
end

//--- calculate layer 2
/*
generate
	genvar j;
	for(j=0; j<4; j=j+1) begin: calc_layer2
		assign layer2[2*j]   = layer1[2*j] + layer1[4*j+2]; 
		assign layer2[2*j+1] = layer1[2*j] + layer1[2*j+1]; 
	end
endgenerate
*/
assign layer2[0] = layer1[1] + layer1[2];
assign layer2[1] = layer1[1] + layer1[3];
assign layer2[2] = layer1[5] + layer1[6];
assign layer2[3] = layer1[5] + layer1[7];
assign layer2[4] = layer1[9] + layer1[10];
assign layer2[5] = layer1[9] + layer1[11];
assign layer2[6] = layer1[13] + layer1[14];
assign layer2[7] = layer1[13] + layer1[15];
/*
always @(posedge clk or posedge rst) begin: calc_layer1
	if (rst) begin
		layer2[0] <= 48'h0;
		layer2[1] <= 48'h0;
		layer2[2] <= 48'h0;
		layer2[3] <= 48'h0;
		layer2[4] <= 48'h0;
		layer2[5] <= 48'h0;
		layer2[6] <= 48'h0;
		layer2[7] <= 48'h0;		
	end
	else if (add_en) begin
		layer2[0] <= layer1[0] + mass_tmp[2];
		layer2[1] <= layer1[0] + layer1[1];
		layer2[2] <= layer1[2] + mass_tmp[6];
		layer2[3] <= layer1[2] + layer1[3];
		layer2[4] <= layer1[4] + mass_tmp[10];
		layer2[5] <= layer1[4] + layer1[5];
		layer2[6] <= layer1[6] + mass_tmp[14];
		layer2[7] <= layer1[6] + layer1[7];
	end
end
*/
//--- calculate layer 3
assign layer3[0] = layer2[1] + layer1[4];
assign layer3[1] = layer2[1] + layer1[5];
assign layer3[2] = layer2[1] + layer2[2];
assign layer3[3] = layer2[1] + layer2[3];
assign layer3[4] = layer2[5] + layer1[12];
assign layer3[5] = layer2[5] + layer1[13];
assign layer3[6] = layer2[5] + layer2[6];
assign layer3[7] = layer2[5] + layer2[7];
/*
generate
	genvar k;
	for(k=0; k<2; k=k+1) begin: calc_layer3
		assign layer3[4*k]   = layer2[4*k+1] + layer1[8*k+4];
		assign layer3[4*k+1] = layer2[4*k+1] + layer1[4*k+2];
		assign layer3[4*k+2] = layer2[4*k+1] + layer2[4*k+2];
		assign layer3[4*k+3] = layer2[4*k+1] + layer2[4*k+3];
	end
endgenerate
*/
//generate
//	genvar k;
//	for(k=0; k<2; k=k+1) begin: calc_layer3
//		add_dsp add_dsp_0(.A(layer2[4*k+1][47:0]), .B(layer1[8*k+4][47:0]), .CLK(clk), .S(layer3[4*k]));
//		add_dsp add_dsp_1(.A(layer2[4*k+1][47:0]), .B(layer1[4*k+2][47:0]), .CLK(clk), .S(layer3[4*k+1]));
//		add_dsp add_dsp_2(.A(layer2[4*k+1][47:0]), .B(layer2[4*k+2][47:0]), .CLK(clk), .S(layer3[4*k+2]));
//		add_dsp add_dsp_3(.A(layer2[4*k+1][47:0]), .B(layer2[4*k+3][47:0]), .CLK(clk), .S(layer3[4*k+3]));
//	end
//endgenerate

//reg  [47 : 0]  layer_reg_1 [0 : 7];
/*
always @(posedge clk or posedge rst) begin
	if (rst) begin
		layer3 [0]  <= 48'h0;
		layer3 [1]  <= 48'h0;
		layer3 [2]  <= 48'h0;
		layer3 [3]  <= 48'h0;
		layer3 [4]  <= 48'h0;
		layer3 [5]  <= 48'h0;
		layer3 [6]  <= 48'h0;
		layer3 [7]  <= 48'h0;
		layer3 [8] 	<= 48'h0; 
		layer3 [9] 	<= 48'h0;
		layer3 [10]	<= 48'h0;
		layer3 [11]	<= 48'h0;
		layer3 [12]	<= 48'h0;
		layer3 [13]	<= 48'h0;
		layer3 [14]	<= 48'h0;
		layer3 [15]	<= 48'h0;
	end
	else if (add_en) begin
		layer3 [0] <= layer1[0];
		layer3 [1] <= layer1[1];
		layer3 [2] <= layer2[0];
		layer3 [3] <= layer2[1];
		layer3 [4] <= layer2[1] + layer1[4];
		layer3 [5] <= layer2[1] + layer1[5];
		layer3 [6] <= layer2[1] + layer2[2];
		layer3 [7] <= layer2[1] + layer2[3];
		layer3 [8] 	<= layer1[8]; 
		layer3 [9] 	<= layer1[9];
		layer3 [10]	<= layer2[4];
		layer3 [11]	<= layer2[5];
		layer3 [12]	<= layer2[5] + layer1[12];
		layer3 [13]	<= layer2[5] + layer1[13];
		layer3 [14]	<= layer2[5] + layer2[6];
		layer3 [15]	<= layer2[5] + layer2[7];
	end
end
*/

//--- calculate layer 4
always @(posedge clk or posedge rst) begin
	if (rst) begin
		layer4[0] <= 48'h0;
		layer4[1] <= 48'h0;
		layer4[2] <= 48'h0;
		layer4[3] <= 48'h0;
		layer4[4] <= 48'h0;
		layer4[5] <= 48'h0;
		layer4[6] <= 48'h0;
		layer4[7] <= 48'h0;
		layer4[8] <= 48'h0;
		layer4[9] <= 48'h0;
		layer4[10] <= 48'h0;
		layer4[11] <= 48'h0;
		layer4[12] <= 48'h0;
		layer4[13] <= 48'h0;
		layer4[14] <= 48'h0;
		layer4[15] <= 48'h0;
	end
	else if (add_en) begin
		layer4[0] <= layer1[0];
		layer4[1] <= layer1[1];
		layer4[2] <= layer2[0];
		layer4[3] <= layer2[1];
		layer4[4] <= layer3[0];
		layer4[5] <= layer3[1];
		layer4[6] <= layer3[2];
		layer4[7] <= layer3[3];
		layer4[8] <= layer3[3] + layer1[8];
		layer4[9] <= layer3[3] + layer1[9];
		layer4[10] <= layer3[3] + layer2[4];
		layer4[11] <= layer3[3] + layer2[5];
		layer4[12] <= layer3[3] + layer3[4];
		layer4[13] <= layer3[3] + layer3[5];
		layer4[14] <= layer3[3] + layer3[6];
		layer4[15] <= layer3[3] + layer3[7];		
	end
end
//assign layer4[0] = layer3[7] + layer3[8];
//assign layer4[1] = layer3[7] + layer3[9];
//assign layer4[2] = layer3[7] + layer3[10];
//assign layer4[3] = layer3[7] + layer3[11];
//assign layer4[4] = layer3[7] + layer3[12];
//assign layer4[5] = layer3[7] + layer3[13];
//assign layer4[6] = layer3[7] + layer3[14];
//assign layer4[7] = layer3[7] + layer3[15];

/*
assign vout_0  = carry_in +  layer_reg_1[0];
assign vout_1  = carry_in +  layer_reg_1[1];
assign vout_2  = carry_in +  layer_reg_1[2];
assign vout_3  = carry_in +  layer_reg_1[3];
assign vout_4  = carry_in +  layer3[0];
assign vout_5  = carry_in +  layer3[1];
assign vout_6  = carry_in +  layer3[2];
assign vout_7  = carry_in +  layer3[3];
assign vout_8  = carry_in +  layer4[0];
assign vout_9  = carry_in +  layer4[1];
assign vout_10 = carry_in +  layer4[2];
assign vout_11 = carry_in +  layer4[3];
assign vout_12 = carry_in +  layer4[4];
assign vout_13 = carry_in +  layer4[5];
assign vout_14 = carry_in +  layer4[6];
assign vout_15 = carry_in +  layer4[7];
*/

assign 	vout_0  = carry_in + layer4[0];
assign 	vout_1  = carry_in + layer4[1];
assign 	vout_2  = carry_in + layer4[2];
assign 	vout_3  = carry_in + layer4[3];
assign 	vout_4  = carry_in + layer4[4];
assign 	vout_5  = carry_in + layer4[5];
assign 	vout_6  = carry_in + layer4[6];
assign 	vout_7  = carry_in + layer4[7];
assign 	vout_8  = carry_in + layer4[8];
assign 	vout_9  = carry_in + layer4[9];
assign 	vout_10 = carry_in + layer4[10];
assign 	vout_11 = carry_in + layer4[11];
assign 	vout_12 = carry_in + layer4[12];
assign 	vout_13 = carry_in + layer4[13];
assign 	vout_14 = carry_in + layer4[14];
assign 	vout_15 = carry_in + layer4[15];		



endmodule
