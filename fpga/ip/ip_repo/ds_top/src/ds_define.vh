
// This file contains the defination of parameters used in dot-score function block

`define     TIME_COUNT

`define 	AXI_RESP_OK			2'b00
`define  	AXI_RESP_SLVERR		2'b10
`define 	IS_DALTON         1'b0  
`define 	IS_PPM            1'b1  

`define		A_TYPE  1
`define		B_TYPE	2
`define		C_TYPE	3
`define		X_TYPE	4
`define		Y_TYPE	5
`define		Z_TYPE 	6

//*------------------ Amino Acids quality defination ------------------*//
//----- mass_type = 1 ----//

`define 	Q_A_1 	32'h4709805    // Format 32(Q20)
`define 	Q_B_1 	32'h720AFD5
`define 	Q_C_1 	32'h670259F
`define 	Q_D_1 	32'h7306E5C
`define 	Q_E_1 	32'h810AE76
`define 	Q_F_1 	32'h9311839
`define 	Q_G_1 	32'h39057EA
`define 	Q_H_1 	32'h890F14E
`define 	Q_I_1 	32'h7115854
`define 	Q_J_1 	32'h0
`define 	Q_K_1 	32'h80184F8
`define 	Q_L_1 	32'h7115854
`define 	Q_M_1 	32'h830A5D3
`define 	Q_N_1 	32'h720AFD5
`define 	Q_O_1 	32'hFF2885D
`define 	Q_P_1 	32'h610D81F
`define 	Q_Q_1 	32'h800EFEF
`define 	Q_R_1 	32'h9C19E27
`define 	Q_S_1 	32'h5708330
`define 	Q_T_1 	32'h650C34B
`define 	Q_U_1 	32'h96F4216
`define 	Q_V_1 	32'h6311839
`define 	Q_W_1 	32'hBA144DE
`define 	Q_X_1 	32'h0
`define 	Q_Y_1 	32'hA310365
`define 	Q_Z_1 	32'h800EFEF


//----- mass_type = 0 ----//

`define 	Q_A_0 	32'h47142C4
`define 	Q_B_0 	32'h721A92A
`define 	Q_C_0 	32'h6723886
`define 	Q_D_0 	32'h7316AE8
`define 	Q_E_0 	32'h811D917
`define 	Q_F_0 	32'h932D35B
`define 	Q_G_0 	32'h390D495
`define 	Q_H_0 	32'h89241F2
`define 	Q_I_0 	32'h7128CE7
`define 	Q_J_0 	32'h0
`define 	Q_K_0 	32'h802C91D
`define 	Q_L_0 	32'h7128CE7
`define 	Q_M_0 	32'h83314E4
`define 	Q_N_0 	32'h721A92A
`define 	Q_O_0 	32'hED4F5C3
`define 	Q_P_0 	32'h611DE01
`define 	Q_Q_0 	32'h8021759
`define 	Q_R_0 	32'h9C30000
`define 	Q_S_0 	32'h571404F
`define 	Q_T_0 	32'h651AE7D
`define 	Q_U_0 	32'h9608659
`define 	Q_V_0 	32'h6321F21
`define 	Q_W_0 	32'hBA36944
`define 	Q_X_0 	32'h0
`define 	Q_Y_0 	32'hA32D0E5
`define 	Q_Z_0 	32'h8021759
//*--------------- End: Amino Acids quality defination ---------------*//


//*--------------- Other internal paramter defination-----------------*//

//----- mass_type = 1 ----//

`define 	M_CLEAVE_C_DEFAULT_1 	32'h1100B39
`define 	M_CLEAVE_N_DEFAULT_1 	32'h10200D
`define 	M_PROTON_1 				32'h101DCD
`define 	M_HYDROGEN_1 			32'h10200D
`define 	M_A_1 					32'hFE4014D4   // M_A_1 < 0, complement format
`define 	M_B_1 					32'h0
`define 	M_C_1 					32'h1106CBF
`define 	M_X_1 					32'h2BFD657
`define 	M_Y_1 					32'h1202B46
`define 	M_Z_1 					32'h1FDE94


//----- mass_type = 0 ----//
`define 	M_CLEAVE_C_DEFAULT_0	32'h1101E11
`define 	M_CLEAVE_N_DEFAULT_0	32'h102086
`define 	M_PROTON_0 				32'h101DCD
`define 	M_HYDROGEN_0 			32'h10200D
`define 	M_A_0 					32'hFE3FD6A1
`define 	M_B_0 					32'h0
`define 	M_C_0 					32'h1107D03
`define 	M_X_0 					32'h2C026E9
`define 	M_Y_0 					32'h1203E96
`define 	M_Z_0 					32'h1FE219

//*--------------- End: Other internal paramter defination-----------------*//

