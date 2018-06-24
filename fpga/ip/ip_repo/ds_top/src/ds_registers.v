
`timescale 1 ns / 1 ps

`include "ds_define.vh"

module ds_registers #
	(
		// Users to add parameters here

		// User parameters ends


		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 32,

		parameter integer PARA_WIDTH            = 32*32,

		parameter integer PARA_ADDR_WIDTH       = 5*32,

		parameter integer BASE_ADDR = 16'hB000


	)
	(
		// Users to add ports here
		input 	wire                                clk,
		// User ports ends

		// Do not modify the ports beyond this line

		// Global Clock Signal
		input 	wire  								S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input 	wire  								S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input	wire [C_S_AXI_ADDR_WIDTH-1 : 0]		S_AXI_AWADDR,
		//	input wire [2 : 0] 						S_AXI_AWPROT,
		input	wire  								S_AXI_AWVALID,
		output 	wire  								S_AXI_AWREADY,


		input	wire [C_S_AXI_DATA_WIDTH-1 : 0]		S_AXI_WDATA, 
		input 	wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]	S_AXI_WSTRB,
		input 	wire  								S_AXI_WVALID,
		output 	wire  								S_AXI_WREADY,

		output 	wire [1 : 0] 						S_AXI_BRESP,
		output 	wire  								S_AXI_BVALID,
		input 	wire  								S_AXI_BREADY,

		input 	wire [C_S_AXI_ADDR_WIDTH-1 : 0] 	S_AXI_ARADDR,
		input 	wire  								S_AXI_ARVALID,
		output 	wire  								S_AXI_ARREADY,

		output 	wire [C_S_AXI_DATA_WIDTH-1 : 0]		S_AXI_RDATA,
		output 	wire [1 : 0]						S_AXI_RRESP,
		output 	wire  								S_AXI_RVALID,
		input 	wire  								S_AXI_RREADY,


		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg0,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg1,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg2,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg3,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg4,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg5,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg6,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg7,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg8,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg9,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg10,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg11,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg12,
		output 	[C_S_AXI_DATA_WIDTH-1:0]			slv_reg13,

	`ifdef TIME_COUNT
		input   [C_S_AXI_DATA_WIDTH-1:0]			frag_time_reg,
		input   [C_S_AXI_DATA_WIDTH-1:0]			dot_time_reg,
	`endif

        input   [3 : 0]                             ds_state,
		input   [C_S_AXI_DATA_WIDTH-1:0]			package_num,

		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_x_cb,	
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_y_cb,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_z_cb,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_a_cb,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_b_cb,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_c_cb,

		output	[PARA_WIDTH-1 : 0]					rd_data_x_cb,
		output	[PARA_WIDTH-1 : 0]					rd_data_y_cb,
		output	[PARA_WIDTH-1 : 0]					rd_data_z_cb,
		output	[PARA_WIDTH-1 : 0]					rd_data_a_cb,
		output	[PARA_WIDTH-1 : 0]					rd_data_b_cb,
		output	[PARA_WIDTH-1 : 0]					rd_data_c_cb,
		
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_x_cb_2,	
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_y_cb_2,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_z_cb_2,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_a_cb_2,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_b_cb_2,
		input	[PARA_ADDR_WIDTH-1 : 0]				rd_addr_c_cb_2,

		output	[PARA_WIDTH-1 : 0]					rd_data_x_cb_2,
		output	[PARA_WIDTH-1 : 0]					rd_data_y_cb_2,
		output	[PARA_WIDTH-1 : 0]					rd_data_z_cb_2,
		output	[PARA_WIDTH-1 : 0]					rd_data_a_cb_2,
		output	[PARA_WIDTH-1 : 0]					rd_data_b_cb_2,
		output	[PARA_WIDTH-1 : 0]					rd_data_c_cb_2


	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  							axi_awready;
	reg  							axi_wready;
	reg [1 : 0] 					axi_bresp;
	reg  							axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  							axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 					axi_rresp;
	reg  							axi_rvalid;


	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 6;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 128

	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	//integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY		= axi_wready;
	assign S_AXI_BRESP		= axi_bresp;
	assign S_AXI_BVALID		= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA		= axi_rdata;
	assign S_AXI_RRESP		= axi_rresp;
	assign S_AXI_RVALID		= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
wire reg0_wen;   
wire reg1_wen;   
wire reg2_wen;   
wire reg3_wen;   
wire reg4_wen;   
wire reg5_wen;   
wire reg6_wen;   
wire reg7_wen;   
wire reg8_wen;   
wire reg9_wen;   
wire reg10_wen;  
wire reg11_wen;  
wire reg12_wen;  
wire reg13_wen;  


assign reg0_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h00); 
assign reg1_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h01); 
assign reg2_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h02); 
assign reg3_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h03); 
assign reg4_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h04); 
assign reg5_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h05); 
assign reg6_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h06); 
assign reg7_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h07); 
assign reg8_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h08); 
assign reg9_wen   = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h09); 
assign reg10_wen  = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h0a);
assign reg11_wen  = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h0b);
assign reg12_wen  = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h0c);
assign reg13_wen  = slv_reg_wren & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] == 7'h0d);


/** python code
for i in range(10):
	print('ds_register_syn reg%d' % (i))
	print('(')
	print('\t.data_in\t(S_AXI_WDATA),')
	print('\t.data_out\t(slv_reg%d),' % (i))
	print('\t.we\t(reg%d_wen),' % (i))
	print('\t.clk\t(S_AXI_ACLK),')
	print('\t.rst_n\t(S_AXI_ARESETN)')
	print(');')
*/

ds_register_syn reg0
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg0),
  .we 		(reg0_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);
ds_register_syn reg1
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg1),
  .we 		(reg1_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);
   
ds_register_syn reg2
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg2),
  .we 		(reg2_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);
   
ds_register_syn reg3
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg3),
  .we 		(reg3_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);

ds_register_syn reg4
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg4),
  .we 		(reg4_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);
	
ds_register_syn reg5
( 
  .data_in 	(S_AXI_WDATA),
  .data_out (slv_reg5),
  .we 		(reg5_wen),
  .clk 		(S_AXI_ACLK),
  .rst_n (S_AXI_ARESETN)
);

ds_register_syn reg6
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg6),
	.we	(reg6_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg7
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg7),
	.we	(reg7_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg8
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg8),
	.we	(reg8_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg9
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg9),
	.we		(reg9_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg10
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg10),
	.we	(reg10_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg11
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg11),
	.we	(reg11_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
);
ds_register_syn reg12
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg12),
	.we	(reg12_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
); 
ds_register_syn reg13
(
	.data_in	(S_AXI_WDATA),
	.data_out	(slv_reg13),
	.we	(reg13_wen),
	.clk	(S_AXI_ACLK),
	.rst_n	(S_AXI_ARESETN)
); 
	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= `AXI_RESP_OK; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= `AXI_RESP_OK; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        7'h00   : reg_data_out <= {slv_reg0[31:22], ds_state, slv_reg0[17:0]};
	        7'h01   : reg_data_out <= slv_reg1;
	        7'h02   : reg_data_out <= slv_reg2;
	        7'h03   : reg_data_out <= slv_reg3;
	        7'h04   : reg_data_out <= slv_reg4;
	        7'h05   : reg_data_out <= slv_reg5;
	        7'h06   : reg_data_out <= slv_reg6;
	        7'h07   : reg_data_out <= slv_reg7;
	        7'h08   : reg_data_out <= slv_reg8;
	        7'h09   : reg_data_out <= slv_reg9;
	        7'h0A   : reg_data_out <= slv_reg10;
	        7'h0B   : reg_data_out <= slv_reg11;
	        7'h0C   : reg_data_out <= slv_reg12; 
	        7'h0D   : reg_data_out <= slv_reg13; 
	        7'h0E 	: reg_data_out <= package_num;
	   `ifdef TIME_COUNT
	        7'h0F   : reg_data_out <= frag_time_reg;
	        7'h10   : reg_data_out <= dot_time_reg;
	   `endif
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        //	axi_rdata <= 32'h0;
	        end   
	    end
	end    

	// Add user logic here

/*---------------- calculation parameter storing --------------*/


wire  [6 : 0]			wr_addr;
wire                    wr_en;

assign   wr_en = slv_reg_wren & ((axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] > 7'hd) & (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] < 7'h28));
/**
	for i in range(14, 40):
	print ('7\'h%x : wr_addr = 7\'h%x;' % (i, (i-13)% 27 + 3 * (i-13)) )
	for i in range(40, 66):
	print ('7\'h%x : wr_addr = 7\'h%x;' % (i, (i-39)% 27 + 3 * (i-39) + 1) )
	for i in range(66, 92):
	print ('7\'h%x : wr_addr = 7\'h%x;' % (i, (i-65)% 27 + 3 * (i-65) + 2) )
	for i in range(92, 118):
	print ('7\'h%x : wr_addr = 7\'h%x;' % (i, (i-91)% 27 + 3 * (i-91) + 3) )
*/

assign  wr_addr = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] - 4'hd;

/*
always @(*) begin
	case(axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB]) 
		7'he  : wr_addr = 7'h4;
		7'hf  : wr_addr = 7'h8;
		7'h10 : wr_addr = 7'hc;
		7'h11 : wr_addr = 7'h10;
		7'h12 : wr_addr = 7'h14;
		7'h13 : wr_addr = 7'h18;
		7'h14 : wr_addr = 7'h1c;
		7'h15 : wr_addr = 7'h20;
		7'h16 : wr_addr = 7'h24;
		7'h17 : wr_addr = 7'h28;
		7'h18 : wr_addr = 7'h2c;
*/
/**
for i in range(2,32):
	print ('para_bram para_bram_x_%d' % (i))
	print ('\t(')
	print ('\t.clka 	(S_AXI_ACLK),\n\t.ena 	(wr_en),\n\t.wea 	(wr_en),\n\t.addra 	(wr_addr),\n\t.dina   (S_AXI_WDATA),\n\t.clkb 	(clk),\n\t.enb 	(~wr_en),\n\t.addrb  (rd_addr_x_%d),\n\t.doutb  (rd_data_x_%d)\n\t);' % (i,i))
*/

/*------------------------- for x type only -------------------------------------*/
wire [6 : 0] 			rd_addr_x[0 : 31];
wire [31 : 0]			rd_data_x[0 : 31];

generate
	genvar p_x;
	for(p_x = 0; p_x < 32; p_x = p_x + 1) begin
		assign rd_addr_x[p_x] = {2'b0, rd_addr_x_cb[5*p_x +: 5]};
		assign rd_data_x_cb[32*p_x +: 32] = rd_data_x[p_x];
		para_bram para_bram_x
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_x[p_x]),
    		.doutb  (rd_data_x[p_x])
 		);
	end
endgenerate


/*------------------------- for y type only -------------------------------------*/
wire [6 : 0] 			rd_addr_y[0 : 31];
wire [31 : 0]			rd_data_y[0 : 31];

generate
	genvar p_y;
	for(p_y = 0; p_y < 32; p_y = p_y + 1) begin
		assign 	rd_addr_y[p_y] ={2'b0, rd_addr_y_cb[5*p_y +: 5]};
		assign 	rd_data_y_cb[32*p_y +: 32] = rd_data_y[p_y];
		para_bram para_bram_y
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_y[p_y]),
    		.doutb  (rd_data_y[p_y])
 		);
	end
endgenerate


/*------------------------- for z type only -------------------------------------*/
wire [6 : 0] 			rd_addr_z[0 : 31];
wire [31 : 0]			rd_data_z[0 : 31];

generate
	genvar p_z;
	for(p_z = 0; p_z < 32; p_z = p_z + 1) begin
		assign rd_addr_z[p_z] = {2'b0, rd_addr_z_cb[5*p_z +: 5]};
		assign rd_data_z_cb[32*p_z +: 32] = rd_data_z[p_z];
		para_bram para_bram_z
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_z[p_z]),
    		.doutb  (rd_data_z[p_z])
 		);
	end
endgenerate



wire [6 : 0] 			rd_addr_a[0 : 31];
wire [31 : 0]			rd_data_a[0 : 31];

generate
	genvar p_a;
	for(p_a = 0; p_a < 32; p_a = p_a + 1) begin
		assign rd_addr_a[p_a] = {2'b0, rd_addr_a_cb[5*p_a +: 5]};
		assign rd_data_a_cb[32*p_a +: 32] = rd_data_a[p_a];
		para_bram para_bram_a
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_a[p_a]),
    		.doutb  (rd_data_a[p_a])
 		);
	end
endgenerate



wire [6 : 0] 			rd_addr_b[0 : 31];
wire [31 : 0]			rd_data_b[0 : 31];

generate
	genvar p_b;
	for(p_b = 0; p_b < 32; p_b = p_b + 1) begin
		assign rd_addr_b[p_b] = {2'b0, rd_addr_b_cb[5*p_b +: 5]};
		assign rd_data_b_cb[32*p_b +: 32] = rd_data_b[p_b];
		para_bram para_bram_b
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_b[p_b]),
    		.doutb  (rd_data_b[p_b])
 		);
	end
endgenerate


wire [6 : 0] 			rd_addr_c[0 : 31];
wire [31 : 0]			rd_data_c[0 : 31];

generate
	genvar p_c;
	for(p_c = 0; p_c < 32; p_c = p_c + 1) begin
		assign rd_addr_c[p_c] = {2'b0, rd_addr_c_cb[5*p_c +: 5]};
		assign rd_data_c_cb[32*p_c +: 32] = rd_data_c[p_c];
		para_bram para_bram_c
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_c[p_c]),
    		.doutb  (rd_data_c[p_c])
 		);
	end
endgenerate

/*------------------------- for x type only -------------------------------------*/
wire [6 : 0] 			rd_addr_x_2[0 : 31];
wire [31 : 0]			rd_data_x_2[0 : 31];

generate
	genvar p_x_2;
	for(p_x_2 = 0; p_x_2 < 32; p_x_2 = p_x_2 + 1) begin
		assign rd_addr_x_2[p_x_2] = {2'b0, rd_addr_x_cb_2[5*p_x_2 +: 5]};
		assign rd_data_x_cb_2[32*p_x_2 +: 32] = rd_data_x_2[p_x_2];
		para_bram para_bram_x_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_x_2[p_x_2]),
    		.doutb  (rd_data_x_2[p_x_2])
 		);
	end
endgenerate


/*------------------------- for y type only -------------------------------------*/
wire [6 : 0] 			rd_addr_y_2[0 : 31];
wire [31 : 0]			rd_data_y_2[0 : 31];

generate
	genvar p_y_2;
	for(p_y_2 = 0; p_y_2 < 32; p_y_2 = p_y_2 + 1) begin
		assign 	rd_addr_y_2[p_y_2] ={2'b0, rd_addr_y_cb_2[5*p_y_2 +: 5]};
		assign 	rd_data_y_cb_2[32*p_y_2 +: 32] = rd_data_y_2[p_y_2];
		para_bram para_bram_y_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_y_2[p_y_2]),
    		.doutb  (rd_data_y_2[p_y_2])
 		);
	end
endgenerate


/*------------------------- for z type only -------------------------------------*/
wire [6 : 0] 			rd_addr_z_2[0 : 31];
wire [31 : 0]			rd_data_z_2[0 : 31];

generate
	genvar p_z_2;
	for(p_z_2 = 0; p_z_2 < 32; p_z_2 = p_z_2 + 1) begin
		assign rd_addr_z_2[p_z_2] = {2'b0, rd_addr_z_cb_2[5*p_z_2 +: 5]};
		assign rd_data_z_cb_2[32*p_z_2 +: 32] = rd_data_z_2[p_z_2];
		para_bram para_bram_z_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_z_2[p_z_2]),
    		.doutb  (rd_data_z_2[p_z_2])
 		);
	end
endgenerate



wire [6 : 0] 			rd_addr_a_2[0 : 31];
wire [31 : 0]			rd_data_a_2[0 : 31];

generate
	genvar p_a_2;
	for(p_a_2 = 0; p_a_2 < 32; p_a_2 = p_a_2 + 1) begin
		assign rd_addr_a_2[p_a_2] = {2'b0, rd_addr_a_cb_2[5*p_a_2 +: 5]};
		assign rd_data_a_cb_2[32*p_a_2 +: 32] = rd_data_a_2[p_a_2];
		para_bram para_bram_a_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_a_2[p_a_2]),
    		.doutb  (rd_data_a_2[p_a_2])
 		);
	end
endgenerate



wire [6 : 0] 			rd_addr_b_2[0 : 31];
wire [31 : 0]			rd_data_b_2[0 : 31];

generate
	genvar p_b_2;
	for(p_b_2 = 0; p_b_2 < 32; p_b_2 = p_b_2 + 1) begin
		assign rd_addr_b_2[p_b_2] = {2'b0, rd_addr_b_cb_2[5*p_b_2 +: 5]};
		assign rd_data_b_cb_2[32*p_b_2 +: 32] = rd_data_b_2[p_b_2];
		para_bram para_bram_b_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_b_2[p_b_2]),
    		.doutb  (rd_data_b_2[p_b_2])
 		);
	end
endgenerate


wire [6 : 0] 			rd_addr_c_2[0 : 31];
wire [31 : 0]			rd_data_c_2[0 : 31];

generate
	genvar p_c_2;
	for(p_c_2 = 0; p_c_2 < 32; p_c_2 = p_c_2 + 1) begin
		assign rd_addr_c_2[p_c_2] = {2'b0, rd_addr_c_cb_2[5*p_c_2 +: 5]};
		assign rd_data_c_cb_2[32*p_c_2 +: 32] = rd_data_c_2[p_c_2];
		para_bram para_bram_c_2
  		(
    		.clka 	(S_AXI_ACLK),
    		.ena 	(wr_en),
    		.wea 	(wr_en),
    		.addra 	(wr_addr),
    		.dina   (S_AXI_WDATA),
    		.clkb 	(clk), 
    		.enb 	(~wr_en),
    		.addrb  (rd_addr_c_2[p_c_2]),
    		.doutb  (rd_data_c_2[p_c_2])
 		);
	end
endgenerate

endmodule
