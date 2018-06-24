/////////////////////////////////////////
// Project  : X!Tandem Hardware Acceleration
// File     : pep_alignment.v
// Author   : Ding Li
// Date     : 5.8.2016
// Func     : Decompress peptides
/////////////////////////////////////////

module pep_alignment
#(
    parameter MAX_WIDTH     = 13,
    parameter PARSE_WIDTH   = 5,
    parameter PEP_WIDTH     = MAX_WIDTH - PARSE_WIDTH,
    parameter PROG_FULL_TH  = 9'd450
)
(
    input  wire                     clk,
    input  wire                     rd_clk,
    input  wire                     rst,

    input  wire [159:0]             peptide_data,
    input  wire [15:0]              peptide_begin,
    input  wire [15:0]              peptide_len,
    input  wire [207:0]             peptide_info,
    input  wire                     peptide_valid,
    output wire                     peptide_ready,

	output wire [207:0]             axis_pep_user,
    output wire [255:0]             axis_pep_data,
    output wire [31:0]              axis_pep_keep,
    output wire                     axis_pep_valid,
    output wire                     axis_pep_last,
    output wire                     axis_pep_empty,
    input  wire                     axis_pep_ready
);

localparam  IDLE  = 3'b001,
            PARSE = 3'b010,
            LAST  = 3'b100;

 reg [2:0]              ns;
 reg [2:0]              ps;

wire                    is_idle_state;
wire                    is_parse_state;

wire                    parse_finish;
 reg [15:0]             pep_counter;
 reg [4:0]              pep_indicator;
wire [255:0]            data_fifo_256;

reg  [207:0]            axis_pep_user_in;
wire [9:0]              axis_data_count;

 reg [159:0]            data;

 reg [159:0]            data_fifo;
 reg [31:0]             keep;
 reg                    valid;
 reg                    last;
wire                    ready;

assign  parse_finish        = (pep_counter <= 'd32);
assign  is_idle_state       = (ps == IDLE); 
assign  is_parse_state      = (ps == PARSE);
assign  peptide_ready       = (axis_data_count < PROG_FULL_TH);

assign  axis_pep_empty      = (axis_data_count == 0);

assign data_fifo_256 = 
{
3'b0, data_fifo[32 * 5 - 1 : 31 * 5],
3'b0, data_fifo[31 * 5 - 1 : 30 * 5],
3'b0, data_fifo[30 * 5 - 1 : 29 * 5],
3'b0, data_fifo[29 * 5 - 1 : 28 * 5],
3'b0, data_fifo[28 * 5 - 1 : 27 * 5],
3'b0, data_fifo[27 * 5 - 1 : 26 * 5],
3'b0, data_fifo[26 * 5 - 1 : 25 * 5],
3'b0, data_fifo[25 * 5 - 1 : 24 * 5],
3'b0, data_fifo[24 * 5 - 1 : 23 * 5],
3'b0, data_fifo[23 * 5 - 1 : 22 * 5],
3'b0, data_fifo[22 * 5 - 1 : 21 * 5],
3'b0, data_fifo[21 * 5 - 1 : 20 * 5],
3'b0, data_fifo[20 * 5 - 1 : 19 * 5],
3'b0, data_fifo[19 * 5 - 1 : 18 * 5],
3'b0, data_fifo[18 * 5 - 1 : 17 * 5],
3'b0, data_fifo[17 * 5 - 1 : 16 * 5],
3'b0, data_fifo[16 * 5 - 1 : 15 * 5],
3'b0, data_fifo[15 * 5 - 1 : 14 * 5],
3'b0, data_fifo[14 * 5 - 1 : 13 * 5],
3'b0, data_fifo[13 * 5 - 1 : 12 * 5],
3'b0, data_fifo[12 * 5 - 1 : 11 * 5],
3'b0, data_fifo[11 * 5 - 1 : 10 * 5],
3'b0, data_fifo[10 * 5 - 1 :  9 * 5],
3'b0, data_fifo[ 9 * 5 - 1 :  8 * 5],
3'b0, data_fifo[ 8 * 5 - 1 :  7 * 5],
3'b0, data_fifo[ 7 * 5 - 1 :  6 * 5],
3'b0, data_fifo[ 6 * 5 - 1 :  5 * 5],
3'b0, data_fifo[ 5 * 5 - 1 :  4 * 5],
3'b0, data_fifo[ 4 * 5 - 1 :  3 * 5],
3'b0, data_fifo[ 3 * 5 - 1 :  2 * 5],
3'b0, data_fifo[ 2 * 5 - 1 :  1 * 5],
3'b0, data_fifo[ 1 * 5 - 1 :  0 * 5]
};


always @ (*)
begin
    case (ps)
        IDLE:   if (peptide_valid)      ns = PARSE;
                else                    ns = IDLE;
        PARSE:  if (parse_finish)       ns = LAST;
                else                    ns = PARSE;
        LAST:                           ns = IDLE;
        default: ns = IDLE;
    endcase
end

always @(posedge clk or posedge rst) 
begin
    if (rst) ps <= IDLE;
    else     ps <= ns;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) pep_counter <= 'd0;
    else if (is_idle_state & peptide_valid) 
             pep_counter <= peptide_len;
    else if (is_parse_state)
             pep_counter <= pep_counter - 'd32;
    else     pep_counter <= pep_counter;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) pep_indicator <= 'd0;
    else if (is_idle_state & peptide_valid) 
             pep_indicator <= peptide_begin[4:0];
    else     pep_indicator <= pep_indicator;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) data_fifo <= 'd0;
    else if (is_parse_state) 
        case (pep_indicator)
                'd0 :   data_fifo <= data;
                'd1 :   data_fifo <= {peptide_data[ 1*5-1:0],data[32*5-1: 1*5]};
                'd2 :   data_fifo <= {peptide_data[ 2*5-1:0],data[32*5-1: 2*5]};
                'd3 :   data_fifo <= {peptide_data[ 3*5-1:0],data[32*5-1: 3*5]};
                'd4 :   data_fifo <= {peptide_data[ 4*5-1:0],data[32*5-1: 4*5]};
                'd5 :   data_fifo <= {peptide_data[ 5*5-1:0],data[32*5-1: 5*5]};
                'd6 :   data_fifo <= {peptide_data[ 6*5-1:0],data[32*5-1: 6*5]};
                'd7 :   data_fifo <= {peptide_data[ 7*5-1:0],data[32*5-1: 7*5]};
                'd8 :   data_fifo <= {peptide_data[ 8*5-1:0],data[32*5-1: 8*5]};
                'd9 :   data_fifo <= {peptide_data[ 9*5-1:0],data[32*5-1: 9*5]};
                'd10:   data_fifo <= {peptide_data[10*5-1:0],data[32*5-1:10*5]};
                'd11:   data_fifo <= {peptide_data[11*5-1:0],data[32*5-1:11*5]};
                'd12:   data_fifo <= {peptide_data[12*5-1:0],data[32*5-1:12*5]};
                'd13:   data_fifo <= {peptide_data[13*5-1:0],data[32*5-1:13*5]};
                'd14:   data_fifo <= {peptide_data[14*5-1:0],data[32*5-1:14*5]};
                'd15:   data_fifo <= {peptide_data[15*5-1:0],data[32*5-1:15*5]};
                'd16:   data_fifo <= {peptide_data[16*5-1:0],data[32*5-1:16*5]};
                'd17:   data_fifo <= {peptide_data[17*5-1:0],data[32*5-1:17*5]};
                'd18:   data_fifo <= {peptide_data[18*5-1:0],data[32*5-1:18*5]};
                'd19:   data_fifo <= {peptide_data[19*5-1:0],data[32*5-1:19*5]};
                'd20:   data_fifo <= {peptide_data[20*5-1:0],data[32*5-1:20*5]};
                'd21:   data_fifo <= {peptide_data[21*5-1:0],data[32*5-1:21*5]};
                'd22:   data_fifo <= {peptide_data[22*5-1:0],data[32*5-1:22*5]};
                'd23:   data_fifo <= {peptide_data[23*5-1:0],data[32*5-1:23*5]};
                'd24:   data_fifo <= {peptide_data[24*5-1:0],data[32*5-1:24*5]};
                'd25:   data_fifo <= {peptide_data[25*5-1:0],data[32*5-1:25*5]};
                'd26:   data_fifo <= {peptide_data[26*5-1:0],data[32*5-1:26*5]};
                'd27:   data_fifo <= {peptide_data[27*5-1:0],data[32*5-1:27*5]};
                'd28:   data_fifo <= {peptide_data[28*5-1:0],data[32*5-1:28*5]};
                'd29:   data_fifo <= {peptide_data[29*5-1:0],data[32*5-1:29*5]};
                'd30:   data_fifo <= {peptide_data[30*5-1:0],data[32*5-1:30*5]};
                'd31:   data_fifo <= {peptide_data[31*5-1:0],data[32*5-1:31*5]};
                default:data_fifo <= data;
        endcase
    else        data_fifo <= data_fifo;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) valid <= 'd0;
    else valid <= is_parse_state;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) last <= 'd0;
    else last <= is_parse_state & parse_finish;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) keep <= 'hffffffff;
    else if (is_parse_state & parse_finish)
    begin
        case (pep_counter)
            'd32: keep <= 'hffffffff;
            'd31: keep <= 'h7fffffff;
            'd30: keep <= 'h3fffffff;
            'd29: keep <= 'h1fffffff;
            'd28: keep <= 'h0fffffff;
            'd27: keep <= 'h07ffffff;
            'd26: keep <= 'h03ffffff;
            'd25: keep <= 'h01ffffff;
            'd24: keep <= 'h00ffffff;
            'd23: keep <= 'h007fffff;
            'd22: keep <= 'h003fffff;
            'd21: keep <= 'h001fffff;
            'd20: keep <= 'h000fffff;
            'd19: keep <= 'h0007ffff;
            'd18: keep <= 'h0003ffff;
            'd17: keep <= 'h0001ffff;
            'd16: keep <= 'h0000ffff;
            'd15: keep <= 'h00007fff;
            'd14: keep <= 'h00003fff;
            'd13: keep <= 'h00001fff;
            'd12: keep <= 'h00000fff;
            'd11: keep <= 'h000007ff;
            'd10: keep <= 'h000003ff;
            'd9 : keep <= 'h000001ff;
            'd8 : keep <= 'h000000ff;
            'd7 : keep <= 'h0000007f;
            'd6 : keep <= 'h0000003f;
            'd5 : keep <= 'h0000001f;
            'd4 : keep <= 'h0000000f;
            'd3 : keep <= 'h00000007;
            'd2 : keep <= 'h00000003;
            'd1 : keep <= 'h00000001;
        default : keep <= 'h00000000;
        endcase
    end
    else keep <= 'hffffffff;
end

always @(posedge clk or posedge rst) 
begin
    if (rst) data <= 'd0;
    else     data <= peptide_data;
end

always @(posedge clk or posedge rst)
begin 
    if (rst) axis_pep_user_in <= 'd0;
    else if (is_idle_state & peptide_valid)
        axis_pep_user_in <= peptide_info;
    else
        axis_pep_user_in <= axis_pep_user_in;
end

fifo_axis_async_256_user_208 pep_fifo
(
.s_aclk             (clk),
.s_aresetn          (~rst),
.s_axis_tvalid      (valid),
.s_axis_tready      (ready),
.s_axis_tdata       (data_fifo_256),
.s_axis_tkeep       (keep),
.s_axis_tlast       (last),
.s_axis_tuser       (axis_pep_user_in),
.m_aclk             (rd_clk),
.m_axis_tvalid      (axis_pep_valid),
.m_axis_tready      (axis_pep_ready),
.m_axis_tdata       (axis_pep_data),
.m_axis_tkeep       (axis_pep_keep),
.m_axis_tlast       (axis_pep_last),
.m_axis_tuser       (axis_pep_user),
.axis_rd_data_count (),
.axis_wr_data_count (axis_data_count)
);

endmodule