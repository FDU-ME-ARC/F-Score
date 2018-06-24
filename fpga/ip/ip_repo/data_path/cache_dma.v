//////////////////////////////////////////////////
//File    : cache_dma.v
//Module  : cache_dma
//Author  : Kleon
//Contact : 1995dingli@gmail.com
//Func    : 
//Create  : 2017/5/8
//Version : 0.0.0.1
//////////////////////////////////////////////////

module cache_dma
#(
    parameter REQ_ADDR_WIDTH = 32,
    parameter REQ_LENG_WIDTH = 32,
    parameter REQ_DATA_WIDTH = 512,
    parameter RSP_ADDR_WIDTH = 8,
    parameter RSP_DATA_WIDTH = REQ_DATA_WIDTH
)
(
input  wire  clk,
input  wire  rst,

//Request Interface
input  wire                        request_permit,
input  wire [REQ_ADDR_WIDTH-1:0]   request_address,
input  wire [REQ_LENG_WIDTH-1:0]   request_length,
input  wire                        request_valid,
output wire                        request_ready,

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

//Response Interface
output wire [RSP_DATA_WIDTH-1:0]   response_data,
output wire [RSP_ADDR_WIDTH-1:0]   response_pointer,
output wire                        response_valid,
output wire                        response_last,
input  wire                        response_ready,
output wire [REQ_ADDR_WIDTH-1:0]   response_address,
output wire [REQ_LENG_WIDTH-1:0]   response_length

);

localparam  IDLE = 3'b001,
            ACKD = 3'b010,
            DATA = 3'b100;

reg [2:0] ps;
reg [2:0] ns;

wire                    is_ackd;
wire                    is_idle;
wire                    is_data;

reg [REQ_LENG_WIDTH-1:0] len;
reg [REQ_ADDR_WIDTH-1:0] addr;
reg [RSP_ADDR_WIDTH-1:0] pointer;


assign is_idle       = (ps == IDLE);
assign is_ackd       = (ps == ACKD);
assign is_data       = (ps == DATA);

assign request_ready = request_permit & is_idle;
assign s_axis_ready  = response_ready;

assign response_data    = s_axis_data;
assign response_pointer = pointer;
assign response_valid   = s_axis_valid;
assign response_last    = s_axis_last;
assign response_address = addr;
assign response_length  = len;

assign s_axis_rreq  = is_ackd;
assign s_axis_raddr = addr;
assign s_axis_rlen  = len;

always @ (*)
begin
    case (ps)
        IDLE:   if (request_valid & request_permit)       
                    ns = ACKD;
                else                    
                    ns = IDLE;
        ACKD:   if (s_axis_rack)        
                    ns = DATA;
                else                    
                    ns = ACKD;
        DATA:   if (s_axis_last & s_axis_valid & s_axis_ready) 
                    ns = IDLE;
                else                            
                    ns = DATA;
        default: ns = IDLE;
    endcase
end

always @(posedge clk or posedge rst) 
begin
    if (rst) ps <= IDLE;
    else     ps <= ns;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr <= 'h0;
        len  <= 'h0;
    end
    else if (request_valid & request_ready) begin
        addr <= request_address;
        len  <= request_length;
    end
    else begin
        addr <= addr;
        len  <= len;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pointer <= 'h0;
    end
    else if (is_idle) begin
        pointer <= 'h0;
    end
    else if (is_data & s_axis_valid & s_axis_ready) begin
        pointer <= pointer + 1'b1;
    end
    else pointer <= pointer;
end
 
endmodule