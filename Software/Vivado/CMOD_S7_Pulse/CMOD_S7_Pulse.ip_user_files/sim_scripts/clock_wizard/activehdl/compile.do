transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../CMOD_S7_Pulse.gen/sources_1/bd/clock_wizard/ipshared/a9be" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  \
"C:/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../CMOD_S7_Pulse.gen/sources_1/bd/clock_wizard/ipshared/a9be" "+incdir+../../../../../../../../../../../Xilinx/2025.1/Vivado/data/rsb/busdef" -l xpm -l xil_defaultlib \
"../../../bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/clock_wizard/ip/clock_wizard_clk_wiz_0_0/clock_wizard_clk_wiz_0_0.v" \
"../../../bd/clock_wizard/sim/clock_wizard.v" \

vlog -work xil_defaultlib \
"glbl.v"

