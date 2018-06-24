# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CACHE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CACHE_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "LEN_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PEP_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RD_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REQ_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REQ_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "REQ_LENG_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RSP_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RSP_DATA_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.CACHE_SIZE { PARAM_VALUE.CACHE_SIZE } {
	# Procedure called to update CACHE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CACHE_SIZE { PARAM_VALUE.CACHE_SIZE } {
	# Procedure called to validate CACHE_SIZE
	return true
}

proc update_PARAM_VALUE.CACHE_WIDTH { PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to update CACHE_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CACHE_WIDTH { PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to validate CACHE_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.LEN_WIDTH { PARAM_VALUE.LEN_WIDTH } {
	# Procedure called to update LEN_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.LEN_WIDTH { PARAM_VALUE.LEN_WIDTH } {
	# Procedure called to validate LEN_WIDTH
	return true
}

proc update_PARAM_VALUE.PEP_WIDTH { PARAM_VALUE.PEP_WIDTH } {
	# Procedure called to update PEP_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PEP_WIDTH { PARAM_VALUE.PEP_WIDTH } {
	# Procedure called to validate PEP_WIDTH
	return true
}

proc update_PARAM_VALUE.RD_ADDR_WIDTH { PARAM_VALUE.RD_ADDR_WIDTH } {
	# Procedure called to update RD_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RD_ADDR_WIDTH { PARAM_VALUE.RD_ADDR_WIDTH } {
	# Procedure called to validate RD_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.REQ_ADDR_WIDTH { PARAM_VALUE.REQ_ADDR_WIDTH } {
	# Procedure called to update REQ_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REQ_ADDR_WIDTH { PARAM_VALUE.REQ_ADDR_WIDTH } {
	# Procedure called to validate REQ_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.REQ_DATA_WIDTH { PARAM_VALUE.REQ_DATA_WIDTH } {
	# Procedure called to update REQ_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REQ_DATA_WIDTH { PARAM_VALUE.REQ_DATA_WIDTH } {
	# Procedure called to validate REQ_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.REQ_LENG_WIDTH { PARAM_VALUE.REQ_LENG_WIDTH } {
	# Procedure called to update REQ_LENG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.REQ_LENG_WIDTH { PARAM_VALUE.REQ_LENG_WIDTH } {
	# Procedure called to validate REQ_LENG_WIDTH
	return true
}

proc update_PARAM_VALUE.RSP_ADDR_WIDTH { PARAM_VALUE.RSP_ADDR_WIDTH } {
	# Procedure called to update RSP_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RSP_ADDR_WIDTH { PARAM_VALUE.RSP_ADDR_WIDTH } {
	# Procedure called to validate RSP_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.RSP_DATA_WIDTH { PARAM_VALUE.RSP_DATA_WIDTH } {
	# Procedure called to update RSP_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RSP_DATA_WIDTH { PARAM_VALUE.RSP_DATA_WIDTH } {
	# Procedure called to validate RSP_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.REQ_ADDR_WIDTH { MODELPARAM_VALUE.REQ_ADDR_WIDTH PARAM_VALUE.REQ_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REQ_ADDR_WIDTH}] ${MODELPARAM_VALUE.REQ_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.REQ_LENG_WIDTH { MODELPARAM_VALUE.REQ_LENG_WIDTH PARAM_VALUE.REQ_LENG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REQ_LENG_WIDTH}] ${MODELPARAM_VALUE.REQ_LENG_WIDTH}
}

proc update_MODELPARAM_VALUE.REQ_DATA_WIDTH { MODELPARAM_VALUE.REQ_DATA_WIDTH PARAM_VALUE.REQ_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.REQ_DATA_WIDTH}] ${MODELPARAM_VALUE.REQ_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RSP_ADDR_WIDTH { MODELPARAM_VALUE.RSP_ADDR_WIDTH PARAM_VALUE.RSP_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RSP_ADDR_WIDTH}] ${MODELPARAM_VALUE.RSP_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.RSP_DATA_WIDTH { MODELPARAM_VALUE.RSP_DATA_WIDTH PARAM_VALUE.RSP_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RSP_DATA_WIDTH}] ${MODELPARAM_VALUE.RSP_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RD_ADDR_WIDTH { MODELPARAM_VALUE.RD_ADDR_WIDTH PARAM_VALUE.RD_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RD_ADDR_WIDTH}] ${MODELPARAM_VALUE.RD_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.CACHE_WIDTH { MODELPARAM_VALUE.CACHE_WIDTH PARAM_VALUE.CACHE_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CACHE_WIDTH}] ${MODELPARAM_VALUE.CACHE_WIDTH}
}

proc update_MODELPARAM_VALUE.CACHE_SIZE { MODELPARAM_VALUE.CACHE_SIZE PARAM_VALUE.CACHE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CACHE_SIZE}] ${MODELPARAM_VALUE.CACHE_SIZE}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.LEN_WIDTH { MODELPARAM_VALUE.LEN_WIDTH PARAM_VALUE.LEN_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.LEN_WIDTH}] ${MODELPARAM_VALUE.LEN_WIDTH}
}

proc update_MODELPARAM_VALUE.PEP_WIDTH { MODELPARAM_VALUE.PEP_WIDTH PARAM_VALUE.PEP_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PEP_WIDTH}] ${MODELPARAM_VALUE.PEP_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

