vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu  -sv "+incdir+../../../../CMOD_S7_Pulse.gen/sources_1/bd/clock_wizard/ipshared/a9be" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm  -93  \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -mfcu  "+incdir+../../../../CMOD_S7_Pulse.gen/sources_1/bd/clock_wizard/ipshared/a9be" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" \
"../../../bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0.v" \
"../../../bd/clock_wizard/sim/clock_wizard.v" \

vlog -work xil_defaultlib \
"glbl.v"

