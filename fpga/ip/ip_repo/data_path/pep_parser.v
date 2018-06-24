/////////////////////////////////////////
// Project  : X!Tandem Hardware Acceleration
// File     : pep_parser.v
// Author   : Ding Li
// Date     : 5.8.2017
// Func     : Decompress peptides
/////////////////////////////////////////

module pep_parser
#(
    parameter ADDR_WIDTH    = 32,
    parameter MAX_WIDTH     = 14,
    parameter PARSE_WIDTH   = 5,
    parameter PEP_WIDTH     = 11
)
(
    input  wire                     clk,
    input  wire                     rst,

    //Peptide port
    output wire                     pep_ready,
    input  wire                     pep_valid,
    input  wire [207:0]             pep_data,

    //Peptide data
    output  reg [31:0]              parse_protein_addr,
    input  wire                     parse_protein_valid,
    output  reg [PEP_WIDTH-1:0]     parse_addr,
    output wire                     parse_ready,
    input  wire [159:0]             parse_data,

    output  reg [31:0]              clear_addr,
    output wire                     clear_valid,

    //output pep
    input  wire                     peptide_ready,
    output  reg [207:0]             peptide_info,
    output wire [159:0]             peptide_data,
    output  reg [15:0]              peptide_begin,
    output  reg [15:0]              peptide_len,
    output  reg                     peptide_valid
);

localparam  IDLE  = 3'b001,
            WAIT  = 3'b010,
            PARSE = 3'b100;

 reg [2:0]              ns;
 reg [2:0]              ps;
 
 reg                    check_permit_r;
 reg [PEP_WIDTH-1:0]    pep_end_shift;
wire [PEP_WIDTH-1:0]    pep_end_shift_w;
wire [PEP_WIDTH-1:0]    pep_begin_shift_w;

// wire                    is_check_state;
wire                    is_wait_state;
wire                    is_idle_state;
wire                    is_parse_state;

wire                    parse_finish;
wire                    check_permit;

wire [31:0]             pep_addr;
wire [15:0]             pep_begin;
wire [15:0]             pep_end;

assign pep_addr = pep_data[176+:32];
assign pep_begin= pep_data[104+:16];
assign pep_end  = pep_data[88+:16];

assign pep_ready = peptide_ready & is_idle_state;

assign  parse_finish        = (parse_addr == pep_end_shift);
assign  pep_end_shift_w     = pep_end >> PARSE_WIDTH;
assign  pep_begin_shift_w   = pep_begin >> PARSE_WIDTH;

assign  is_wait_state       = (ps == WAIT); 
assign  is_idle_state       = (ps == IDLE); 
assign  is_parse_state      = (ps == PARSE);

assign  parse_ready         = is_parse_state;
assign  peptide_data        = parse_data;

assign  check_permit        = pep_valid & peptide_ready;

always @ (*)
begin
    case (ps)
        IDLE:   if (check_permit)       ns = WAIT;
                else                    ns = IDLE;
        WAIT:   if (parse_protein_valid)ns = PARSE;
                else                    ns = WAIT;
        PARSE:  if (parse_finish)       ns = IDLE;
                else                    ns = PARSE;
        default:                        ns = IDLE;
    endcase
end

always @(posedge clk or posedge rst) 
begin
    if (rst) ps <= IDLE;
    else     ps <= ns;
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    
    begin
        pep_end_shift   <= 'b0;
    end
    else if (is_idle_state & check_permit)    
    begin 
        pep_end_shift   <= pep_end_shift_w[PEP_WIDTH-1:0];
    end
    else
    begin 
        pep_end_shift  <= pep_end_shift;
    end
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    parse_addr  <= 'b0;
    else if (is_idle_state & check_permit)
                parse_addr  <= pep_begin_shift_w[PEP_WIDTH-1:0];
    else if (is_parse_state)
                parse_addr  <= parse_addr + 1'b1;
    else        parse_addr  <= parse_addr;
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    parse_protein_addr  <= 'd0;
    else if (is_idle_state & check_permit)  
                parse_protein_addr  <= pep_addr;
    else        parse_protein_addr  <= parse_protein_addr;
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    clear_addr  <= 32'hffff_ffff;
    else if (check_permit_r)
                clear_addr  <= parse_protein_addr;
    else        clear_addr  <= clear_addr;
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    peptide_valid   <= 1'b0;
    else        peptide_valid   <= is_parse_state;
end

always @(posedge clk or posedge rst) 
begin
    if (rst)    check_permit_r   <= 1'b0;
    else        check_permit_r   <= is_idle_state & check_permit;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        peptide_begin <= 'b0;
        peptide_len   <= 'b0;
        peptide_info  <= 'b0;
    end
    else if (is_idle_state & check_permit) begin
        peptide_begin <= pep_begin;
        peptide_len   <= pep_end - pep_begin + 1'b1;
        peptide_info  <= pep_data;
    end
    else begin
        peptide_begin <= peptide_begin;
        peptide_len   <= peptide_len;
        peptide_info  <= peptide_info;
    end
end

dup_suppress 
#(
.WIDTH(32),
.MAGIC(32'hffff_ffff)
)
dup_suppress_i
(
.clk(clk),
.rst(rst),
.data(parse_protein_addr),
.valid(check_permit_r),
.grant(clear_valid)
);

endmodule