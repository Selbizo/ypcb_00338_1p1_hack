open_project /tmp/fft_axis/tmp/fft_axis.xpr
add_files -fileset sim_1 /tmp/opencode/tb_fft.v
set_property top tb_fft [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation
run 30us
exit
