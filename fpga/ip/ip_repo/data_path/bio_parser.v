module bio_parser(
input  wire clk,
input  wire rst,

//Input AXI Stream Interface
input  wire [255  : 0]    data_slave,
input  wire [31   : 0]    keep_slave,
input  wire [0    : 0]    valid_slave,
input  wire [0    : 0]    last_slave,
output wire [0    : 0]    ready_slave,

//Output AXI Stream Interface
output wire [255  : 0]    pep_data_master,
output wire [31   : 0]    pep_keep_master,
output wire [0    : 0]    pep_valid_master,
output wire [0    : 0]    pep_last_master,
input  wire [0    : 0]    pep_ready_master,

output wire [255  : 0]    spec_data_master,
output wire [31   : 0]    spec_keep_master,
output wire [0    : 0]    spec_valid_master,
output wire [0    : 0]    spec_last_master,
input  wire [0    : 0]    spec_ready_master,

//Output results
output reg  [31   : 0]    spectrum_seq,
output reg  [15   : 0]    spectrum_len,
output reg  [7    : 0]    spectrum_charge,
output reg  [31   : 0]    peptide_number,
output reg  [167  : 0]    padding0
);

localparam IDLE = 4'b0001,
           HEAD = 4'b0010,
           DATA = 4'b0100,
           WAIT = 4'b1000;

reg [3:0] ps;
reg [3:0] ns;

wire is_idle;
wire is_head;
wire is_data;
wire is_wait; 

assign is_idle = (ps == IDLE);
assign is_head = (ps == HEAD);
assign is_data = (ps == DATA);
assign is_wait = (ps == WAIT);

wire [255 :0] data_out;
reg  [31  :0] keep_out;
wire [0   :0] valid_out;
wire [0   :0] last_out_pep;
wire [0   :0] last_out_spec;
wire [0   :0] ready_out;

reg  [255 :0] data;
reg  [0   :0] valid;
reg  [0   :0] last;
reg  [15  :0] length_spec;
reg  [31  :0] length_pep;
reg  [5   :0] header;
//0 for spec 1 for pep
reg           spec_pep;
wire [255 :0] rdata;

assign data_out = data[255:0]; 



assign valid_out = (is_data & valid) | last;
assign last_out_pep  = (length_pep <= 'd1 ) & valid_out & spec_pep;
assign last_out_spec = (length_spec<= 'd4 ) & valid_out & ~spec_pep;
assign ready_slave = ready_out & ~last;

assign pep_data_master  = data_out;
assign pep_valid_master = spec_pep & valid_out;
// assign pep_keep_master  = keep_out;
assign pep_last_master  = last_out_pep;
assign ready_out    = spec_pep ? pep_ready_master : spec_ready_master;

assign spec_data_master  = data_out;
assign spec_valid_master = ~spec_pep & valid_out;
assign spec_keep_master  = keep_out;
assign spec_last_master  = last_out_spec;

assign rdata = {
data[7   :   0],
data[15  :   8],
data[23  :  16],
data[31  :  24],
data[39  :  32],
data[47  :  40],
data[55  :  48],
data[63  :  56],
data[71  :  64],
data[79  :  72],
data[87  :  80],
data[95  :  88],
data[103 :  96],
data[111 : 104],
data[119 : 112],
data[127 : 120],
data[135 : 128],
data[143 : 136],
data[151 : 144],
data[159 : 152],
data[167 : 160],
data[175 : 168],
data[183 : 176],
data[191 : 184],
data[199 : 192],
data[207 : 200],
data[215 : 208],
data[223 : 216],
data[231 : 224],
data[239 : 232],
data[247 : 240],
data[255 : 248]
};

always@(*) begin 
    keep_out = 0;
    case (length_spec)
        'd1: keep_out = 32'h0000_00ff;
        'd2: keep_out = 32'h0000_ffff;
        'd3: keep_out = 32'h00ff_ffff;
        'd4: keep_out = 32'hffff_ffff; 
        
       // 'd1: keep_out = 32'hff00_0000;
       // 'd2: keep_out = 32'hffff_0000;
       // 'd3: keep_out = 32'hffff_ff00;
       // 'd4: keep_out = 32'hffff_ffff;
    default: keep_out = 32'hffff_ffff;
    endcase
end

wire valid_ready;
assign valid_ready = valid_slave & ready_slave;

wire true_last;
assign true_last = last_slave & valid_ready;

wire header_last;
assign header_last = (header == 'd0);

always @(posedge clk or posedge rst) 
begin
    if (rst) ps <= IDLE;
    else     ps <= ns;
end

always @ (*)
begin
    case (ps)
        IDLE:   if  (valid_ready)   ns = HEAD;
                else                ns = IDLE;
        HEAD:   if  (valid_ready & header_last)
                                    ns = DATA;
                else                ns = HEAD;
        DATA:   if (last_out_pep & spec_pep & ready_out) 
                begin
                    if (last)       ns = IDLE;
                    else            ns = WAIT;
                end
                else                ns = DATA;
        WAIT:   if (true_last)      ns = IDLE;
                else                ns = WAIT;
        default:                    ns = IDLE;
    endcase
end

always @ (posedge clk)
begin
    if (rst) begin
        data <= 0;
    end
    else if (valid_ready) begin
        data <= data_slave;
    end
    else begin
        data <= data;
    end
end

always @ (posedge clk or posedge rst) 
begin
    if (rst)
        valid <= 'b0;
    else if (ready_out)
        valid <= valid_ready;
    else
        valid <= valid;
end

always @ (posedge clk or posedge rst)
begin
    if (rst)
        last <= 1'b0;
    else if (true_last)
        last <= 1'b1;
    else if (ns == IDLE)
        last <= 1'b0;
    else
        last <= last;
end

always @ (posedge clk or posedge rst)
begin
    if (rst)
    begin
        spectrum_seq <= 'd0;
        spectrum_len <= 'd0;
        spectrum_charge <= 'd0;
        peptide_number <= 'd0;
        padding0 <= 'd0;
    end
    else if (is_head)
        case (header)
            'd0   : 
            begin
                spectrum_seq[31:0] <= rdata[255:224];
                spectrum_len[15:0] <= rdata[223:208];
                spectrum_charge[7:0] <= rdata[207:200];
                peptide_number[31:0] <= rdata[199:168];
                padding0[167:0] <= rdata[167:0];
            end
        endcase
    else
    begin
        spectrum_seq <= spectrum_seq;
        spectrum_len <= spectrum_len;
        spectrum_charge <= spectrum_charge;
        peptide_number <= peptide_number;
        padding0 <= padding0;
    end
end

always @ (posedge clk or posedge rst)
begin
    if (rst) 
        length_spec <= 'd0;
    else if (is_head & (header == 'd0))
        length_spec[15:0] <= rdata[223:208];
    else if (valid_out & ready_out & ~spec_pep)
        length_spec <= length_spec - 'd4;
    else if (ns == IDLE) 
        length_spec <= 'd0;
    else 
        length_spec <= length_spec;
end

always @ (posedge clk or posedge rst)
begin
    if (rst) 
        length_pep <= 'd0;
    else if (is_head & (header == 'd0))
        length_pep[15:0] <= rdata[199:168];
    else if (valid_out & ready_out & spec_pep)
        length_pep <= length_pep - 'd1;
    else if (ns == IDLE) 
        length_pep <= 'd0;
    else 
        length_pep <= length_pep;
end

always @ (posedge clk or posedge rst)
begin
    if (rst) 
        spec_pep <= 'd0;
    else if (is_idle)
        spec_pep <= 'd0;
    else if (last_out_spec)
        spec_pep <= 'd1;
    else 
        spec_pep <= spec_pep;
end

always @(posedge clk or posedge rst) begin
    if (rst) 
        header <= 'd0;
    else if (~is_head)
        header <= 'd0;
    else if (valid_ready)
        header <= header + 'd1;
    else
        header <= header;
end

endmodule