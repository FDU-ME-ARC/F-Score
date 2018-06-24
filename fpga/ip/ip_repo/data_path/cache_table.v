//////////////////////////////////////////////////
//File    : cache_table.v
//Module  : cache_table
//Author  : Kleon
//Contact : 1995dingli@gmail.com
//Func    : 
//Create  : 2017/5/8
//Version : 0.0.0.1
//////////////////////////////////////////////////

module cache_table
#(
 parameter RD_ADDR_WIDTH = 32,
 parameter CACHE_WIDTH   = 2,
 parameter CACHE_SIZE    = 4
)
(
input  wire  clk,
input  wire  rst,

//Read
input  wire [RD_ADDR_WIDTH-1:0] read_address,
output reg  [CACHE_WIDTH-1:0]   read_pointer,
output wire                     read_valid,

//Write
input  wire [RD_ADDR_WIDTH-1:0] write_address,
input  wire                     write_valid,
output reg  [CACHE_WIDTH-1:0]   write_pointer,

//Clear
input  wire [RD_ADDR_WIDTH-1:0] clear_address,
input  wire                     clear_valid,

output wire                     table_vaccant
);

//Table
reg [31:0]                address[0:CACHE_SIZE-1];
reg [CACHE_SIZE-1:0]      occupied;
wire [CACHE_SIZE-1:0]     read_select;

assign table_vaccant = ~&occupied;
assign read_valid = |read_select;

always @(posedge clk)
begin
    if (rst) write_pointer <= 'b0;
    else if (occupied[write_pointer] | write_valid)
        write_pointer <= write_pointer + 1'b1;
    else
        write_pointer <= write_pointer;
end

always @ (*)
begin
    case(read_select)
        'h1:  read_pointer = 'h0;
        'h2:  read_pointer = 'h1;
        'h4:  read_pointer = 'h2;
        'd8:  read_pointer = 'h3;
    default:  read_pointer = 'h0;
    endcase
end

generate
    genvar i;

for (i = 0; i < CACHE_SIZE; i = i + 1) begin 

always @ (posedge clk) begin 
    if (rst) begin 
        address[i] <='b0;
        occupied[i]<='b0;
    end
    else if (write_valid & clear_valid) begin
        if (i == write_pointer) begin
            address[i] <= write_address;
            occupied[i]<= 1'b1;
        end
        else if (clear_address == address[i]) begin 
            address[i] <='b0;
            occupied[i]<='b0;
        end
        else begin 
            address[i] <= address[i];
            occupied[i]<= occupied[i];
        end
    end
    else if (write_valid & (i == write_pointer)) begin 
            address[i] <= write_address;
            occupied[i]<= 1'b1;        
    end
    else if (clear_valid & (clear_address == address[i])) begin 
            address[i] <='b0;
            occupied[i]<='b0;        
    end
    else begin 
            address[i] <= address[i];
            occupied[i]<= occupied[i];
    end
end

assign read_select[i] = (occupied[i] & (read_address == address[i]));

end
endgenerate

endmodule