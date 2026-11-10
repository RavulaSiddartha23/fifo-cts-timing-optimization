# Clock Tree Synthesis and Timing Optimization of a 32-bit Synchronous FIFO

## 1. Abstract

This project implements a 32-bit, 16-entry synchronous FIFO using Verilog HDL and carries the design through a standard-cell physical-design flow. The work includes functional verification, generic synthesis, technology mapping, floorplanning, placement, clock tree synthesis (CTS), hold repair, global routing and detailed routing.

The Nangate45 standard-cell library is used for technology mapping and physical implementation. The project focuses on understanding clock distribution, setup and hold timing, routing congestion and physical-design verification.

The final design completed detailed routing with zero final detailed-route violations. Final timing values are reported using placement-based parasitic estimation and are not presented as detailed-route SPEF-based sign-off timing.

## 2. Objectives

1. Design and verify a synchronous FIFO using Verilog HDL.
2. Understand generic synthesis and standard-cell technology mapping.
3. Perform floorplanning, IO pin placement and standard-cell placement.
4. Implement Clock Tree Synthesis.
5. Analyze clock skew and repair hold violations.
6. Perform global routing and detailed routing.
7. Evaluate area, utilization, timing estimates and routing results.
8. Save physical-design checkpoints and verification reports.

## 3. Design Architecture

### 3.1 FIFO Specifications

| Parameter | Value |
|---|---|
| Architecture | Synchronous FIFO |
| Data width | 32 bits |
| Depth | 16 entries |
| Storage capacity | 512 bits |
| Clock | 10 ns (100 MHz) |
| Standard-cell library | Nangate45 |
| Storage implementation | Register-based |

The FIFO contains a 16-entry memory array, a 4-bit write pointer, a 4-bit read pointer and a 5-bit occupancy counter.

### 3.2 Functional Operation

- The write pointer selects the location for incoming data.
- The read pointer selects the location from which data is read.
- The occupancy counter tracks the number of stored entries.
- The FULL flag is asserted when the occupancy count reaches 16.
- The EMPTY flag is asserted when the occupancy count is zero.
- A write is accepted only when the FIFO is not full, except when a simultaneous accepted read creates space.
- A read is accepted only when the FIFO is not empty.
- The count increments for write-only operation, decrements for read-only operation and remains unchanged for simultaneous read and write.

The design uses register-based storage. No SRAM macro is instantiated.

## 4. RTL Design and Functional Verification

The RTL source is located at `rtl/sync_fifo.v`. The testbench is located at `testbench/sync_fifo_tb.v`.

The functional testbench verifies:

| Test | Expected result | Status |
|---|---|---|
| Fill all 16 entries | FIFO becomes full | PASS |
| Attempt overflow write | Write rejected | PASS |
| Read all 16 entries | Correct data order | PASS |
| Complete all reads | FIFO becomes empty | PASS |
| Attempt underflow read | Read rejected | PASS |
| Simultaneous read and write | Operation accepted correctly | PASS |

**Overall simulation result: ALL FIFO TESTS PASSED.**

The verification output is available in `reports/fifo_functional_verification.log`.

## 5. Generic Synthesis

Generic synthesis was performed using Yosys.

| Metric | Result |
|---|---:|
| Generic cells | 1,123 |
| Generic enabled storage flip-flops | 512 |
| Generic multiplexers | 480 |
| Yosys design-check problems | 0 |

The 512 enabled storage flip-flops represent the 512 bits of FIFO memory. The generic synthesis report is available in `reports/synthesis_baseline.txt`.

## 6. Technology Mapping

Technology mapping was performed using the Nangate45 standard-cell library.

| Metric | Result |
|---|---:|
| Total mapped standard cells | 1,936 |
| DFF_X1 cells | 557 |
| MUX2_X1 cells | 549 |
| Mapped cell area | 4,423.048 µm² |

The 557 mapped flip-flops account for:

- 512 FIFO storage bits
- 4 write-pointer bits
- 4 read-pointer bits
- 5 occupancy-counter bits
- 32 output-register bits

The total is 557 flip-flops.

The technology-mapping log is available at `reports/technology_mapping.log`.

Generic synthesis cell counts and technology-mapped cell counts belong to different synthesis stages and should not be compared as identical cell categories.

## 7. Timing Constraints

The design uses a 10 ns clock period, corresponding to a nominal frequency of 100 MHz.

The SDC file is `constraints/fifo.sdc`.

The constraints include:

- Clock uncertainty: 0.1 ns
- Clock transition: 0.1 ns
- Input delay: 1.0 ns
- Input transition: 0.1 ns
- Output delay: 1.0 ns
- Output load: 5.0 fF

These are project implementation assumptions and are not a foundry sign-off constraint set.

## 8. Floorplanning and Placement

The initial floorplan target utilization was 40%, with an aspect ratio of 1.0 and a core-space setting of 2 µm.

The floorplan was configured with the Nangate45 placement site. Routing tracks were generated and IO pins were assigned to metal3 for horizontal placement and metal2 for vertical placement.

The effective placement utilization was approximately 40.7%.

Global placement was executed with a target density of 0.40. The placer adjusted the density to 0.45 because of the minimum feasible density requirement.

Detailed placement was then performed to legalize the standard-cell locations.

The placement check reported zero illegal cells and zero illegal sites after legalization.

## 9. Clock Tree Synthesis

Clock Tree Synthesis was performed for the 557 initial clock sinks.

| CTS metric | Result |
|---|---:|
| Initial clock sinks | 557 |
| Clock buffers created | 81 |
| Clock nets created | 81 |
| Maximum reported tree level | 6 |
| Setup clock skew | Approximately 0.11 ns |

The clock tree was generated using the available Nangate45 clock-buffer cells.

After CTS, the clock was propagated for timing analysis.

## 10. Hold Timing Repair

After CTS, setup timing was positive, while a small hold violation was observed.

The hold-repair operation identified three violating endpoints and inserted three hold buffers.

After repair, the reported hold worst negative slack (WNS) and total negative slack (TNS) were both zero at the displayed precision.

The final placement-based timing estimate reports:

- Setup slack: +5.650612 ns
- Hold slack: +0.000058 ns

Both values are positive in the reported placement-based estimate.

## 11. Global Routing

Global routing was performed using metal2 through metal10 as the configured signal and clock routing-layer range.

| Metric | Result |
|---|---:|
| Routing demand | 11,162 |
| Available routing resources | 108,373 |
| Total resource usage | Approximately 10.30% |
| Global-route wire length | 46,859 µm |
| Routed nets | 2,061 |
| Maximum reported congestion | 0 |

The global routing guide is saved as `physical_design/fifo_global_route.guide`.

## 12. Detailed Routing

Detailed routing completed successfully.

| Metric | Result |
|---|---:|
| Detailed-route wire length | 32,714 µm |
| Detailed-route vias | 16,150 |
| Runtime | Approximately 1,008.57 seconds |
| Final detailed-route violations | 0 |

The final detailed-route database is `physical_design/fifo_detailed_route.odb`. The final physical-design database is `physical_design/fifo_final.odb`.

The detailed-route DRC output file is `reports/fifo_detailed_route.drc`. It is empty (zero bytes), consistent with zero final router violations; it is not a full routing log.

Antenna checks reported:

- Net violations: 0
- Pin violations: 0

The final database also reported a routed design status of 1.

## 13. Final Area and Timing Results

### 13.1 Physical Area

| Metric | Result |
|---|---:|
| Final design area | 4,561 µm² |
| Final utilization | 42% |

The mapped cell area and final physical-design area are different measurements. Physical-design operations, including clock-tree and hold-repair cell insertion, affect the final implementation.

### 13.2 Final Placement-Based Timing Estimate

| Metric | Result |
|---|---:|
| Clock period | 10 ns |
| Setup slack | +5.650612 ns |
| Hold slack | +0.000058 ns |
| Setup clock skew | Approximately 0.11 ns |

**Important methodology note:** These final timing values use placement-based parasitic estimation. Detailed routing was completed, but a detailed-route SPEF extraction was not completed. Therefore, these timing numbers must not be described as detailed-route parasitic timing or sign-off timing.

The reproducible timing report is `reports/fifo_final_placement_estimate.rpt`.

## 14. Project Screenshots

The `screenshots/` directory contains:

1. `FIFO_Pre_CTS_Layout.png` — layout before CTS.
2. `FIFO_Final_Detailed_Routed_Layout.png` — complete final detailed-routed layout.
3. `FIFO_Final_Detailed_Routed_Zoom.png` — zoomed view of detailed routing.

## 15. Limitations

1. The FIFO uses register-based storage rather than a compiled SRAM macro.
2. No power analysis or power optimization result is claimed.
3. Detailed-route SPEF extraction and sign-off timing analysis were not completed.
4. No foundry sign-off or fabrication-ready GDSII result is claimed.
5. The project uses the Nangate45 open standard-cell library.
6. The Nangate45 LEF and Liberty files are external dependencies and are not included in this repository.
7. Some Tcl scripts contain local PDK paths that must be updated for another machine.

## 16. Conclusion

A 32-bit, 16-entry synchronous FIFO was implemented and functionally verified. The design was synthesized, technology-mapped and taken through floorplanning, placement, clock tree synthesis, hold repair, global routing and detailed routing using the Nangate45 standard-cell library.

The final detailed-routing process completed with zero final router violations. Antenna checks reported zero net and pin violations. The final physical design has an area of 4,561 µm² and a reported utilization of 42%.

The placement-based timing estimate shows positive setup slack of 5.650612 ns and positive hold slack of 0.000058 ns. These results demonstrate practical experience with the standard-cell physical-design flow and clock-tree timing optimization.

## 17. Tools Used

- Verilog HDL
- Icarus Verilog
- Yosys
- OpenROAD
- Nangate45 standard-cell library
- Tcl
- Ubuntu Linux / WSL
