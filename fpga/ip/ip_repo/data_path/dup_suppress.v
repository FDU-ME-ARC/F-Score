//////////////////////////////////////////////////
//File    : dup_suppress.v
//Module  : dup_suppress
//Author  : Kleon
//Contact : 1995dingli@gmail.com
//Func    : 
//Create  : 2017/5/9
//Version : 0.0.0.1
//////////////////////////////////////////////////

module dup_suppress
#(
 parameter WIDTH = 32,
 parameter MAGIC = 32'hffff_ffff
)
(
input  wire  clk,
input  wire  rst,


input  wire  [WIDTH-1:0] data,
input  wire              valid,
output wire              grant
);

reg [WIDTH-1:0] data_r;

always @ (posedge clk) begin 
    if (rst) 
        data_r <= MAGIC;
    else if (valid) 
        data_r <= data;
    else
        data_r <= data_r;
end

assign grant = valid & (data != data_r);

endmodule
