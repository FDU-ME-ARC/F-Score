//----------------------------------------------------------------------------
// Filename:            axisrd2axi.v
// Version:             1.00.a
// Verilog Standard:    Verilog-2001
// Description:         Generate AXI read channel signal and send data back in 
//                      AXI Stream.
//                      
// Author:              Ding Li (@Kleon)
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps

module axisrd2axi 
#(
     parameter C_AXI_DATA_WIDTH = 512,
     parameter C_AXI_ADDR_WIDTH = 33
)
(
    input  wire                             clk,
    input  wire                             rst,

    //AXI read channel
    output wire [C_AXI_ADDR_WIDTH-1:0]      m_axi_araddr,
    // output wire [2:0]                       m_axi_arprot,
    output wire [0:0]                       m_axi_arvalid,
    input  wire [0:0]                       m_axi_arready,
    // output wire [2:0]                    m_axi_arsize,
    // output wire [1:0]                    m_axi_arburst,
    // output wire [3:0]                    m_axi_arcache,
    // output wire [0:0]                    m_axi_arlock,
    output wire [7:0]                       m_axi_arlen,
    // output wire [3:0]                    m_axi_arqos,
    output wire [0:0]                       m_axi_arid,
    input  wire [C_AXI_DATA_WIDTH-1:0]      m_axi_rdata,
    input  wire [1:0]                       m_axi_rresp,
    input  wire [0:0]                       m_axi_rvalid,
    output wire [0:0]                       m_axi_rready,
    input  wire [0:0]                       m_axi_rlast,
    // input  wire [0:0]                    m_axi_rid,

    //AXI Stream Memory Mapped
    input  wire [C_AXI_ADDR_WIDTH-1:0]      m_axis_raddr,
    input  wire [15:0]                      m_axis_rlen,
    input  wire                             m_axis_rreq,
    output wire                             m_axis_rack,

    output wire [C_AXI_DATA_WIDTH-1:0]      m_axis_data,
    output wire [C_AXI_DATA_WIDTH/8-1:0]    m_axis_keep,
    output wire                             m_axis_valid,
    output wire                             m_axis_last,
    input  wire                             m_axis_ready

);

function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
endfunction // clogb2

localparam C_AXI_STRB_WIDTH = C_AXI_DATA_WIDTH / 8;
localparam C_AXI_STRB_POWER = clogb2(C_AXI_STRB_WIDTH);

wire [31:0] lenminus1;
reg         arid;

assign m_axis_rack      = m_axi_arready;
assign m_axis_data      = m_axi_rdata;
assign m_axis_keep      = {(C_AXI_STRB_WIDTH){1'b1}};
assign m_axis_valid     = m_axi_rvalid;
assign m_axis_last      = m_axi_rlast;
assign lenminus1        = m_axis_rlen - 1;

assign m_axi_araddr     = m_axis_raddr;
assign m_axi_rready     = m_axis_ready;
assign m_axi_arvalid    = m_axis_rreq;
assign m_axi_arid       = arid;
assign m_axi_arqos      = 4'b0;
assign m_axi_arlen      = (lenminus1 >> C_AXI_STRB_POWER);
// assign m_axi_arsize     = 3'h4;
// assign m_axi_arburst    = 2'b01;
// assign m_axi_arlock     = 1'b0;
// assign m_axi_arcache    = 4'h0;
// assign m_axi_arprot     = 3'h0;

always @(posedge clk or posedge rst) begin
    if (rst) 
        arid = 1'b0;
    else if (m_axi_rlast & m_axi_rvalid)
        arid = ~arid;
    else 
        arid = arid;
end

endmodule