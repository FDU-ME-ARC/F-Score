//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.3 (win64) Build 1682563 Mon Oct 10 19:07:27 MDT 2016
//Date        : Wed Mar 14 00:18:23 2018
//Host        : diabolum-PC running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (C0_SYS_CLK_clk_n,
    C0_SYS_CLK_clk_p,
    c0_ddr3_addr,
    c0_ddr3_ba,
    c0_ddr3_cas_n,
    c0_ddr3_ck_n,
    c0_ddr3_ck_p,
    c0_ddr3_cke,
    c0_ddr3_cs_n,
    c0_ddr3_dq,
    c0_ddr3_dqs_n,
    c0_ddr3_dqs_p,
    c0_ddr3_odt,
    c0_ddr3_ras_n,
    c0_ddr3_reset_n,
    c0_ddr3_we_n,
    diff_clock_rtl_clk_n,
    diff_clock_rtl_clk_p,
    pcie_7x_mgt_rtl_rxn,
    pcie_7x_mgt_rtl_rxp,
    pcie_7x_mgt_rtl_txn,
    pcie_7x_mgt_rtl_txp,
    sys_rst_n,
    shdn,
    clk_rst_si,
    sys_clk_100M_p,
    sys_clk_100M_n);
  input C0_SYS_CLK_clk_n;
  input C0_SYS_CLK_clk_p;
  output [15:0]c0_ddr3_addr;
  output [2:0]c0_ddr3_ba;
  output c0_ddr3_cas_n;
  output [0:0]c0_ddr3_ck_n;
  output [0:0]c0_ddr3_ck_p;
  output [0:0]c0_ddr3_cke;
  output [0:0]c0_ddr3_cs_n;
  inout [71:0]c0_ddr3_dq;
  inout [8:0]c0_ddr3_dqs_n;
  inout [8:0]c0_ddr3_dqs_p;
  output [0:0]c0_ddr3_odt;
  output c0_ddr3_ras_n;
  output c0_ddr3_reset_n;
  output c0_ddr3_we_n;
  input [0:0]diff_clock_rtl_clk_n;
  input [0:0]diff_clock_rtl_clk_p;
  input [7:0]pcie_7x_mgt_rtl_rxn;
  input [7:0]pcie_7x_mgt_rtl_rxp;
  output [7:0]pcie_7x_mgt_rtl_txn;
  output [7:0]pcie_7x_mgt_rtl_txp;
  input sys_rst_n;
  output shdn, clk_rst_si;
  input sys_clk_100M_p, sys_clk_100M_n;

  wire C0_SYS_CLK_clk_n;
  wire C0_SYS_CLK_clk_p;
  wire USR_CLK_clk_n;
  wire USR_CLK_clk_p;
  wire [15:0]c0_ddr3_addr;
  wire [2:0]c0_ddr3_ba;
  wire c0_ddr3_cas_n;
  wire [0:0]c0_ddr3_ck_n;
  wire [0:0]c0_ddr3_ck_p;
  wire [0:0]c0_ddr3_cke;
  wire [0:0]c0_ddr3_cs_n;
  wire [71:0]c0_ddr3_dq;
  wire [8:0]c0_ddr3_dqs_n;
  wire [8:0]c0_ddr3_dqs_p;
  wire [0:0]c0_ddr3_odt;
  wire c0_ddr3_ras_n;
  wire c0_ddr3_reset_n;
  wire c0_ddr3_we_n;
  wire [0:0]diff_clock_rtl_clk_n;
  wire [0:0]diff_clock_rtl_clk_p;
  wire [7:0]pcie_7x_mgt_rtl_rxn;
  wire [7:0]pcie_7x_mgt_rtl_rxp;
  wire [7:0]pcie_7x_mgt_rtl_txn;
  wire [7:0]pcie_7x_mgt_rtl_txp;
  wire sys_rst;
  wire sys_rst_n;
  
  assign sys_rst = ~sys_rst_n;
  assign shdn = 1'b1;
  assign clk_rst_si = 1'b1;

  system system_i
       (.C0_SYS_CLK_clk_n(C0_SYS_CLK_clk_n),
        .C0_SYS_CLK_clk_p(C0_SYS_CLK_clk_p),
        .USR_CLK_clk_n(sys_clk_100M_n),
        .USR_CLK_clk_p(sys_clk_100M_p),
        .c0_ddr3_addr(c0_ddr3_addr),
        .c0_ddr3_ba(c0_ddr3_ba),
        .c0_ddr3_cas_n(c0_ddr3_cas_n),
        .c0_ddr3_ck_n(c0_ddr3_ck_n),
        .c0_ddr3_ck_p(c0_ddr3_ck_p),
        .c0_ddr3_cke(c0_ddr3_cke),
        .c0_ddr3_cs_n(c0_ddr3_cs_n),
        .c0_ddr3_dq(c0_ddr3_dq),
        .c0_ddr3_dqs_n(c0_ddr3_dqs_n),
        .c0_ddr3_dqs_p(c0_ddr3_dqs_p),
        .c0_ddr3_odt(c0_ddr3_odt),
        .c0_ddr3_ras_n(c0_ddr3_ras_n),
        .c0_ddr3_reset_n(c0_ddr3_reset_n),
        .c0_ddr3_we_n(c0_ddr3_we_n),
        .diff_clock_rtl_clk_n(diff_clock_rtl_clk_n),
        .diff_clock_rtl_clk_p(diff_clock_rtl_clk_p),
        .pcie_7x_mgt_rtl_rxn(pcie_7x_mgt_rtl_rxn),
        .pcie_7x_mgt_rtl_rxp(pcie_7x_mgt_rtl_rxp),
        .pcie_7x_mgt_rtl_txn(pcie_7x_mgt_rtl_txn),
        .pcie_7x_mgt_rtl_txp(pcie_7x_mgt_rtl_txp),
        .sys_rst(sys_rst),
        .sys_rst_n(sys_rst_n));
endmodule
