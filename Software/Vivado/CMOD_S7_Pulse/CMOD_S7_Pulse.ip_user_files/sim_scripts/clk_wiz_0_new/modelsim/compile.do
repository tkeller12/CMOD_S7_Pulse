vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../ipstatic" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"../../../../CMOD_S7_Pulse.gen/sources_1/ip/clk_wiz_0_new/clk_wiz_0_new_clk_wiz.v" \
"../../../../CMOD_S7_Pulse.gen/sources_1/ip/clk_wiz_0_new/clk_wiz_0_new.v" \

vlog -work xil_defaultlib \
"glbl.v"

