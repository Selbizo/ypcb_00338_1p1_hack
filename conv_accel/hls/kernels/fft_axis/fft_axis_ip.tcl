create_project -force /tmp/fft_axis /tmp/fft_axis -part xc7k480tffg1156-2
create_ip -name xfft -vendor xilinx.com -library ip -version 9.1 -module_name fft_axis
set_property -dict [list \
  CONFIG.transform_length {256} \
  CONFIG.implementation_options {pipelined_streaming_io} \
  CONFIG.data_format {fixed_point} \
  CONFIG.input_width {24} \
  CONFIG.phase_factor_width {16} \
  CONFIG.scaling_options {unscaled} \
  CONFIG.rounding_modes {convergent_rounding} \
  CONFIG.output_ordering {natural_order} \
  CONFIG.throttle_scheme {realtime} \
  CONFIG.aclken {true} \
  CONFIG.aresetn {true} \
  CONFIG.ovflo {true} \
] [get_ips fft_axis]
generate_target all [get_ips fft_axis]
exit
