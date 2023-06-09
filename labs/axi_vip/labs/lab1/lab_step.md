# lab to create VIP simulation and tb 

## lab1 create a simple test bench
1. create a sime test design with VIP master, passthrough and slave.
  + script: ./script/crt_sim_lab1_step1.tcl
  + in the test bench, there is only package imported and DUT. after run the simulation, it report the VIP path as below, the VIP agent should be created with path it reported.
```TCL
# run 1000ns
XilinxAXIVIP: Found at Path: axi_vip_0_exdes_ready_tb.DUT.ex_sim_i.axi_vip_mst.inst
XilinxAXIVIP: Found at Path: axi_vip_0_exdes_ready_tb.DUT.ex_sim_i.axi_vip_passthrough.inst
This AXI VIP is in passthrough mode
XilinxAXIVIP: Found at Path: axi_vip_0_exdes_ready_tb.DUT.ex_sim_i.axi_vip_slv.inst
```
2. add agents
  step lab
  + open project created by step1
  + source lab1_step2.tcl
  
  * error:
```
RROR: 110000.0 ps axi_vip_0_lab1_tb.DUT.ex_sim_i.axi_vip_mst.inst.IF  : XILINX_RESET_PULSE_WIDTH: Holding AXI ARESETN asserted for 16 cycles of the slowest AXI clock is generally a sufficient reset pulse width for Xilinx IP. --UG1037. To downgrade, use <hierarchy_path to VIP>.IF.set_xilinx_reset_check_to_warn(), or filter using clr_xilinx_reset_check().
ERROR: 110000.0 ps axi_vip_0_lab1_tb.DUT.ex_sim_i.axi_vip_passthrough.inst.IF  : XILINX_RESET_PULSE_WIDTH: Holding AXI ARESETN asserted for 16 cycles of the slowest AXI clock is generally a sufficient reset pulse width for Xilinx IP. --UG1037. To downgrade, use <hierarchy_path to VIP>.IF.set_xilinx_reset_check_to_warn(), or filter using clr_xilinx_reset_check().
ERROR: 110000.0 ps axi_vip_0_lab1_tb.DUT.ex_sim_i.axi_vip_slv.inst.IF  : XILINX_RESET_PULSE_WIDTH: Holding AXI ARESETN asserted for 16 cycles of the slowest AXI clock is generally a sufficient reset pulse width for Xilinx IP. --UG1037. To downgrade, use <hierarchy_path to VIP>.IF.set_xilinx_reset_check_to_warn(), or filter using clr_xilinx_reset_check().
r
```
 * fix: give longer reset

3. step 3 add no back press ready transactions
   * cmd
   source lab1_step3.tcl

