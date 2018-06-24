module data_path
#(
parameter REQ_ADDR_WIDTH = 32,
parameter REQ_LENG_WIDTH = 32,
parameter REQ_DATA_WIDTH = 512,
parameter RSP_ADDR_WIDTH = 16,
parameter RSP_DATA_WIDTH = REQ_DATA_WIDTH,
parameter RD_ADDR_WIDTH  = 32,
parameter CACHE_WIDTH    = 2,
parameter CACHE_SIZE     = 4,
parameter ADDR_WIDTH     = 32,
parameter LEN_WIDTH      = 32,
parameter PEP_WIDTH      = 11,
parameter C_AXI_DATA_WIDTH = 512
)
(
input  wire  dma_clk,
input  wire  ddr_clk,
input  wire  usr_clk,
input  wire  rst,
input  wire  process_done,

input  wire [255:0]                     axis_dma_tdata,
input  wire [31:0]                      axis_dma_tkeep,
input  wire                             axis_dma_tvalid,
input  wire                             axis_dma_tlast,
output wire                             axis_dma_tready,

output wire [9:0]                       pep_counter,

output wire [ADDR_WIDTH-1:0]            s_axis_raddr_pr,
output wire [LEN_WIDTH-1:0]             s_axis_rlen_pr,
output wire                             s_axis_rreq_pr,
input  wire                             s_axis_rack_pr,
input  wire [C_AXI_DATA_WIDTH-1:0]      s_axis_data_pr,
input  wire [C_AXI_DATA_WIDTH/8-1:0]    s_axis_keep_pr,
input  wire                             s_axis_valid_pr,
input  wire                             s_axis_last_pr,
output wire                             s_axis_ready_pr,

output wire [255:0]                     axis_spec_data,
output wire [31:0]                      axis_spec_keep,
output wire                             axis_spec_valid,
output wire                             axis_spec_last,
input  wire                             axis_spec_ready,
output wire [7:0]                       axis_spec_charge,
output wire [15:0]                      axis_spec_len,
output wire [31:0]                      axis_spec_seq,

output wire                             axis_pep_stop,
output wire [207:0]                     axis_pep_user,
output wire [255:0]                     axis_pep_data,
output wire [31:0]                      axis_pep_keep,
output wire                             axis_pep_valid,
output wire                             axis_pep_last,
output wire                             axis_pep_empty,
input  wire                             axis_pep_ready
);

wire [255  : 0]    rdata;
wire [255  : 0]    pep_data_master;
wire [31   : 0]    pep_keep_master;
wire [0    : 0]    pep_valid_master;
wire [0    : 0]    pep_last_master;
wire [0    : 0]    pep_ready_master;
wire               pep_full_master;
wire               pep_empty_master;
wire               pep_grant_master;

wire [87:0]        axis_spec_user;

wire [255  : 0]    spec_data_master;
wire [31   : 0]    spec_keep_master;
wire [0    : 0]    spec_valid_master;
wire [0    : 0]    spec_last_master;
wire [0    : 0]    spec_ready_master;

wire [31   : 0]    spectrum_seq;
wire [15   : 0]    spectrum_len;
wire [7    : 0]    spectrum_charge;
wire [31   : 0]    peptide_number;


wire                     pep_ready;
wire                     pep_valid;
wire [207:0]             pep_data;

wire [31:0]              parse_protein_addr;
wire                     parse_protein_valid;
wire [PEP_WIDTH-1:0]     parse_addr;
wire                     parse_ready;
wire [159:0]             parse_data;

wire [31:0]              clear_addr;
wire                     clear_valid;

wire                     peptide_ready;
wire [207:0]             peptide_info;
wire [159:0]             peptide_data;
wire [15:0]              peptide_begin;
wire [15:0]              peptide_len;
wire                     peptide_valid;


assign pep_ready_master = ~pep_full_master;

assign axis_spec_seq = axis_spec_user[56+:32];
assign axis_spec_len = axis_spec_user[40+:16];
assign axis_spec_charge = axis_spec_user[32+:8];


assign rdata = {
pep_data_master[7   :   0],
pep_data_master[15  :   8],
pep_data_master[23  :  16],
pep_data_master[31  :  24],
pep_data_master[39  :  32],
pep_data_master[47  :  40],
pep_data_master[55  :  48],
pep_data_master[63  :  56],
pep_data_master[71  :  64],
pep_data_master[79  :  72],
pep_data_master[87  :  80],
pep_data_master[95  :  88],
pep_data_master[103 :  96],
pep_data_master[111 : 104],
pep_data_master[119 : 112],
pep_data_master[127 : 120],
pep_data_master[135 : 128],
pep_data_master[143 : 136],
pep_data_master[151 : 144],
pep_data_master[159 : 152],
pep_data_master[167 : 160],
pep_data_master[175 : 168],
pep_data_master[183 : 176],
pep_data_master[191 : 184],
pep_data_master[199 : 192],
pep_data_master[207 : 200],
pep_data_master[215 : 208],
pep_data_master[223 : 216],
pep_data_master[231 : 224],
pep_data_master[239 : 232],
pep_data_master[247 : 240],
pep_data_master[255 : 248]
};


bio_parser
bio_parser_i
(
.clk(dma_clk),
.rst(rst),

.data_slave (axis_dma_tdata),
.keep_slave (axis_dma_tkeep),
.valid_slave(axis_dma_tvalid),
.last_slave (axis_dma_tlast),
.ready_slave(axis_dma_tready),

.pep_data_master(pep_data_master),
.pep_keep_master(pep_keep_master),
.pep_valid_master(pep_valid_master),
.pep_last_master(pep_last_master),
.pep_ready_master(pep_ready_master),

.spec_data_master(spec_data_master),
.spec_keep_master(spec_keep_master),
.spec_valid_master(spec_valid_master),
.spec_last_master(spec_last_master),
.spec_ready_master(spec_ready_master),

.spectrum_seq(spectrum_seq),
.spectrum_len(spectrum_len),
.spectrum_charge(spectrum_charge),
.peptide_number(peptide_number)
);

cache_half 
#(
.REQ_ADDR_WIDTH(REQ_ADDR_WIDTH),
.REQ_LENG_WIDTH(REQ_LENG_WIDTH),
.REQ_DATA_WIDTH(REQ_DATA_WIDTH),
.RSP_ADDR_WIDTH(RSP_ADDR_WIDTH),
.RSP_DATA_WIDTH(RSP_DATA_WIDTH),
.RD_ADDR_WIDTH(RD_ADDR_WIDTH),
.CACHE_WIDTH(CACHE_WIDTH),
.CACHE_SIZE(CACHE_SIZE)
)
cache_half_i
(
.mem_clk(ddr_clk),
.usr_clk(usr_clk),
.dma_clk(dma_clk),
.rst(rst),

.prefetch_address(rdata[224+:32]),
.prefetch_length({16'd0,rdata[224-16+:16]}),
.prefetch_valid(pep_grant_master),
.prefetch_ready(),

.s_axis_raddr(s_axis_raddr_pr),
.s_axis_rlen(s_axis_rlen_pr),
.s_axis_rreq(s_axis_rreq_pr),
.s_axis_rack(s_axis_rack_pr),
.s_axis_data(s_axis_data_pr),
.s_axis_keep(s_axis_keep_pr),
.s_axis_valid(s_axis_valid_pr),
.s_axis_last(s_axis_last_pr),
.s_axis_ready(s_axis_ready_pr),

.extract_address(parse_protein_addr),
.extract_pointer(parse_addr),
.extract_valid(parse_protein_valid),
.extract_ready(parse_ready),
.extract_data(parse_data),

.clear_address(clear_addr),
.clear_valid(clear_valid)
);

fifo_async_fwft_208
dcp_pep_queue
(
.rd_clk(ddr_clk),
.wr_clk(dma_clk),
.rst(rst),
.din(rdata[48+:208]),
.wr_data_count(pep_counter),
.wr_en(pep_valid_master),
.full(pep_full_master),
.empty(pep_empty_master),
.dout(pep_data),
.rd_en(pep_ready),
.valid(pep_valid)
);

pep_parser
#(PEP_WIDTH)
pep_parser_i
(
.clk(ddr_clk),
.rst(rst),

.pep_ready(pep_ready),
.pep_valid(pep_valid),
.pep_data(pep_data),

.parse_protein_addr(parse_protein_addr),
.parse_protein_valid(parse_protein_valid),
.parse_addr(parse_addr),
.parse_ready(parse_ready),
.parse_data(parse_data),

.clear_addr(clear_addr),
.clear_valid(clear_valid),

.peptide_ready(peptide_ready),
.peptide_info(peptide_info),
.peptide_data(peptide_data),
.peptide_begin(peptide_begin),
.peptide_len(peptide_len),
.peptide_valid(peptide_valid)
);

pep_alignment pep_alignment_i
(
.clk(ddr_clk),
.rst(rst),
.rd_clk(usr_clk),

.peptide_data(peptide_data),
.peptide_begin(peptide_begin),
.peptide_len(peptide_len),
.peptide_info(peptide_info),
.peptide_valid(peptide_valid),
.peptide_ready(peptide_ready),

.axis_pep_user(axis_pep_user),
.axis_pep_data(axis_pep_data),
.axis_pep_keep(axis_pep_keep),
.axis_pep_valid(axis_pep_valid),
.axis_pep_last(axis_pep_last),
.axis_pep_empty(axis_pep_empty),
.axis_pep_ready(axis_pep_ready)
);

dup_suppress 
#(
.WIDTH(32),
.MAGIC(32'hffff_ffff)
)
dup_suppress_i
(
.clk(dma_clk),
.rst(rst),
.data(rdata[224+:32]),
.valid(pep_valid_master),
.grant(pep_grant_master)
);

output_ctrl 
#(
. WIDTH(32)
)
output_ctrl_i
(
.clk(usr_clk),
.rst(rst | process_done),

.valid1(axis_spec_valid & axis_spec_ready & axis_spec_last),
.length(axis_spec_user[0+:32]),
.valid2(axis_pep_valid & axis_pep_ready & axis_pep_last),
.stop(axis_pep_stop)
);

fifo_axis_async_256_user_88 spec_fifo
(
.s_aclk             (dma_clk),
.s_aresetn          (~rst),
.s_axis_tvalid      (spec_valid_master),
.s_axis_tready      (spec_ready_master),
.s_axis_tdata       (spec_data_master),
.s_axis_tkeep       (spec_keep_master),
.s_axis_tlast       (spec_last_master),
.s_axis_tuser       ({spectrum_seq,spectrum_len,spectrum_charge,peptide_number}),
.m_aclk             (usr_clk),
.m_axis_tvalid      (axis_spec_valid),
.m_axis_tready      (axis_spec_ready),
.m_axis_tdata       (axis_spec_data),
.m_axis_tkeep       (axis_spec_keep),
.m_axis_tlast       (axis_spec_last),
.m_axis_tuser       (axis_spec_user)
);

endmodule
