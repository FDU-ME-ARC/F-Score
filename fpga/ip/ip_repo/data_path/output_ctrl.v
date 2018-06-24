//////////////////////////////////////////////////
//File    : output_ctrl.v
//Module  : output_ctrl
//Author  : Kleon
//Contact : 1995dingli@gmail.com
//Func    : 
//Create  : 2017/5/9
//Version : 0.0.0.1
//////////////////////////////////////////////////

module output_ctrl
#(
    parameter WIDTH = 32
)
(
input  wire  clk,
input  wire  rst,

input  wire              valid1,
input  wire  [WIDTH-1:0] length,
input  wire              valid2,
output wire              stop
);

reg  [WIDTH-1:0] length0;
reg  [WIDTH-1:0] counter;
assign stop = (counter == length0);

always @ (posedge clk) begin 
    if (rst) length0 <= -1;
    else if (valid1) length0 <= length;
    else length0 <= length0;
end

always @ (posedge clk) begin 
    if (rst | valid1) counter <= 'b0;
    else if (valid2) counter <= counter + 1'b1;
    else counter <= counter;
end

endmodule
