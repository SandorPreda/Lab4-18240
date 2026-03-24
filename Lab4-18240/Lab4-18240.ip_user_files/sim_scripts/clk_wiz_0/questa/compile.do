vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv "+incdir+../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0" \
"/afs/ece.cmu.edu/support/xilinx/xilinx.release/Vivado-2024.2/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0" \
"../../../../Lab4-18240.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

