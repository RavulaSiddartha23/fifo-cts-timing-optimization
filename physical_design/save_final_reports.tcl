read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45.lef
read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45-opt.lef
read_liberty /home/siddu/openroad-utilization-study/pdk/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_db physical_design/fifo_final.odb
read_sdc constraints/fifo.sdc

set_wire_rc -signal -layer metal3
set_wire_rc -clock -layer metal5
set_propagated_clock [all_clocks]

estimate_parasitics -placement

puts "===== FINAL DESIGN AREA ====="
report_design_area

puts "===== CLOCK SKEW ====="
report_clock_skew

puts "===== SETUP TIMING ====="
report_checks -path_delay max -format full_clock_expanded -digits 6

puts "===== HOLD TIMING ====="
report_checks -path_delay min -format full_clock_expanded -digits 6

puts "===== ROUTING STATUS ====="
design_is_routed -verbose
