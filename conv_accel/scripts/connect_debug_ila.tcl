# Connect the pre-created system_ila (dbg_ila) to three AXIS nets and save.
set here [file normalize [file dirname [info script]]]
set root [file normalize "$here/.."]
open_project "$root/hw/accel.xpr"
open_bd_design [get_files -quiet top.bd]

if {[llength [get_bd_cells -quiet dbg_ila]] == 0} { error "dbg_ila missing" }

set pairs [list \
    [list dbg_ila/SLOT_0_AXIS wiener_0/fwd_in_0] \
    [list dbg_ila/SLOT_1_AXIS fwd_fifo_0/M_AXIS] \
    [list dbg_ila/SLOT_2_AXIS wiener_0/dout] \
]
foreach p $pairs {
    lassign $p a b
    set net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins $b]]
    set has [get_bd_intf_pins -quiet -of_objects $net */SLOT_*_AXIS]
    if {[llength $has] == 0} {
        connect_bd_intf_net [get_bd_intf_pins $a] [get_bd_intf_pins $b]
        puts "tapped $b -> $a"
    } else {
        puts "already tapped $b"
    }
}

validate_bd_design
save_bd_design
puts "ILA taps saved"
exit
