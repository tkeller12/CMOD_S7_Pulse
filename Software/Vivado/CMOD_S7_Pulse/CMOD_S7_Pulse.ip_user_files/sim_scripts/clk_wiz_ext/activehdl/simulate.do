transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+clk_wiz_ext  -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.clk_wiz_ext xil_defaultlib.glbl

do {clk_wiz_ext.udo}

run 1000ns

endsim

quit -force
