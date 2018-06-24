//**************************************************************************************************
// This file can realise the comparation between pep and spec. And the step of comparation is 8
// 2015/05/08              change the step to 8
//**************************************************************************************************

`timescale 1 ns / 1 ps
`include "ds_define.vh"

module ds_frag_compare #(

    parameter integer FORM_WIDTH = 32,
    parameter integer DATA_WIDTH = 32,
    parameter integer RESULT_WID = 64,
    parameter integer FRAG_TYPE = `X_TYPE
    
    )(

    //system input
    input                               clk,
    input                               rst,

    // register parameter
    input   [FORM_WIDTH - 1 : 0]        ds_ctrl,         // slv_reg0
    input   [FORM_WIDTH - 1 : 0]        WOE,             // slv_reg5

    input                               start,
    input                               frag_gen_done,   //frag_gen_done = ds_ctrl[8] & store_finish_x;

    //spec data input
    output  [4 : 0]                     spec_bram_addr,  //for both mz and i value
    input   [20 * DATA_WIDTH - 1 : 0]   spec_mz_data,
    input   [40 * DATA_WIDTH - 1 : 0]   spec_i_data,     // Q20 form
    input   [15 : 0]                    spec_len,

    //pep frag input
    output  [4 : 0]                     frag_bram_addr,
    input   [15 : 0]                    frag_len,
    input   [40 * DATA_WIDTH - 1 : 0]   frag_xt_mz,
    input   [8 * DATA_WIDTH - 1 : 0]    frag_xt_p,     

    //upload result
    output  reg     [63 : 0]            ds_x,

    output  reg     [15 : 0]            match_num_x,
    
    output  [7 : 0]                     match_num0,
    output  [7 : 0]                     match_num1,
    output  [7 : 0]                     match_num2,
    output  [7 : 0]                     match_num3,
    output  [7 : 0]                     match_num4, 
    output  [7 : 0]                     match_num5,
    output  [7 : 0]                     match_num6,
    output  [7 : 0]                     match_num7,
    output  [7 : 0]                     match_num8,
    output  [7 : 0]                     match_num9, 
    output  [7 : 0]                     match_num10,
    output  [7 : 0]                     match_num11,
    output  [7 : 0]                     match_num12,
    output  [7 : 0]                     match_num13,
    output  [7 : 0]                     match_num14,    
    output  [7 : 0]                     match_num15,    
    output  [7 : 0]                     match_num16,
    output  [7 : 0]                     match_num17,
    output  [7 : 0]                     match_num18,
    output  [7 : 0]                     match_num19,    
    output  [7 : 0]                     match_num20,    
    output  [7 : 0]                     match_num21,
    output  [7 : 0]                     match_num22,
    output  [7 : 0]                     match_num23,
    output  [7 : 0]                     match_num24,    
    output  [7 : 0]                     match_num25,    
    output  [7 : 0]                     match_num26,
    output  [7 : 0]                     match_num27,
    output  [7 : 0]                     match_num28,
    output  [7 : 0]                     match_num29,    

    input   [4 : 0]                     spec_z_charge,

    output  reg                         clear,   //when ds_done, clear set
    input   wire                        ds_blocked
); 



parameter   [2 : 0]     RESET       = 3'b000,
                        INIT_PARA   = 3'b001,
                        WAIT_FRAG   = 3'b011,
                        COMP_STAT   = 3'b100;


reg     [2 : 0]         current;
reg     [2 : 0]         next;
wire                    comp_end;
reg     [4 : 0]         spec_z_charge_r;
reg     [4 : 0]         charge_tmp;

reg    [2:0]    wait_frag_delay;
reg             frag_ready;
always @(posedge clk or posedge rst) begin
    if(rst)
        frag_ready <= 1'b0;
    else if(frag_gen_done)
        frag_ready <= 1'b1;
    else if(current == COMP_STAT)
        frag_ready <= 1'b0;
end


always @(posedge clk or posedge rst)
begin
    if(rst) 
        current <= RESET;
    else
        current <= next;
end


always @ (*)
begin

    case (current)
    RESET   :                                           //0
            begin
                if ( start & (~ds_blocked)) 
                    next = INIT_PARA;
                else 
                    next = RESET;
            end
    INIT_PARA : next = WAIT_FRAG;                      //1
    WAIT_FRAG :                                        //3
            begin
                if (frag_ready  && (wait_frag_delay == 3'h3)) begin
                    if (charge_tmp < spec_z_charge_r)
                        next = COMP_STAT;
                    else 
                        next = RESET;
                end
                else 
                    next = WAIT_FRAG;
            end
            
    COMP_STAT :                                       //4
            begin
                if (comp_end)            //when all the compare state finished
                    next = RESET;
                else 
                    next = COMP_STAT;
            end

    default   : next = current;
    endcase
end


always @(posedge clk or posedge rst) begin
    if(rst)
        wait_frag_delay <= 3'b0;
    else if((current == WAIT_FRAG) && frag_ready)
        wait_frag_delay <= wait_frag_delay + 3'b1;
    else
        wait_frag_delay <= 3'b0;
end

/*-------------- INIT_PARA state ---------------*/


always @(posedge clk or posedge rst) begin
    if (rst) begin
        spec_z_charge_r <= 5'b0;
    end
    else if (current == INIT_PARA) begin
        if(spec_z_charge <= 5'b1)
            spec_z_charge_r <= 5'b00010;
        else if((ds_ctrl[6] | ds_ctrl[9]) & (spec_z_charge > 5'b00010))   //c type or z type
            spec_z_charge_r <= spec_z_charge - 5'b00001;
        else 
            spec_z_charge_r <= spec_z_charge;
    end
    else 
        spec_z_charge_r <= spec_z_charge_r;
end

/*------------- COMP_STAT state ---------------*/
reg     [4 : 0]     state_cnt; //state num
reg                 state_next;
reg                 state_end;       
reg     [2 : 0]     state_next_delay;
always @(posedge clk or posedge rst) begin
    if (rst) 
        state_cnt <= 5'b0;
    else if (current == INIT_PARA) 
        state_cnt <= 5'b0;
    else if (state_end & (~state_next) & (next == COMP_STAT))                       //state_next = (charge_tmp < spec_z_charge_r) & state_end;
        state_cnt <= state_cnt + 5'b1;
    else 
        state_cnt <= state_cnt;
end

reg     [4 : 0]     read_spec_addr;           // read data from bram
reg     [4 : 0]     read_frag_addr;
//wire                spec_read_next;
//wire                frag_read_next;
/*
always @(posedge clk or posedge rst) begin
    if (rst) 
        read_spec_addr <= 5'b0;
    else if ((current == INIT_PARA) | state_next | clear) 
        read_spec_addr <= 5'b0;
    else if (spec_read_next)                 // read next spec data
        read_spec_addr <= read_spec_addr + 5'b1;
    else 
        read_spec_addr <= read_spec_addr;
end*/


/*
always @(posedge clk or posedge rst) begin
    if (rst) 
        read_frag_addr <= 5'b0;
    else if ((current == INIT_PARA) | state_next | clear) 
        read_frag_addr <= 5'b0;
    else if (frag_read_next)                // read next frag data
        read_frag_addr <= read_frag_addr + 5'b1;
    else 
        read_frag_addr <= read_frag_addr;
end*/ 

assign spec_bram_addr = read_spec_addr;
assign frag_bram_addr = read_frag_addr;



/*------------- mz data mask design especially for X, Y, Z type -------------*/
wire    [5 : 0]    mz_data_mask;
wire    [5 : 0]    mz_data_mask_r;
wire    [4 : 0]    pep_frame_deep;
wire    [4 : 0]    spec_frame_deep;
reg     [4 : 0]    mz_frame_num;
reg     [4 : 0]    mz_spec_num;
assign mz_data_mask_r = (frag_len[4 : 0] == 5'h0) ? 6'h0 : (6'h20 - {1'b0, frag_len[4 : 0]});
assign mz_data_mask   = (frag_len[4 : 0] == 5'h0) ? 6'h1f : {1'b0, frag_len[4 : 0]};

assign pep_frame_deep = (frag_len[4 : 0] == 5'h0) ?  ((frag_len >> 5) - 5'b1) : (frag_len >> 5); 
assign spec_frame_deep = (spec_len[4 : 0] == 5'h0) ? ((spec_len >> 5) - 5'b1) : (spec_len >> 5);



reg [40 * DATA_WIDTH - 1 : 0]   frag_mz_tmp;
reg [20 * DATA_WIDTH - 1 : 0]   spec_mz_tmp;
reg [40 * DATA_WIDTH - 1 : 0]   spec_i_tmp;
reg [8 * DATA_WIDTH - 1 : 0]    frag_p_tmp;


wire    [71 : 0]                    pep_mz_value_i[0 : 31];
reg     [19 : 0]                    pep_mz_value[0 : 31];
wire    [31 : 0]                    m_proton;
wire    [19 : 0]                    spec_mz_value[0 : 31];
wire    [39 : 0]                    spec_i_value[0 : 31];
wire    [7 : 0]                     pep_p_value[0 : 31];
wire    [4 : 0]                     z_charge;

assign  z_charge = state_cnt + 5'b1;
assign  m_proton = ds_ctrl[1] ? `M_PROTON_1 : `M_PROTON_0;

reg  [64 : 0] coef_1;
reg  [31 : 0] coef_1_r;
always @(*) begin
    case (z_charge)
    5'h1:   coef_1 = (WOE * 32'h100000) >> 20;
    5'h2:   coef_1 = (WOE * 32'h80000) >> 20;
    5'h3:   coef_1 = (WOE * 32'h55555) >> 20;
    5'h4:   coef_1 = (WOE * 32'h40000) >> 20;
    5'h5:   coef_1 = (WOE * 32'h33333) >> 20;
    5'h6:   coef_1 = (WOE * 32'h2AAAB) >> 20;
    5'h7:   coef_1 = (WOE * 32'h24925) >> 20;
    5'h8:   coef_1 = (WOE * 32'h20000) >> 20;
    5'h9:   coef_1 = (WOE * 32'h1C71C) >> 20;
    5'ha:   coef_1 = (WOE * 32'h1999A) >> 20;
    5'hb:   coef_1 = (WOE * 32'h1745D) >> 20;
    5'hc:   coef_1 = (WOE * 32'h15555) >> 20;
    5'hd:   coef_1 = (WOE * 32'h13B14) >> 20;
    5'he:   coef_1 = (WOE * 32'h12492) >> 20;
    5'hf:   coef_1 = (WOE * 32'h11111) >> 20;
    5'h10:  coef_1 = (WOE * 32'h10000) >> 20;
    5'h11:  coef_1 = (WOE * 32'hF0F1) >> 20;
    5'h12:  coef_1 = (WOE * 32'hE38E) >> 20;
    5'h13:  coef_1 = (WOE * 32'hD794) >> 20;
    5'h14:  coef_1 = (WOE * 32'hCCCD) >> 20;
    5'h15:  coef_1 = (WOE * 32'hC30C) >> 20;
    5'h16:  coef_1 = (WOE * 32'hBA2F) >> 20;
    5'h17:  coef_1 = (WOE * 32'hB216) >> 20;
    5'h18:  coef_1 = (WOE * 32'hAAAB) >> 20;
    5'h19:  coef_1 = (WOE * 32'hA3D7) >> 20;
    5'h1a:  coef_1 = (WOE * 32'h9D8A) >> 20;
    5'h1b:  coef_1 = (WOE * 32'h97B4) >> 20;
    5'h1c:  coef_1 = (WOE * 32'h9249) >> 20;
    5'h1d:  coef_1 = (WOE * 32'h8D3E) >> 20;
    default : coef_1 = 64'h1;
    endcase
end

generate
    genvar i;
    for(i = 0; i < 32; i = i + 1) begin
        assign pep_p_value[i]    = frag_p_tmp[i*8 +: 8];
        assign spec_mz_value[i]  = ((mz_spec_num == spec_frame_deep) && (i >= spec_len[4 : 0])) ? 20'h6ffff : spec_mz_tmp[20 * i +: 20];
        assign spec_i_value[i]   = spec_i_tmp[i*40 +: 40];
    end
endgenerate

//reg    spec_new;
reg    pep_new;
reg    pep_new_r;
integer j;

wire   [63 : 0] coef_2_r;
wire   [63 : 0] pep_mz_value_q [0 : 32];
generate
    genvar ii;
        for (ii = 0; ii < 32; ii = ii + 1) begin
            mult_40_32 mult_pep_i(.CLK(clk), .A(frag_mz_tmp[ii*40 +: 40]), .B(coef_1_r), .CE(pep_new), .P(pep_mz_value_i[ii]));
            assign pep_mz_value_q[ii] = pep_mz_value_i[ii][63 : 0] + coef_2_r;
        end     
endgenerate 

mult_32_32 coef_gen_2(.CLK(clk), .A(m_proton), .B(WOE), .CE(pep_new), .P(coef_2_r));

reg    [19 : 0]    pep_mz_value_align;

generate
    case (FRAG_TYPE)
    `A_TYPE :
        begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                                       
                end
                else if (pep_new_r) begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= ((mz_frame_num == pep_frame_deep) & (j > mz_data_mask)) ? 20'h7ffff : pep_mz_value_q[j][59 : 40];                    
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end
            end         
        end
    `B_TYPE :
        begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    pep_mz_value[0] <= 20'h0;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                   
                end
                else if (pep_new_r) begin
                    pep_mz_value[0] <= pep_mz_value_align;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <=  (((mz_frame_num == pep_frame_deep) & (j >= mz_data_mask )) ? 20'h7ffff : pep_mz_value_q[j - 1][59 : 40]);   
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end 
            end
        end
    `C_TYPE : 
        begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    pep_mz_value[0] <= 20'h0;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                   
                end
                else if (pep_new_r) begin
                    pep_mz_value[0] <= pep_mz_value_align;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <=  (((mz_frame_num == pep_frame_deep) & (j >= mz_data_mask - 1 )) ? 20'h7ffff : pep_mz_value_q[j - 1][59 : 40]);   
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end 
            end
        end
    `X_TYPE : 
        begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    pep_mz_value[0] <= 20'h0;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                   
                end
                else if (pep_new_r) begin
                    pep_mz_value[0] <= pep_mz_value_align;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <=  ((mz_frame_num == 5'h0) & (j <= mz_data_mask_r)) ? 20'h0 : pep_mz_value_q[j-1][59 : 40];
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end 
            end
        end
    `Y_TYPE : 
        begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    pep_mz_value[0] <= 20'h0;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                   
                end
                else if (pep_new_r) begin
                    pep_mz_value[0] <= pep_mz_value_align;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <=  (((mz_frame_num == 5'h0) & (j <= mz_data_mask_r )) ? 20'h0 : pep_mz_value_q[j - 1][59 : 40]);
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end 
            end
        end
    default : begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    pep_mz_value[0] <= 20'h0;
                    for(j = 1; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= 20'h0;                   
                end
                else begin
                    for(j = 0; j < 32; j = j + 1 ) 
                        pep_mz_value[j] <= pep_mz_value[j];
                end 
            end
        end                 
    endcase

endgenerate


/*-------- compare two sequence --------*/
reg     [4 : 0]     spec_pointer;
reg     [4 : 0]     pep_pointer;
reg     [7 : 0]     match_num[0 : 29];

localparam  CMP_STEP = 8;
//localparam  SHIFT_BIT = clogb2(CMP_STEP);
localparam  SHIFT_BIT = 3;
localparam  SPEC_LIMIT = 32/CMP_STEP - 1;
localparam  PEP_LIMIT = 32/CMP_STEP - 1;


wire    spec_end;
wire    pep_end;

assign spec_end = (spec_frame_deep + 5'b1 == read_spec_addr) & (spec_pointer == SPEC_LIMIT) & (current == COMP_STAT);//(spec_pointer == spec_len[4 : 0] - 1);
assign pep_end  = (pep_frame_deep + 5'b1 == read_frag_addr) & (pep_pointer == PEP_LIMIT) & (current == COMP_STAT);//(pep_pointer == frag_len[4 : 0] - 1);

wire    [19 : 0]    s_mz_tmp [0 : CMP_STEP - 1];       // compare 4 mz values in one clock.  s: spec
wire    [19 : 0]    p_mz_tmp [0 : CMP_STEP - 1];       // p: pep
wire    [39 : 0]    s_i_tmp [0 : CMP_STEP - 1];
wire    [7 : 0]     p_p_tmp [0 : CMP_STEP - 1];

generate
    genvar jj;
    for (jj = 0; jj < CMP_STEP; jj = jj + 1)begin
        assign s_mz_tmp [jj] = spec_mz_value[(spec_pointer << SHIFT_BIT) + jj];
        assign p_mz_tmp [jj] = pep_mz_value[(pep_pointer << SHIFT_BIT) + jj];
        assign s_i_tmp [jj] = spec_i_value[(spec_pointer << SHIFT_BIT) + jj];
        assign p_p_tmp [jj] = pep_p_value[(pep_pointer << SHIFT_BIT) + jj];
    end
endgenerate


//reg  comparing;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        spec_pointer <= 5'b0;
        pep_pointer <= 5'b0;

//        comparing <= 1'b0; 
        state_end <= 1'b0;

        frag_mz_tmp <= {40 * DATA_WIDTH {1'b0}};
        pep_mz_value_align <= 20'h0;
        frag_p_tmp  <= {8 * DATA_WIDTH {1'b0}};
        read_frag_addr <= 5'b0;
        coef_1_r <= 32'h0;
        mz_frame_num <= 5'h0;
        mz_spec_num <= 5'h0;
        spec_mz_tmp <= {20 * DATA_WIDTH {1'b0}};
        spec_i_tmp  <= {40 * DATA_WIDTH {1'b0}};
        read_spec_addr <= 5'h0;
        pep_new <= 1'b0;
    end
    else if (clear) begin
        spec_pointer <= 5'b0;
        pep_pointer <= 5'b0; 
        state_end <= 1'b0;  
        pep_new <= 1'b0;  
        read_spec_addr <= 5'h0;  
        read_frag_addr <= 5'b0;
    end
    else if ((current == WAIT_FRAG) && (wait_frag_delay == 3'h3)) begin
//        comparing <= 1'b0;
        
        frag_mz_tmp <= frag_xt_mz;
        coef_1_r <= coef_1[31 : 0];
        pep_mz_value_align <= 20'h0;
        frag_p_tmp  <= frag_xt_p;
        read_frag_addr <= read_frag_addr + 5'b1;
        spec_mz_tmp <= spec_mz_data;
        spec_i_tmp  <= spec_i_data;
        read_spec_addr <= read_spec_addr + 5'b1;
        mz_frame_num <= frag_bram_addr;
        mz_spec_num <= spec_bram_addr;
        pep_new <= 1'b1;

    end
    else if((current == COMP_STAT) & (~state_next) & (~state_end) & (~pep_new) & (~pep_new_r))begin
        if (p_mz_tmp[0] > s_mz_tmp[CMP_STEP-1]) begin
            if (spec_end) begin
                state_end <= 1'b1;
            end
            else if (spec_pointer == SPEC_LIMIT) begin
                spec_pointer <= 5'h0;
                spec_mz_tmp <= spec_mz_data;
                spec_i_tmp  <= spec_i_data;
                read_spec_addr <= read_spec_addr + 5'b1;
                mz_spec_num <= spec_bram_addr;
            end
            else begin
                spec_pointer <= spec_pointer + 5'h1;
            end
        end
        else if (p_mz_tmp[CMP_STEP-1] < s_mz_tmp[0]) begin
            if (pep_end) begin
                state_end <= 1'b1;
            end
            else if (pep_pointer == PEP_LIMIT) begin
                pep_pointer <= 5'b0;
                frag_mz_tmp <= frag_xt_mz;
                pep_mz_value_align <= pep_mz_value_q[31][59 : 40];
                coef_1_r <= coef_1[31 : 0];
                frag_p_tmp  <= frag_xt_p;
                read_frag_addr <= read_frag_addr + 5'b1;
                mz_frame_num <= frag_bram_addr;
                pep_new <= 1'b1;      
            end
            else 
                pep_pointer <= pep_pointer + 5'h1;
        end
        else begin
            /*---------- comparing -----------*/
 //           comparing <= 1;
            if (p_mz_tmp[CMP_STEP-1] > s_mz_tmp [CMP_STEP-1]) begin
                if (spec_end) begin
                    state_end <= 1'b1;
                end
                else if (spec_pointer == SPEC_LIMIT) begin
                    spec_pointer <= 5'h0;
                    spec_mz_tmp <= spec_mz_data;
                    spec_i_tmp  <= spec_i_data;
                    read_spec_addr <= read_spec_addr + 5'b1;
                    mz_spec_num <= spec_bram_addr;
                end
                else begin
                    spec_pointer <= spec_pointer + 5'h1;
                end            
            end
            else if (p_mz_tmp[CMP_STEP-1] < s_mz_tmp[CMP_STEP-1]) begin
                if (pep_end) begin
                    state_end <= 1'b1;
                end
                else if (pep_pointer == PEP_LIMIT) begin
                    pep_pointer <= 5'b0;
                    frag_mz_tmp <= frag_xt_mz;
                    pep_mz_value_align <= pep_mz_value_q[31][59 : 40];
                    coef_1_r <= coef_1[31 : 0];
                    frag_p_tmp  <= frag_xt_p;
                    read_frag_addr <= read_frag_addr + 5'b1;
                    mz_frame_num <= frag_bram_addr;
                    pep_new <= 1'b1;      
                end
                else 
                    pep_pointer <= pep_pointer + 5'h1;
            end
            else begin
                if (spec_end | pep_end) begin
                    state_end <= 1'b1;
                end
                else begin
                    if (spec_pointer == SPEC_LIMIT) begin
                        spec_pointer <= 5'h0;
                        spec_mz_tmp <= spec_mz_data;
                        spec_i_tmp  <= spec_i_data;
                        read_spec_addr <= read_spec_addr + 5'b1;      
                        mz_spec_num <= spec_bram_addr;              
                    end
                    else begin
                        spec_pointer <= spec_pointer + 5'h1;
                    end

                    if (pep_pointer == PEP_LIMIT) begin
                        pep_pointer <= 5'b0;
                        frag_mz_tmp <= frag_xt_mz;
                        pep_mz_value_align <= pep_mz_value_q[31][59 : 40];
                        coef_1_r <= coef_1[31 : 0];
                        frag_p_tmp  <= frag_xt_p;
                        read_frag_addr <= read_frag_addr + 5'b1;
                        mz_frame_num <= frag_bram_addr;
                        pep_new <= 1'b1;                          
                    end
                end

            end
        end
    end

    else if(current == COMP_STAT && state_next)begin
//       comparing <= 1'b0;
       state_end <= 1'b0;
       pep_pointer <= 5'b0;
       spec_pointer <= 5'b0;
       read_spec_addr <= 5'h0;
       read_frag_addr <= 5'h0;
       if(state_next_delay == 3'd4)begin         
              frag_mz_tmp <= frag_xt_mz;
              coef_1_r <= coef_1[31 : 0];
              pep_mz_value_align <= 20'h0;//pep_mz_value_i[31][59 : 40];
              frag_p_tmp  <= frag_xt_p;
              spec_mz_tmp <= spec_mz_data;
              spec_i_tmp  <= spec_i_data;   
              mz_frame_num <= frag_bram_addr;
              mz_spec_num <= spec_bram_addr;
              pep_new <= 1'b1;
       end 
    end
    else if (current == COMP_STAT && pep_new) begin
//        comparing <= 1'b0;
        pep_new <= 1'b0;
    end
    
end

wire [CMP_STEP - 1 : 0]   cmp_res [0 : CMP_STEP - 1];
reg [SHIFT_BIT : 0]   match_index [0 : CMP_STEP - 1];
reg [SHIFT_BIT : 0]   match_index_q [0 : CMP_STEP - 1];
wire          match_hit;
reg           match_hit_q;


generate
    genvar cmp_1;
    for (cmp_1 = 0; cmp_1 < CMP_STEP; cmp_1 = cmp_1 + 1) begin
//    assign   cmp_res[cmp_1] = {((p_mz_tmp[cmp_1] == s_mz_tmp[0]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[2]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[3]) ? 1'b1 : 1'b0)};
    assign   cmp_res[cmp_1] = {((p_mz_tmp[cmp_1] == s_mz_tmp[7]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[6]) ? 1'b1 : 1'b0), 
                               ((p_mz_tmp[cmp_1] == s_mz_tmp[5]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[4]) ? 1'b1 : 1'b0),
                               ((p_mz_tmp[cmp_1] == s_mz_tmp[3]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[2]) ? 1'b1 : 1'b0), 
                               ((p_mz_tmp[cmp_1] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[cmp_1] == s_mz_tmp[0]) ? 1'b1 : 1'b0)};

    end
endgenerate

//always @ (*) begin
//        cmp_res[0] = {((p_mz_tmp[0] == s_mz_tmp[3]) ? 1'b1 : 1'b0), ((p_mz_tmp[0] == s_mz_tmp[2]) ? 1'b1 : 1'b0), ((p_mz_tmp[0] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[0] == s_mz_tmp[0]) ? 1'b1 : 1'b0)};
//        cmp_res[1] = {((p_mz_tmp[1] == s_mz_tmp[3]) ? 1'b1 : 1'b0), ((p_mz_tmp[1] == s_mz_tmp[2]) ? 1'b1 : 1'b0), ((p_mz_tmp[1] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[1] == s_mz_tmp[0]) ? 1'b1 : 1'b0)};
//        cmp_res[2] = {((p_mz_tmp[2] == s_mz_tmp[3]) ? 1'b1 : 1'b0), ((p_mz_tmp[2] == s_mz_tmp[2]) ? 1'b1 : 1'b0), ((p_mz_tmp[2] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[2] == s_mz_tmp[0]) ? 1'b1 : 1'b0)};
//        cmp_res[3] = {((p_mz_tmp[3] == s_mz_tmp[3]) ? 1'b1 : 1'b0), ((p_mz_tmp[3] == s_mz_tmp[2]) ? 1'b1 : 1'b0), ((p_mz_tmp[3] == s_mz_tmp[1]) ? 1'b1 : 1'b0), ((p_mz_tmp[3] == s_mz_tmp[0]) ? 1'b1 : 1'b0)};
//end

assign match_hit = ((current == COMP_STAT) && (~state_next) & (~state_end) & (~pep_new) & (~pep_new_r)) ? ((|cmp_res[0]) | (|cmp_res[1]) | (|cmp_res[2]) | (|cmp_res[3]) | (|cmp_res[4]) | (|cmp_res[5]) | (|cmp_res[6]) | (|cmp_res[7])) : 1'b0; 
always @(posedge clk or posedge rst) begin
    if (rst) 
        match_hit_q <= 1'b0;
    else 
        match_hit_q <= match_hit;
end

generate
    genvar k;
    for ( k = 0; k < CMP_STEP; k = k + 1)begin
        always @(*) begin
            if (match_hit) begin
                casex (cmp_res[k])
                    8'bxxxxxxx1: match_index [k] = 4'b0000;
                    8'bxxxxxx10: match_index [k] = 4'b0001;
                    8'bxxxxx100: match_index [k] = 4'b0010;
                    8'bxxxx1000: match_index [k] = 4'b0011;
                    8'bxxx10000: match_index [k] = 4'b0100;
                    8'bxx100000: match_index [k] = 4'b0101;
                    8'bx1000000: match_index [k] = 4'b0110;
                    8'b10000000: match_index [k] = 4'b0111;
                    default: match_index [k] = 4'b1000;
                endcase
            end
            else 
                match_index [k] = 4'b1000; 
        end       
    end
endgenerate


generate
    genvar cmp_3;
    for (cmp_3 = 0; cmp_3 < CMP_STEP; cmp_3 = cmp_3 + 1) begin
        always @(posedge clk or posedge rst) begin
            if (rst) 
                match_index_q [cmp_3] <= 4'h0;
            else if (match_hit) 
                match_index_q [cmp_3] <= match_index [cmp_3];
            else 
                match_index_q [cmp_3] <= 4'h0;
        end

    end
endgenerate

//always @(posedge clk or posedge rst) begin
//    if (rst) begin
//        match_index_q [0] <= 4'h0;
//        match_index_q [1] <= 4'h0;
//        match_index_q [2] <= 4'h0;
//        match_index_q [3] <= 4'h0;
//        match_index_q [4] <= 4'h0;
//        match_index_q [5] <= 4'h0;
//        match_index_q [6] <= 4'h0;
//        match_index_q [7] <= 4'h0;
//    end
//    else if (match_hit) begin
//        match_index_q [0] <= match_index [0];
//        match_index_q [1] <= match_index [1];
//        match_index_q [2] <= match_index [2];
//        match_index_q [3] <= match_index [3];
//        match_index_q [4] <= match_index [4];
//        match_index_q [5] <= match_index [5];
//        match_index_q [6] <= match_index [6];
//        match_index_q [7] <= match_index [7];
//    end
//    else begin
//        match_index_q [0] <= 4'h0;
//        match_index_q [1] <= 4'h0;
//        match_index_q [2] <= 4'h0;
//        match_index_q [3] <= 4'h0; 
//        match_index_q [4] <= 4'h0;
//        match_index_q [5] <= 4'h0;
//        match_index_q [6] <= 4'h0;
//        match_index_q [7] <= 4'h0;     
//    end
//end

reg    [SHIFT_BIT : 0] match_num_tmp;
wire   [SHIFT_BIT : 0] match_tmp [0 : CMP_STEP/2 - 1];
assign match_tmp[0] = (~match_index[0][3]) + (~match_index[1][3]);
assign match_tmp[1] = (~match_index[2][3]) + (~match_index[3][3]);
assign match_tmp[2] = (~match_index[4][3]) + (~match_index[5][3]);
assign match_tmp[3] = (~match_index[6][3]) + (~match_index[7][3]);
always @(posedge clk or posedge rst) begin
    if (rst) begin
        match_num_tmp <= 4'h0;
    end
    else if (match_hit) begin
        match_num_tmp <= match_tmp[0] + match_tmp[1] + match_tmp[2] + match_tmp[3];
    end
    else 
        match_num_tmp <= 4'h0;
end 
//match_num_tmp = ((match_index[0] < 3'h4) ? 3'b1 : 3'b0) + ((match_index[1] < 3'h4) ? 1'b1 : 1'b0) + ((match_index[2] < 3'h4) ? 1'b1 : 1'b0) + ((match_index[3] < 3'h4) ? 1'b1 : 1'b0);

//wire match_calc;
wire  [47 : 0] ds_x_tmp_0[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_1[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_2[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_3[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_4[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_5[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_6[0 : CMP_STEP];
wire  [47 : 0] ds_x_tmp_7[0 : CMP_STEP];

wire  [47 : 0] ds_x_tmp [0 : CMP_STEP/2 - 1];

//assign match_calc = (current == COMP_STAT) & (~state_next) & (~state_end) & (~pep_new) & (~pep_new_r) && (pep_mz_value[pep_pointer] == spec_mz_value[spec_pointer]);
generate
    genvar cmp_2;
    for (cmp_2 = 0; cmp_2 < CMP_STEP; cmp_2 = cmp_2 + 1) begin
       mult_40_8 mult_0 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[0]), .CE(match_hit), .P(ds_x_tmp_0[cmp_2]));
       mult_40_8 mult_1 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[1]), .CE(match_hit), .P(ds_x_tmp_1[cmp_2]));
       mult_40_8 mult_2 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[2]), .CE(match_hit), .P(ds_x_tmp_2[cmp_2]));
       mult_40_8 mult_3 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[3]), .CE(match_hit), .P(ds_x_tmp_3[cmp_2]));
       mult_40_8 mult_4 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[4]), .CE(match_hit), .P(ds_x_tmp_4[cmp_2]));
       mult_40_8 mult_5 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[5]), .CE(match_hit), .P(ds_x_tmp_5[cmp_2]));
       mult_40_8 mult_6 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[6]), .CE(match_hit), .P(ds_x_tmp_6[cmp_2]));
       mult_40_8 mult_7 (.CLK(clk), .A(s_i_tmp[cmp_2]), .B(p_p_tmp[7]), .CE(match_hit), .P(ds_x_tmp_7[cmp_2]));
    end
endgenerate

assign    ds_x_tmp_0[CMP_STEP] = 48'h0;
assign    ds_x_tmp_1[CMP_STEP] = 48'h0;
assign    ds_x_tmp_2[CMP_STEP] = 48'h0;
assign    ds_x_tmp_3[CMP_STEP] = 48'h0;
assign    ds_x_tmp_4[CMP_STEP] = 48'h0;
assign    ds_x_tmp_5[CMP_STEP] = 48'h0;
assign    ds_x_tmp_6[CMP_STEP] = 48'h0;
assign    ds_x_tmp_7[CMP_STEP] = 48'h0;


//mult_40_8 mult_0_0(.CLK(clk), .A(s_i_tmp[0]), .B(p_p_tmp[0]), .CE(match_hit), .P(ds_x_tmp_0[0]));
//mult_40_8 mult_0_1(.CLK(clk), .A(s_i_tmp[1]), .B(p_p_tmp[0]), .CE(match_hit), .P(ds_x_tmp_0[1]));
//mult_40_8 mult_0_2(.CLK(clk), .A(s_i_tmp[2]), .B(p_p_tmp[0]), .CE(match_hit), .P(ds_x_tmp_0[2]));
//mult_40_8 mult_0_3(.CLK(clk), .A(s_i_tmp[3]), .B(p_p_tmp[0]), .CE(match_hit), .P(ds_x_tmp_0[3]));
//assign   ds_x_tmp_0[4] = 48'h0;
//
//mult_40_8 mult_1_1(.CLK(clk), .A(s_i_tmp[0]), .B(p_p_tmp[1]), .CE(match_hit), .P(ds_x_tmp_1[0]));
//mult_40_8 mult_1_2(.CLK(clk), .A(s_i_tmp[1]), .B(p_p_tmp[1]), .CE(match_hit), .P(ds_x_tmp_1[1]));
//mult_40_8 mult_1_3(.CLK(clk), .A(s_i_tmp[2]), .B(p_p_tmp[1]), .CE(match_hit), .P(ds_x_tmp_1[2]));
//mult_40_8 mult_1_4(.CLK(clk), .A(s_i_tmp[3]), .B(p_p_tmp[1]), .CE(match_hit), .P(ds_x_tmp_1[3]));
//assign   ds_x_tmp_1[4] = 48'h0;
//
//mult_40_8 mult_2_1(.CLK(clk), .A(s_i_tmp[0]), .B(p_p_tmp[2]), .CE(match_hit), .P(ds_x_tmp_2[0]));
//mult_40_8 mult_2_2(.CLK(clk), .A(s_i_tmp[1]), .B(p_p_tmp[2]), .CE(match_hit), .P(ds_x_tmp_2[1]));
//mult_40_8 mult_2_3(.CLK(clk), .A(s_i_tmp[2]), .B(p_p_tmp[2]), .CE(match_hit), .P(ds_x_tmp_2[2]));
//mult_40_8 mult_2_4(.CLK(clk), .A(s_i_tmp[3]), .B(p_p_tmp[2]), .CE(match_hit), .P(ds_x_tmp_2[3]));
//assign   ds_x_tmp_2[4] = 48'h0;
//
//mult_40_8 mult_3_1(.CLK(clk), .A(s_i_tmp[0]), .B(p_p_tmp[3]), .CE(match_hit), .P(ds_x_tmp_3[0]));
//mult_40_8 mult_3_2(.CLK(clk), .A(s_i_tmp[1]), .B(p_p_tmp[3]), .CE(match_hit), .P(ds_x_tmp_3[1]));
//mult_40_8 mult_3_3(.CLK(clk), .A(s_i_tmp[2]), .B(p_p_tmp[3]), .CE(match_hit), .P(ds_x_tmp_3[2]));
//mult_40_8 mult_3_4(.CLK(clk), .A(s_i_tmp[3]), .B(p_p_tmp[3]), .CE(match_hit), .P(ds_x_tmp_3[3]));
//assign   ds_x_tmp_3[4] = 48'h0;

assign  ds_x_tmp[0] = (ds_x_tmp_0[match_index_q[0]] + ds_x_tmp_1[match_index_q[1]]);
assign  ds_x_tmp[1] = (ds_x_tmp_2[match_index_q[2]] + ds_x_tmp_3[match_index_q[3]]);
assign  ds_x_tmp[2] = (ds_x_tmp_4[match_index_q[4]] + ds_x_tmp_5[match_index_q[5]]);
assign  ds_x_tmp[3] = (ds_x_tmp_6[match_index_q[6]] + ds_x_tmp_7[match_index_q[7]]);

/**************************** start from here *************************/


always @(posedge clk or posedge rst) begin
    if (rst) 
        ds_x <= 64'h0;
    else if ((current == WAIT_FRAG) && (wait_frag_delay == 3'h3))
        ds_x <= 64'h0;
    else if (match_hit_q) 
        ds_x <= ds_x + ds_x_tmp[0] + ds_x_tmp[1] + ds_x_tmp[2] + ds_x_tmp[3];
    else 
        ds_x <= ds_x;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        match_num_x <= 16'b0;
        match_num[0]  <= 8'b0;
        match_num[1]  <= 8'b0;
        match_num[2]  <= 8'b0;
        match_num[3]  <= 8'b0;
        match_num[4]  <= 8'b0;
        match_num[5]  <= 8'b0;
        match_num[6]  <= 8'b0;
        match_num[7]  <= 8'b0;
        match_num[8]  <= 8'b0;
        match_num[9]  <= 8'b0;
        match_num[10] <= 8'b0;
        match_num[11] <= 8'b0;
        match_num[12] <= 8'b0;
        match_num[13] <= 8'b0;
        match_num[14] <= 8'b0;
        match_num[15] <= 8'b0;
        match_num[16] <= 8'b0;
        match_num[17] <= 8'b0;
        match_num[18] <= 8'b0;
        match_num[19] <= 8'b0;
        match_num[20] <= 8'b0;
        match_num[21] <= 8'b0;
        match_num[22] <= 8'b0;
        match_num[23] <= 8'b0;
        match_num[24] <= 8'b0;
        match_num[25] <= 8'b0;
        match_num[26] <= 8'b0;
        match_num[27] <= 8'b0;
        match_num[28] <= 8'b0;
        match_num[29] <= 8'b0;
        
    end
    else if ((current == WAIT_FRAG) && (wait_frag_delay == 3'h3)) begin
        match_num_x <= 16'b0;
        match_num[0]  <= 8'b0;
        match_num[1]  <= 8'b0;
        match_num[2]  <= 8'b0;
        match_num[3]  <= 8'b0;
        match_num[4]  <= 8'b0;
        match_num[5]  <= 8'b0;
        match_num[6]  <= 8'b0;
        match_num[7]  <= 8'b0;
        match_num[8]  <= 8'b0;
        match_num[9]  <= 8'b0;
        match_num[10] <= 8'b0;
        match_num[11] <= 8'b0;
        match_num[12] <= 8'b0;
        match_num[13] <= 8'b0;
        match_num[14] <= 8'b0;
        match_num[15] <= 8'b0;
        match_num[16] <= 8'b0;
        match_num[17] <= 8'b0;
        match_num[18] <= 8'b0;
        match_num[19] <= 8'b0;
        match_num[20] <= 8'b0;
        match_num[21] <= 8'b0;
        match_num[22] <= 8'b0;
        match_num[23] <= 8'b0;
        match_num[24] <= 8'b0;
        match_num[25] <= 8'b0;
        match_num[26] <= 8'b0;
        match_num[27] <= 8'b0;
        match_num[28] <= 8'b0;
        match_num[29] <= 8'b0;       
    end
    else if (match_hit_q) begin
        match_num[state_cnt] <= match_num[state_cnt] + match_num_tmp;
        match_num_x <= match_num_x + match_num_tmp;
    end 
    else begin
        match_num_x <= match_num_x;
        match_num[0]  <= match_num[0];
        match_num[1]  <= match_num[1];
        match_num[2]  <= match_num[2];
        match_num[3]  <= match_num[3];
        match_num[4]  <= match_num[4];
        match_num[5]  <= match_num[5];
        match_num[6]  <= match_num[6];
        match_num[7]  <= match_num[7];
        match_num[8]  <= match_num[8];
        match_num[9]  <= match_num[9];
        match_num[10] <= match_num[10];
        match_num[11] <= match_num[11];
        match_num[12] <= match_num[12];
        match_num[13] <= match_num[13];
        match_num[14] <= match_num[14];
        match_num[15] <= match_num[15];
        match_num[16] <= match_num[16];
        match_num[17] <= match_num[17];
        match_num[18] <= match_num[18];
        match_num[19] <= match_num[19];
        match_num[20] <= match_num[20];
        match_num[21] <= match_num[21];
        match_num[22] <= match_num[22];
        match_num[23] <= match_num[23];
        match_num[24] <= match_num[24];
        match_num[25] <= match_num[25];
        match_num[26] <= match_num[26];
        match_num[27] <= match_num[27];
        match_num[28] <= match_num[28];
        match_num[29] <= match_num[29];        
    end
end


always @(posedge clk or posedge rst) begin
    if (rst) 
        pep_new_r <= 1'b0;
    else if (pep_new) 
        pep_new_r <= 1'b1;
    else 
        pep_new_r <= 1'b0;
end

//wire    spec_next;
//wire    pep_next;
//assign  spec_next = (current == COMP_STAT) & (spec_pointer == 5'b0) & (~state_next);
//assign  pep_next = (current == COMP_STAT) & (pep_pointer == 5'b0) & (~state_next);


//ds_sample next_gen0(.clk(clk), .rst(rst), .sig_in(spec_next), .sig_out(spec_read_next));
//ds_sample next_gen1(.clk(clk), .rst(rst), .sig_in(pep_next),  .sig_out(frag_read_next));


assign      match_num0  = match_num[0] ;
assign      match_num1  = match_num[1] ; 
assign      match_num2  = match_num[2] ; 
assign      match_num3  = match_num[3] ; 
assign      match_num4  = match_num[4] ; 
assign      match_num5  = match_num[5] ; 
assign      match_num6  = match_num[6] ; 
assign      match_num7  = match_num[7] ; 
assign      match_num8  = match_num[8] ; 
assign      match_num9  = match_num[9] ; 
assign      match_num10 = match_num[10]; 
assign      match_num11 = match_num[11]; 
assign      match_num12 = match_num[12]; 
assign      match_num13 = match_num[13]; 
assign      match_num14 = match_num[14]; 
assign      match_num15 = match_num[15]; 
assign      match_num16 = match_num[16]; 
assign      match_num17 = match_num[17]; 
assign      match_num18 = match_num[18]; 
assign      match_num19 = match_num[19]; 
assign      match_num20 = match_num[20]; 
assign      match_num21 = match_num[21]; 
assign      match_num22 = match_num[22]; 
assign      match_num23 = match_num[23]; 
assign      match_num24 = match_num[24]; 
assign      match_num25 = match_num[25]; 
assign      match_num26 = match_num[26]; 
assign      match_num27 = match_num[27]; 
assign      match_num28 = match_num[28]; 
assign      match_num29 = match_num[29]; 


//wire   state_end;
//assign    state_end  = ((frag_len >> 5 + (|frag_len[4 : 0])) == read_frag_addr) & (& pep_pointer) |
//             ((spec_len >> 5 + (|spec_len[4 : 0])) == read_spec_addr) & (& spec_pointer);
//assign  state_end = ((spec_len >> 5 + (|spec_len[4 : 0])) == read_spec_addr) & (& spec_pointer);

//assign  state_next =  (charge_tmp < spec_z_charge_r) & state_end;


always @(posedge clk or posedge rst) begin
    if (rst) 
        state_next_delay <= 3'b0;
    else if (state_next && current == COMP_STAT) 
        state_next_delay <= state_next_delay + 1'b1;
    else 
        state_next_delay <= 3'b0;
end

always @(posedge clk or posedge rst) begin
    if (rst) 
        state_next <= 1'b0;
    else if ((charge_tmp < spec_z_charge_r) & state_end && current == COMP_STAT) 
        state_next <= 1'b1;
    else if(state_next_delay == 3'd4)
        state_next <= 1'b0;
end



always @(posedge clk or posedge rst) begin
    if (rst) 
        charge_tmp <= 5'b0;
    else if (current == INIT_PARA)
        charge_tmp <= 5'b1;
    else if ((current == WAIT_FRAG) & (charge_tmp < spec_z_charge_r) & (next == COMP_STAT) | (current == COMP_STAT) & state_end & (~state_next))
        charge_tmp <= charge_tmp + 5'b1;
    else 
        charge_tmp <= charge_tmp;
 end 

reg   state_end_q;
always @(posedge clk or posedge rst) begin
    if(rst)
        state_end_q <= 1'b0;
    else if (state_end & (~state_next))
        state_end_q <= 1'b1;
    else state_end_q <= 1'b0;
end

assign  comp_end =  (charge_tmp == spec_z_charge_r + 1) & state_end_q;
always @(posedge clk or posedge rst)
begin
    if(rst)
        clear <= 1'b0;
    else if( comp_end )
        clear <= 1'b1;
    else
        clear <= 1'b0;
end



// there need to use cp_split to define z_charge tmp;

endmodule