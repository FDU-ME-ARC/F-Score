
module ds_register_syn
( data_in,
  data_out,
  we,
  clk,
  rst_n
);

parameter WIDTH = 32; // default parameter of the register width
parameter RESET_VALUE = 0;

input [WIDTH-1:0] data_in;
input             we;
input             clk;
input             rst_n;

output [WIDTH-1:0] data_out;
reg    [WIDTH-1:0] data_out;

always @ (posedge clk)
begin
  if (!rst_n)                       // synchronous reset
    data_out<=#1 RESET_VALUE;
  else if (we)                        // write
    data_out<=#1 data_in;
end



endmodule
