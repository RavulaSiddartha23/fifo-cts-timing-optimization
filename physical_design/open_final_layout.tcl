read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45.lef
read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45-opt.lef
read_liberty /home/siddu/openroad-utilization-study/pdk/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_db physical_design/fifo_final.odb

puts "===== FINAL LAYOUT ====="
puts "ROUTED STATUS: [design_is_routed -verbose]"
report_design_area
