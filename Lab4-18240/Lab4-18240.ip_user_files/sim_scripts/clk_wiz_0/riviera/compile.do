transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0" -l xpm -l xil_defaultlib \
"/afs/ece.cmu.edu/support/xilinx/xilinx.release/Vivado-2024.2/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0" -l xpm -l xil_defaultlib \
"../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

