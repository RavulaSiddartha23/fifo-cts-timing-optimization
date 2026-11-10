read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45.lef
read_lef /home/siddu/openroad-utilization-study/pdk/nangate45/lef/Nangate45-opt.lef
read_liberty /home/siddu/openroad-utilization-study/pdk/nangate45/lib/NangateOpenCellLibrary_typical.lib

read_db physical_design/fifo_pin_placement_rows.odb
read_sdc constraints/fifo.sdc

global_placement -density 0.40
detailed_placement
check_placement -verbose

estimate_parasitics -placement
report_checks -path_delay max

write_db physical_design/fifo_placed.odb
