/************************************************************************************************
* Description: 
* This file contains example test lists for one design which consistes of one AXI VIP
* in master mode, one AXI VIP in passthrough mode and one AXI VIP in slave mode.
* Ready signals of write command channel,write data channel, write response channel,read command
* channel and read data channel are generated independently from axi_transaction. The axi_ready_gen
* is the class used for ready generation. Please refer PG267 about READY Generation section for 
* more details.
* Once ready policy is being created, it won't change until user change the ready policy. 

* The main purpose in this example design is to demonstrate how to generate noback pressure ready 
* patterns being followed by random policy in AXI Master/Slave/PASSTHROUGH VIP, other ready 
* signals can be generated similarly.
* 
* It also has two simple scoreboards to do self-checking. One scoreboard checks master AXI VIP against
* passthrough AXI VIP and the other scoreboard checks slave AXI VIP against passthrough AXI VIP
***********************************************************************************************/

`timescale 1ns / 1ps
// import package 
import axi_vip_pkg::*;
import ex_sim_axi_vip_mst_0_pkg::*;
import ex_sim_axi_vip_slv_0_pkg::*;
import ex_sim_axi_vip_passthrough_0_pkg::*;

module axi_vip_0_lab_tb(
  );

  typedef enum {
    EXDES_PASSTHROUGH,
    EXDES_PASSTHROUGH_MASTER,
    EXDES_PASSTHROUGH_SLAVE
  } exdes_passthrough_t;

  exdes_passthrough_t                     exdes_state = EXDES_PASSTHROUGH;

  /*************************************************************************************************  
  * Parameterized agents which customer needs to declare according to AXI VIP configuration
  * If AXI VIP is being configured in master mode, axi_mst_agent has to declared 
  * If AXI VIP is being configured in slave mode, axi_mem_agent has to be declared 
  * If AXI VIP is being configured in pass-through mode, axi_passthrough_agent has to be declared
  * "component_name"_mst_t for master agent
  * "component_name"_slv_t for slave agent
  * "component_name"_passthrough_t for passthrough agent
  * "component_name can be easily found in vivado bd design: click on the instance, 
  * then click CONFIG under Properties window and Component_Name will be shown
  * more details please refer PG267 for more details
  ***********************************************************************************************/
  //ex_sim_axi_vip_mst_0_mst_t                                      mst_agent;
  //ex_sim_axi_vip_slv_0_slv_mem_t                                  mem_agent;
  //ex/_sim_axi_vip_passthrough_0_passthrough_mem_t                  passthrough_mem_agent;

  
     
  // Clock signal
  bit                                     clock;
  // Reset signal
  bit                                     reset;

  // instantiate bd
    //chip DUT(
    ex_sim_wrapper DUT(
        .aresetn(!reset),
  
      .aclk(clock)
    );

  initial begin
    reset <= 1'b1;
    repeat (5) @(negedge clock);
    reset =0;
  end
  
  always #10 clock <= ~clock;

endmodule
