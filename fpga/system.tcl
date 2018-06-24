
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku115-flva1517-2-e
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_dma:7.1\
xilinx.com:user:axisrd2axi:1.0\
xilinx.com:ip:clk_wiz:5.4\
fudan:bio:data_path:1.0\
xilinx.com:ip:ddr3:1.4\
fudan:bio:ds_top:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:xdma:4.0\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set C0_SYS_CLK [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 C0_SYS_CLK ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {400000000} \
   ] $C0_SYS_CLK
  set USR_CLK [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 USR_CLK ]
  set c0_ddr3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 c0_ddr3 ]
  set diff_clock_rtl [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clock_rtl ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $diff_clock_rtl
  set pcie_7x_mgt_rtl [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt_rtl ]

  # Create ports
  set sys_rst [ create_bd_port -dir I -type rst sys_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $sys_rst
  set sys_rst_n [ create_bd_port -dir I -type rst sys_rst_n ]

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_sg {0} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {22} \
 ] $axi_dma_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {3} \
   CONFIG.SYNCHRONIZATION_STAGES {2} \
 ] $axi_interconnect_1

  # Create instance: axis_interconnect_0, and set properties
  set axis_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 axis_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axis_interconnect_0

  # Create instance: axisrd2axi_0, and set properties
  set axisrd2axi_0 [ create_bd_cell -type ip -vlnv xilinx.com:user:axisrd2axi:1.0 axisrd2axi_0 ]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.MAX_BURST_LENGTH {256} \
 ] [get_bd_intf_pins /axisrd2axi_0/M_AXI]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {64} \
   CONFIG.HAS_TKEEP {1} \
 ] [get_bd_intf_pins /axisrd2axi_0/M_AXIS]

  # Create instance: c2h, and set properties
  set c2h [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 c2h ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $c2h

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.4 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.AUTO_PRIMITIVE {BUFGCE_DIV} \
   CONFIG.CLKOUT1_DRIVES {Buffer} \
   CONFIG.CLKOUT1_JITTER {130.958} \
   CONFIG.CLKOUT1_PHASE_ERROR {98.575} \
   CONFIG.CLKOUT2_DRIVES {Buffer} \
   CONFIG.CLKOUT3_DRIVES {Buffer} \
   CONFIG.CLKOUT4_DRIVES {Buffer} \
   CONFIG.CLKOUT5_DRIVES {Buffer} \
   CONFIG.CLKOUT6_DRIVES {Buffer} \
   CONFIG.CLKOUT7_DRIVES {Buffer} \
   CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {10.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.000} \
   CONFIG.MMCM_COMPENSATION {AUTO} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.PRIMITIVE {Auto} \
   CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
   CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.USE_FREQ_SYNTH {false} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_PHASE_ALIGNMENT {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: data_path_0, and set properties
  set data_path_0 [ create_bd_cell -type ip -vlnv fudan:bio:data_path:1.0 data_path_0 ]

  # Create instance: ddr3_0, and set properties
  set ddr3_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr3:1.4 ddr3_0 ]
  set_property -dict [ list \
   CONFIG.C0.DDR3_AxiAddressWidth {32} \
   CONFIG.C0.DDR3_AxiArbitrationScheme {WRITE_PRIORITY_REG} \
   CONFIG.C0.DDR3_AxiDataWidth {512} \
   CONFIG.C0.DDR3_CLKFBOUT_MULT {7} \
   CONFIG.C0.DDR3_CLKOUT0_DIVIDE {7} \
   CONFIG.C0.DDR3_CasLatency {11} \
   CONFIG.C0.DDR3_CasWriteLatency {8} \
   CONFIG.C0.DDR3_DIVCLK_DIVIDE {2} \
   CONFIG.C0.DDR3_DataMask {false} \
   CONFIG.C0.DDR3_DataWidth {72} \
   CONFIG.C0.DDR3_Ecc {true} \
   CONFIG.C0.DDR3_InputClockPeriod {2500} \
   CONFIG.C0.DDR3_Mem_Add_Map {BANK_ROW_COLUMN} \
   CONFIG.C0.DDR3_MemoryPart {MT9KSF51272HZ-1G6} \
   CONFIG.C0.DDR3_MemoryType {SODIMMs} \
   CONFIG.C0.DDR3_TimePeriod {1250} \
 ] $ddr3_0

  # Create instance: ds_top_0, and set properties
  set ds_top_0 [ create_bd_cell -type ip -vlnv fudan:bio:ds_top:1.0 ds_top_0 ]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {32} \
   CONFIG.HAS_TKEEP {1} \
 ] [get_bd_intf_pins /ds_top_0/pep_axis]

  set_property -dict [ list \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.MAX_BURST_LENGTH {1} \
 ] [get_bd_intf_pins /ds_top_0/s_axi]

  # Create instance: h2c, and set properties
  set h2c [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_interconnect:2.1 h2c ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $h2c

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: rst_ddr3_0_200M, and set properties
  set rst_ddr3_0_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ddr3_0_200M ]

  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_1 ]
  set_property -dict [ list \
   CONFIG.ALL_PROBE_SAME_MU {false} \
   CONFIG.C_BRAM_CNT {9.5} \
   CONFIG.C_MON_TYPE {MIX} \
   CONFIG.C_NUM_MONITOR_SLOTS {3} \
   CONFIG.C_NUM_OF_PROBES {6} \
   CONFIG.C_PROBE0_TYPE {0} \
   CONFIG.C_PROBE1_MU_CNT {1} \
   CONFIG.C_PROBE1_TYPE {0} \
   CONFIG.C_PROBE1_WIDTH {4} \
   CONFIG.C_PROBE2_MU_CNT {1} \
   CONFIG.C_PROBE2_TYPE {0} \
   CONFIG.C_PROBE2_WIDTH {4} \
   CONFIG.C_PROBE3_TYPE {0} \
   CONFIG.C_PROBE3_WIDTH {2} \
   CONFIG.C_PROBE4_TYPE {0} \
   CONFIG.C_PROBE4_WIDTH {2} \
   CONFIG.C_PROBE5_TYPE {0} \
   CONFIG.C_PROBE5_WIDTH {32} \
   CONFIG.C_PROBE6_TYPE {0} \
   CONFIG.C_PROBE6_WIDTH {1} \
   CONFIG.C_PROBE_WIDTH_PROPAGATION {MANUAL} \
   CONFIG.C_SLOT_0_APC_EN {0} \
   CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_0_TYPE {0} \
   CONFIG.C_SLOT_1_APC_EN {0} \
   CONFIG.C_SLOT_1_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_1_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_1_TYPE {0} \
   CONFIG.C_SLOT_2_APC_EN {0} \
   CONFIG.C_SLOT_2_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_2_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_2_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_1

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
 ] $util_ds_buf

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.0 xdma_0 ]
  set_property -dict [ list \
   CONFIG.axi_bypass_64bit_en {false} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axil_master_64bit_en {false} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_scale {Megabytes} \
   CONFIG.axilite_master_size {1} \
   CONFIG.axist_bypass_en {false} \
   CONFIG.axist_bypass_scale {Megabytes} \
   CONFIG.axist_bypass_size {1} \
   CONFIG.axisten_freq {250} \
   CONFIG.cfg_mgmt_if {false} \
   CONFIG.coreclk_freq {500} \
   CONFIG.en_ext_ch_gt_drp {false} \
   CONFIG.pciebar2axibar_axil_master {0x0000000043600000} \
   CONFIG.pciebar2axibar_axist_bypass {0x0000000040000000} \
   CONFIG.pf0_base_class_menu {Memory_controller} \
   CONFIG.pf0_class_code {058000} \
   CONFIG.pf0_class_code_base {05} \
   CONFIG.pf0_class_code_interface {00} \
   CONFIG.pf0_class_code_sub {80} \
   CONFIG.pf0_device_id {8038} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_pba_offset {00000000} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_offset {00000000} \
   CONFIG.pf0_msix_cap_table_size {000} \
   CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
   CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X8} \
   CONFIG.plltype {QPLL1} \
   CONFIG.xdma_axi_intf_mm {AXI_Stream} \
   CONFIG.xdma_rnum_chnl {2} \
   CONFIG.xdma_wnum_chnl {2} \
 ] $xdma_0

  # Create instance: xdma_0_axi_periph, and set properties
  set xdma_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 xdma_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
   CONFIG.NUM_SI {1} \
 ] $xdma_0_axi_periph

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {40} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_1

  # Create interface connections
  connect_bd_intf_net -intf_net C0_SYS_CLK_1 [get_bd_intf_ports C0_SYS_CLK] [get_bd_intf_pins ddr3_0/C0_SYS_CLK]
  connect_bd_intf_net -intf_net CLK_IN1_D_1 [get_bd_intf_ports USR_CLK] [get_bd_intf_pins clk_wiz_0/CLK_IN1_D]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins c2h/S00_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_interconnect_1/M00_AXI] [get_bd_intf_pins ddr3_0/C0_DDR3_S_AXI]
  connect_bd_intf_net -intf_net axis_interconnect_0_M00_AXIS [get_bd_intf_pins axis_interconnect_0/M00_AXIS] [get_bd_intf_pins xdma_0/S_AXIS_C2H_1]
  connect_bd_intf_net -intf_net axisrd2axi_0_M_AXI [get_bd_intf_pins axi_interconnect_1/S02_AXI] [get_bd_intf_pins axisrd2axi_0/M_AXI]
  connect_bd_intf_net -intf_net axisrd2axi_0_M_AXIS [get_bd_intf_pins axisrd2axi_0/M_AXIS] [get_bd_intf_pins data_path_0/pr_axis]
  connect_bd_intf_net -intf_net c2h_M00_AXIS [get_bd_intf_pins c2h/M00_AXIS] [get_bd_intf_pins xdma_0/S_AXIS_C2H_0]
  connect_bd_intf_net -intf_net data_path_0_pep_axis [get_bd_intf_pins data_path_0/pep_axis] [get_bd_intf_pins ds_top_0/pep_axis]
connect_bd_intf_net -intf_net [get_bd_intf_nets data_path_0_pep_axis] [get_bd_intf_pins data_path_0/pep_axis] [get_bd_intf_pins system_ila_1/SLOT_2_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets data_path_0_pep_axis]
  connect_bd_intf_net -intf_net data_path_0_spec_axis [get_bd_intf_pins data_path_0/spec_axis] [get_bd_intf_pins ds_top_0/spec_axis]
connect_bd_intf_net -intf_net [get_bd_intf_nets data_path_0_spec_axis] [get_bd_intf_pins data_path_0/spec_axis] [get_bd_intf_pins system_ila_1/SLOT_1_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets data_path_0_spec_axis]
  connect_bd_intf_net -intf_net ddr3_0_C0_DDR3 [get_bd_intf_ports c0_ddr3] [get_bd_intf_pins ddr3_0/C0_DDR3]
  connect_bd_intf_net -intf_net diff_clock_rtl_1 [get_bd_intf_ports diff_clock_rtl] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net ds_top_0_m_axis_s [get_bd_intf_pins axis_interconnect_0/S00_AXIS] [get_bd_intf_pins ds_top_0/m_axis_s]
connect_bd_intf_net -intf_net [get_bd_intf_nets ds_top_0_m_axis_s] [get_bd_intf_pins axis_interconnect_0/S00_AXIS] [get_bd_intf_pins system_ila_1/SLOT_0_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets ds_top_0_m_axis_s]
  connect_bd_intf_net -intf_net h2c_M00_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins h2c/M00_AXIS]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_0 [get_bd_intf_pins h2c/S00_AXIS] [get_bd_intf_pins xdma_0/M_AXIS_H2C_0]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_1 [get_bd_intf_pins data_path_0/dma_axis] [get_bd_intf_pins xdma_0/M_AXIS_H2C_1]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins xdma_0/M_AXI_LITE] [get_bd_intf_pins xdma_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M00_AXI [get_bd_intf_pins ddr3_0/C0_DDR3_S_AXI_CTRL] [get_bd_intf_pins xdma_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M01_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins xdma_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net xdma_0_axi_periph_M02_AXI [get_bd_intf_pins ds_top_0/s_axi] [get_bd_intf_pins xdma_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_7x_mgt_rtl] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net axisrd2axi_0_m_axis_rack [get_bd_pins axisrd2axi_0/m_axis_rack] [get_bd_pins data_path_0/s_axis_rack_pr]
  connect_bd_net -net data_path_0_axis_pep_stop [get_bd_pins data_path_0/axis_pep_stop] [get_bd_pins ds_top_0/fifo_empty] [get_bd_pins system_ila_1/probe0]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets data_path_0_axis_pep_stop]
  connect_bd_net -net data_path_0_axis_spec_charge [get_bd_pins data_path_0/axis_spec_charge] [get_bd_pins ds_top_0/spec_z_charge]
  connect_bd_net -net data_path_0_axis_spec_len [get_bd_pins data_path_0/axis_spec_len] [get_bd_pins ds_top_0/spec_len]
  connect_bd_net -net data_path_0_axis_spec_seq [get_bd_pins data_path_0/axis_spec_seq] [get_bd_pins ds_top_0/spec_seq_num]
  connect_bd_net -net data_path_0_s_axis_raddr_pr [get_bd_pins axisrd2axi_0/m_axis_raddr] [get_bd_pins data_path_0/s_axis_raddr_pr]
  connect_bd_net -net data_path_0_s_axis_rlen_pr [get_bd_pins axisrd2axi_0/m_axis_rlen] [get_bd_pins data_path_0/s_axis_rlen_pr]
  connect_bd_net -net data_path_0_s_axis_rreq_pr [get_bd_pins axisrd2axi_0/m_axis_rreq] [get_bd_pins data_path_0/s_axis_rreq_pr]
  connect_bd_net -net ddr3_0_c0_ddr3_ui_clk [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins axi_interconnect_1/S01_ACLK] [get_bd_pins axi_interconnect_1/S02_ACLK] [get_bd_pins axisrd2axi_0/clk] [get_bd_pins c2h/S00_AXIS_ACLK] [get_bd_pins data_path_0/ddr_clk] [get_bd_pins ddr3_0/c0_ddr3_ui_clk] [get_bd_pins h2c/M00_AXIS_ACLK] [get_bd_pins rst_ddr3_0_200M/slowest_sync_clk] [get_bd_pins xdma_0_axi_periph/ACLK] [get_bd_pins xdma_0_axi_periph/M00_ACLK] [get_bd_pins xdma_0_axi_periph/M01_ACLK]
  connect_bd_net -net ddr3_0_c0_ddr3_ui_clk_sync_rst [get_bd_pins ddr3_0/c0_ddr3_ui_clk_sync_rst] [get_bd_pins rst_ddr3_0_200M/ext_reset_in]
  connect_bd_net -net debug_package_dst [get_bd_pins ds_top_0/debug_package_dst] [get_bd_pins system_ila_1/probe4]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets debug_package_dst]
  connect_bd_net -net debug_package_num [get_bd_pins ds_top_0/debug_package_num] [get_bd_pins system_ila_1/probe5]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets debug_package_num]
  connect_bd_net -net debug_pep_dst [get_bd_pins ds_top_0/debug_pep_dst] [get_bd_pins system_ila_1/probe3]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets debug_pep_dst]
  connect_bd_net -net ds_top_0_debug_state [get_bd_pins ds_top_0/debug_state] [get_bd_pins system_ila_1/probe1]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets ds_top_0_debug_state]
  connect_bd_net -net ds_top_0_debug_state2 [get_bd_pins ds_top_0/debug_state2] [get_bd_pins system_ila_1/probe2]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_nets ds_top_0_debug_state2]
  connect_bd_net -net ds_top_0_process_done [get_bd_pins data_path_0/process_done] [get_bd_pins ds_top_0/process_done]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axis_interconnect_0/S00_AXIS_ARESETN] [get_bd_pins ds_top_0/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins system_ila_1/resetn] [get_bd_pins xdma_0_axi_periph/M02_ARESETN]
  connect_bd_net -net rst_ddr3_0_200M_peripheral_aresetn [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins axi_interconnect_1/S01_ARESETN] [get_bd_pins axi_interconnect_1/S02_ARESETN] [get_bd_pins c2h/S00_AXIS_ARESETN] [get_bd_pins ddr3_0/c0_ddr3_aresetn] [get_bd_pins h2c/M00_AXIS_ARESETN] [get_bd_pins rst_ddr3_0_200M/peripheral_aresetn] [get_bd_pins xdma_0_axi_periph/ARESETN] [get_bd_pins xdma_0_axi_periph/M00_ARESETN] [get_bd_pins xdma_0_axi_periph/M01_ARESETN]
  connect_bd_net -net rst_ddr3_0_200M_peripheral_reset [get_bd_pins axisrd2axi_0/rst] [get_bd_pins rst_ddr3_0_200M/peripheral_reset]
  connect_bd_net -net sys_rst_1 [get_bd_ports sys_rst] [get_bd_pins ddr3_0/sys_rst] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net sys_rst_n_1 [get_bd_ports sys_rst_n] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net usr_clk_1 [get_bd_pins axis_interconnect_0/S00_AXIS_ACLK] [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins data_path_0/usr_clk] [get_bd_pins ds_top_0/clk] [get_bd_pins ds_top_0/m_clk] [get_bd_pins ds_top_0/s_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins system_ila_1/clk] [get_bd_pins xdma_0_axi_periph/M02_ACLK]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins util_ds_buf/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins util_ds_buf/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net vio_0_probe_out0 [get_bd_pins data_path_0/rst] [get_bd_pins ds_top_0/rst] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axis_interconnect_0/ACLK] [get_bd_pins axis_interconnect_0/M00_AXIS_ACLK] [get_bd_pins c2h/ACLK] [get_bd_pins c2h/M00_AXIS_ACLK] [get_bd_pins data_path_0/dma_clk] [get_bd_pins h2c/ACLK] [get_bd_pins h2c/S00_AXIS_ACLK] [get_bd_pins xdma_0/axi_aclk] [get_bd_pins xdma_0_axi_periph/S00_ACLK]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins axis_interconnect_0/ARESETN] [get_bd_pins axis_interconnect_0/M00_AXIS_ARESETN] [get_bd_pins c2h/ARESETN] [get_bd_pins c2h/M00_AXIS_ARESETN] [get_bd_pins h2c/ARESETN] [get_bd_pins h2c/S00_AXIS_ARESETN] [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins xdma_0_axi_periph/S00_ARESETN]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins ds_top_0/spec_mass] [get_bd_pins xlconstant_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs ddr3_0/C0_DDR3_MEMORY_MAP/C0_DDR3_ADDRESS_BLOCK] SEG_ddr3_0_C0_DDR3_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs ddr3_0/C0_DDR3_MEMORY_MAP/C0_DDR3_ADDRESS_BLOCK] SEG_ddr3_0_C0_DDR3_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x000100000000 -offset 0x00000000 [get_bd_addr_spaces axisrd2axi_0/s_axi] [get_bd_addr_segs ddr3_0/C0_DDR3_MEMORY_MAP/C0_DDR3_ADDRESS_BLOCK] SEG_ddr3_0_C0_DDR3_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x00001000 -offset 0x43602000 [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x50000000 [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs ddr3_0/C0_DDR3_MEMORY_MAP_CTRL/C0_REG] SEG_ddr3_0_C0_REG
  create_bd_addr_seg -range 0x00001000 -offset 0x43600000 [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs ds_top_0/s_axi/reg0] SEG_ds_top_0_reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


