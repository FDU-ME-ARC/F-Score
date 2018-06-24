module cache_half
#(
parameter REQ_ADDR_WIDTH = 32,
parameter REQ_LENG_WIDTH = 32,
parameter REQ_DATA_WIDTH = 512,
parameter RSP_ADDR_WIDTH = 16,
parameter RSP_DATA_WIDTH = REQ_DATA_WIDTH,
parameter RD_ADDR_WIDTH  = 32,
parameter CACHE_WIDTH    = 2,
parameter CACHE_SIZE     = 4
)
(
input  wire  mem_clk,
input  wire  usr_clk,
input  wire  dma_clk,
input  wire  rst,

//Prefetch Interface
input  wire [REQ_ADDR_WIDTH-1:0]   prefetch_address,
input  wire [REQ_LENG_WIDTH-1:0]   prefetch_length,
input  wire                        prefetch_valid,
output wire                        prefetch_ready,

//Memory Interface
output wire [REQ_ADDR_WIDTH-1:0]   s_axis_raddr,
output wire [REQ_LENG_WIDTH-1:0]   s_axis_rlen,
output wire                        s_axis_rreq,
input  wire                        s_axis_rack,

input  wire [REQ_DATA_WIDTH-1:0]   s_axis_data,
input  wire [REQ_DATA_WIDTH/8-1:0] s_axis_keep,
input  wire                        s_axis_valid,
input  wire                        s_axis_last,
output wire                        s_axis_ready,

//Read
input  wire [RD_ADDR_WIDTH-1:0]    extract_address,
input  wire [10:0]                  extract_pointer,
output wire                        extract_valid,
input  wire                        extract_ready,
output wire [REQ_DATA_WIDTH*5/16-1:0] extract_data,

//Clear
input  wire [RD_ADDR_WIDTH-1:0]    clear_address,
input  wire                        clear_valid

);

//Response Interface
wire [RSP_DATA_WIDTH-1:0]   response_data;
wire [RSP_ADDR_WIDTH-1:0]   response_pointer;
wire                        response_valid;
wire                        response_last;
wire                        response_ready;
wire [REQ_ADDR_WIDTH-1:0]     response_address;
wire [REQ_LENG_WIDTH-1:0]     response_length;

wire                        request_permit;
wire [REQ_ADDR_WIDTH-1:0]   request_address;
wire [REQ_LENG_WIDTH-1:0]   request_length;
wire                        request_valid;
reg                         request_valid_hold;
wire                        request_ready;

wire                        prefetch_empty;
wire                        prefetch_full;
wire [511:0]                s_axis_data_rev;
wire [REQ_ADDR_WIDTH+REQ_LENG_WIDTH-1:0] prefetch_data_out;

wire [CACHE_WIDTH-1:0]      read_pointer;
wire [CACHE_WIDTH-1:0]      write_pointer;
wire [REQ_DATA_WIDTH*5/8-1:0]  response_data_sample;

assign request_address = prefetch_data_out[REQ_LENG_WIDTH+:REQ_ADDR_WIDTH];
assign request_length  = prefetch_data_out[0+:REQ_LENG_WIDTH];
assign prefetch_ready  = prefetch_full;

wire [11:0] ram_wr_address; assign ram_wr_address = {write_pointer,response_pointer[9:0]};
wire [12:0] ram_rd_address; assign ram_rd_address = {read_pointer,extract_pointer[10:0]};


//assign s_axis_data_rev = {s_axis_data[255:0],s_axis_data[511:256]}; //ymc
assign s_axis_data_rev = s_axis_data;

assign response_ready = 1'b1;
cache_dma 
#(
.REQ_ADDR_WIDTH(32),
.REQ_LENG_WIDTH(32),
.REQ_DATA_WIDTH(512),
.RSP_ADDR_WIDTH(RSP_ADDR_WIDTH),
.RSP_DATA_WIDTH(REQ_DATA_WIDTH)
)
cache_dma_i
(
.clk(mem_clk),
.rst(rst),
.request_permit(request_permit),
.request_address(request_address),
.request_length(request_length),
.request_valid(request_valid | request_valid_hold),
.request_ready(request_ready),

.s_axis_raddr(s_axis_raddr),
.s_axis_rlen(s_axis_rlen),
.s_axis_rreq(s_axis_rreq),
.s_axis_rack(s_axis_rack),
.s_axis_data(s_axis_data_rev),
.s_axis_keep(s_axis_keep),
.s_axis_valid(s_axis_valid),
.s_axis_last(s_axis_last),
.s_axis_ready(s_axis_ready),

.response_data(response_data),
.response_pointer(response_pointer),
.response_valid(response_valid),
.response_last(response_last),
.response_ready(response_ready),
.response_address(response_address),
.response_length(response_length)
);

cache_table 
#(
.RD_ADDR_WIDTH(32),
.CACHE_WIDTH(2),
.CACHE_SIZE(4)
)
cache_table_i
(
.clk(mem_clk),
.rst(rst),
.read_address(extract_address),
.read_pointer(read_pointer),
.read_valid(extract_valid),
.write_address(response_address),
.write_valid(response_valid & response_last & response_ready),
.write_pointer(write_pointer),
.clear_address(clear_address),
.clear_valid(clear_valid),
.table_vaccant(request_permit)
);

fifo_async_fwft_512 
cache_queue
(
.rd_clk(mem_clk),
.wr_clk(dma_clk),
.rst(rst),
.din({prefetch_address,prefetch_length}),
.wr_en(prefetch_valid),
.full(prefetch_full),
.empty(prefetch_empty),
.dout(prefetch_data_out),
.rd_en(request_ready),
.valid(request_valid)
);

bram_320_160_16384
cache_ram
(
.clka(mem_clk),
.addra(ram_wr_address),
.dina(response_data_sample),
.ena(response_valid & response_ready),
.wea(1'b1),
.clkb(mem_clk),
.addrb(ram_rd_address),
.doutb(extract_data),
.enb(extract_ready)
);

assign response_data_sample = 
{
response_data[64 * 8 - 4 :63 * 8],
response_data[63 * 8 - 4 :62 * 8],
response_data[62 * 8 - 4 :61 * 8],
response_data[61 * 8 - 4 :60 * 8],
response_data[60 * 8 - 4 :59 * 8],
response_data[59 * 8 - 4 :58 * 8],
response_data[58 * 8 - 4 :57 * 8],
response_data[57 * 8 - 4 :56 * 8],
response_data[56 * 8 - 4 :55 * 8],
response_data[55 * 8 - 4 :54 * 8],
response_data[54 * 8 - 4 :53 * 8],
response_data[53 * 8 - 4 :52 * 8],
response_data[52 * 8 - 4 :51 * 8],
response_data[51 * 8 - 4 :50 * 8],
response_data[50 * 8 - 4 :49 * 8],
response_data[49 * 8 - 4 :48 * 8],
response_data[48 * 8 - 4 :47 * 8],
response_data[47 * 8 - 4 :46 * 8],
response_data[46 * 8 - 4 :45 * 8],
response_data[45 * 8 - 4 :44 * 8],
response_data[44 * 8 - 4 :43 * 8],
response_data[43 * 8 - 4 :42 * 8],
response_data[42 * 8 - 4 :41 * 8],
response_data[41 * 8 - 4 :40 * 8],
response_data[40 * 8 - 4 :39 * 8],
response_data[39 * 8 - 4 :38 * 8],
response_data[38 * 8 - 4 :37 * 8],
response_data[37 * 8 - 4 :36 * 8],
response_data[36 * 8 - 4 :35 * 8],
response_data[35 * 8 - 4 :34 * 8],
response_data[34 * 8 - 4 :33 * 8],
response_data[33 * 8 - 4 :32 * 8],
response_data[32 * 8 - 4 :31 * 8],
response_data[31 * 8 - 4 :30 * 8],
response_data[30 * 8 - 4 :29 * 8],
response_data[29 * 8 - 4 :28 * 8],
response_data[28 * 8 - 4 :27 * 8],
response_data[27 * 8 - 4 :26 * 8],
response_data[26 * 8 - 4 :25 * 8],
response_data[25 * 8 - 4 :24 * 8],
response_data[24 * 8 - 4 :23 * 8],
response_data[23 * 8 - 4 :22 * 8],
response_data[22 * 8 - 4 :21 * 8],
response_data[21 * 8 - 4 :20 * 8],
response_data[20 * 8 - 4 :19 * 8],
response_data[19 * 8 - 4 :18 * 8],
response_data[18 * 8 - 4 :17 * 8],
response_data[17 * 8 - 4 :16 * 8],
response_data[16 * 8 - 4 :15 * 8],
response_data[15 * 8 - 4 :14 * 8],
response_data[14 * 8 - 4 :13 * 8],
response_data[13 * 8 - 4 :12 * 8],
response_data[12 * 8 - 4 :11 * 8],
response_data[11 * 8 - 4 :10 * 8],
response_data[10 * 8 - 4 : 9 * 8],
response_data[ 9 * 8 - 4 : 8 * 8],
response_data[ 8 * 8 - 4 : 7 * 8],
response_data[ 7 * 8 - 4 : 6 * 8],
response_data[ 6 * 8 - 4 : 5 * 8],
response_data[ 5 * 8 - 4 : 4 * 8],
response_data[ 4 * 8 - 4 : 3 * 8],
response_data[ 3 * 8 - 4 : 2 * 8],
response_data[ 2 * 8 - 4 : 1 * 8],
response_data[ 1 * 8 - 4 : 0 * 8]
};

always @ (posedge mem_clk) begin 
    if (rst) 
        request_valid_hold <= 'b0;
    else if (request_valid & request_ready)
        request_valid_hold <= 'b0;
    else if (request_valid)
        request_valid_hold <= 'b1;
    else if (request_valid_hold & request_ready)
        request_valid_hold <= 'b0;
    else
        request_valid_hold <= request_valid_hold;
end
endmodule
