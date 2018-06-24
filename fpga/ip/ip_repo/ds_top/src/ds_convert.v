
module ds_convert #(

	parameter  integer  DATA_WIDTH = 5
)(
	input 	[DATA_WIDTH*32 - 1 : 0] 	data_in,
	output	[DATA_WIDTH*32 - 1 : 0] 	data_out
);

assign data_out = {

	data_in [DATA_WIDTH*1 - 1 : 0],
	data_in [DATA_WIDTH*2 - 1 : DATA_WIDTH*1],
	data_in [DATA_WIDTH*3 - 1 : DATA_WIDTH*2],
	data_in [DATA_WIDTH*4 - 1 : DATA_WIDTH*3],
	data_in [DATA_WIDTH*5 - 1 : DATA_WIDTH*4],
	data_in [DATA_WIDTH*6 - 1 : DATA_WIDTH*5],
	data_in [DATA_WIDTH*7 - 1 : DATA_WIDTH*6],
	data_in [DATA_WIDTH*8 - 1 : DATA_WIDTH*7],
	data_in [DATA_WIDTH*9 - 1 : DATA_WIDTH*8],
	data_in [DATA_WIDTH*10 - 1 : DATA_WIDTH*9],
	data_in [DATA_WIDTH*11 - 1 : DATA_WIDTH*10],
	data_in [DATA_WIDTH*12 - 1 : DATA_WIDTH*11],
	data_in [DATA_WIDTH*13 - 1 : DATA_WIDTH*12],
	data_in [DATA_WIDTH*14 - 1 : DATA_WIDTH*13],
	data_in [DATA_WIDTH*15 - 1 : DATA_WIDTH*14],
	data_in [DATA_WIDTH*16 - 1 : DATA_WIDTH*15],
	data_in [DATA_WIDTH*17 - 1 : DATA_WIDTH*16],
	data_in [DATA_WIDTH*18 - 1 : DATA_WIDTH*17],
	data_in [DATA_WIDTH*19 - 1 : DATA_WIDTH*18],
	data_in [DATA_WIDTH*20 - 1 : DATA_WIDTH*19],
	data_in [DATA_WIDTH*21 - 1 : DATA_WIDTH*20],
	data_in [DATA_WIDTH*22 - 1 : DATA_WIDTH*21],
	data_in [DATA_WIDTH*23 - 1 : DATA_WIDTH*22],
	data_in [DATA_WIDTH*24 - 1 : DATA_WIDTH*23],
	data_in [DATA_WIDTH*25 - 1 : DATA_WIDTH*24],
	data_in [DATA_WIDTH*26 - 1 : DATA_WIDTH*25],
	data_in [DATA_WIDTH*27 - 1 : DATA_WIDTH*26],
	data_in [DATA_WIDTH*28 - 1 : DATA_WIDTH*27],
	data_in [DATA_WIDTH*29 - 1 : DATA_WIDTH*28],
	data_in [DATA_WIDTH*30 - 1 : DATA_WIDTH*29],
	data_in [DATA_WIDTH*31 - 1 : DATA_WIDTH*30],
	data_in [DATA_WIDTH*32 - 1 : DATA_WIDTH*31]

};

endmodule