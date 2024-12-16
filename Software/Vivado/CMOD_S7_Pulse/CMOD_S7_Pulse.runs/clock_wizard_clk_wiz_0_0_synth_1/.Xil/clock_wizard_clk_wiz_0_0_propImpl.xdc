set_property SRC_FILE_INFO {cfile:c:/Users/jkell/Repositories/FPGA_CMOD_S7/uart_rx_pmod/uart_rx_pmod.gen/sources_1/bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0.xdc rfile:../../../uart_rx_pmod.gen/sources_1/bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
current_instance inst
set_property src_info {type:SCOPED_XDC file:1 line:54 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.833
