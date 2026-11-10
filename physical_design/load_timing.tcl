read_db physical_design/fifo_pin_placement.odb
read_liberty /home/siddu/openroad-utilization-study/pdk/nangate45/lib/NangateOpenCellLibrary_typical.lib
read_sdc constraints/fifo.sdc
report_checks -path_delay max
