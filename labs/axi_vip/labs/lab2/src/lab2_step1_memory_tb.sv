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

  //+------------------------------------------------------------------------------------------
  // Step 2 defines for agents
  /*************************************************************************************************  
  * verbosity level which specifies how much debug information to produce
  * 0       - No information will be printed out.
  * 400      - All information will be printed out.
  * master VIP agent verbosity level
  ***********************************************************************************************/
  xil_axi_uint                           mst_agent_verbosity = 0;
  xil_axi_uint                           slv_mem_agent_verbosity = 0;
  xil_axi_uint                           passthrough_agent_verbosity = 0;

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
  ex_sim_axi_vip_mst_0_mst_t                                      mst_agent;
  ex_sim_axi_vip_slv_0_slv_mem_t                                  slv_mem_agent;
  ex_sim_axi_vip_passthrough_0_passthrough_mem_t                  passthrough_mem_agent;

  //+--------------------------------------------------------------------------------------
  // step 3 defines memory model
   xil_axi_uint                                              addr_rand;
  /************************************************************************************************
  * Declare payload, address, data and strobe for back door memory write/read
  * xil_axi_ulong                                           mem_wr_addr;
  * xil_axi_ulong                                           mem_rd_addr;
  * bit[DATA_WIDTH-1:0]                                     mem_wr_data;
  * bit[(DATA_WIDTH/8)-1:0]                                 mem_wr_strb;
  * bit[DATA_WIDTH-1:0]                                     mem_rd_data;
  * bit[DATA_WIDTH-1:0]                                     mem_fill_payload;
  ***********************************************************************************************/

  xil_axi_ulong                                             mem_wr_addr;
  xil_axi_ulong                                             mem_rd_addr;
  bit[32-1:0]                                mem_wr_data;
  bit[(32/8)-1:0]                            mem_wr_strb;
  bit[32-1:0]                                mem_rd_data;
  bit[32-1:0]                                mem_fill_payload;
  
  xil_axi_payload_byte                                      byte_mem[xil_axi_ulong];
  xil_axi_uint                                              error_cnt =0;

  //********************************************************************************************/   
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
    repeat (17) @(negedge clock);
    reset =0;
  end
  
  always #10 clock <= ~clock;

  initial begin
    // create master and slave monitor transaction
    //mst_monitor_transaction = new("master monitor transaction");
    //slv_monitor_transaction = new("slave monitor transaction");
    /*************************************************************************************************  
    * The hierarchy path of the AXI VIP's interface is passed to the agent when it is newed. 
    * Method to find the hierarchy path of AXI VIP is to run simulation without agents being newed, 
    * message like "Xilinx AXI VIP Found at Path: my_ip_exdes_ready_tb.DUT.ex_design.axi_vip_mst.inst" will 
    * be printed out.
    ***********************************************************************************************/
    $display("=========Debug, step 2 New agent======");
    mst_agent = new("master vip agent",DUT.ex_sim_i.axi_vip_mst.inst.IF);
    slv_mem_agent = new("slave vip agent with memory model",DUT.ex_sim_i.axi_vip_slv.inst.IF);
    passthrough_mem_agent = new("passthrough vip agent with memory model",DUT.ex_sim_i.axi_vip_passthrough.inst.IF);
    $timeformat (-12, 1, " ps", 1);
    /*************************************************************************************************  
    * set tag for agents for easy debug,if not set here, it will be hard to tell which driver is filing 
    * if multiple agents are called in one testbench
    ***********************************************************************************************/
    $display("=============\n Debug: agent set_agent_tags");
    mst_agent.set_agent_tag("Master VIP");
    slv_mem_agent.set_agent_tag("Slave VIP");
    passthrough_mem_agent.set_agent_tag("Passthrough VIP");
    // set print out verbosity level.
    mst_agent.set_verbosity(mst_agent_verbosity);
    slv_mem_agent.set_verbosity(slv_mem_agent_verbosity);
    passthrough_mem_agent.set_verbosity(passthrough_agent_verbosity);
    /*************************************************************************************************  
    * master,slave agents start to run 
    * turn monitor on passthrough agent
    ***********************************************************************************************/
    mst_agent.start_master();
    slv_mem_agent.start_slave();
    passthrough_mem_agent.start_monitor();
    $display("Debug: agents have been started");
    /*************************************************************************************************/
    // -end step 2 backdoor read/write memory
   
    error_cnt = 0;
    addr_rand = 0;
    slv_mem_agent.mem_model.pre_load_mem("compile.sh", addr_rand);
    byte_compare("compile.sh",addr_rand);

    #10;

    write_memory_to_binary("compile.sh_cp",addr_rand);
    /***********************************************************************************************
    * Backdoor memory tasks
    * 1.fill fixed default value to memory 
    *    user can choose task set_mem_default_value_fixed or set_mem_default_value_rand
    *    in this testcase the former is being used
    * 2. do a backdoor memory write
    * 3. do a backdoor memory read
    ***********************************************************************************************/
    mem_fill_payload = 1;
    set_mem_default_value_fixed(mem_fill_payload); // Call task to do fill in memory with default fixed value
    mem_wr_data = 20;
    mem_wr_addr= 0;
    mem_wr_strb = 1;
    backdoor_mem_write(mem_wr_addr, mem_wr_data, mem_wr_strb); //Call task to do back doore memory wirte
    mem_rd_addr =0;
    backdoor_mem_read(mem_rd_addr, mem_rd_data);   // Call task to do back door memory read
  
    multiple_write_transaction_partial_rand(20,0);
    mst_agent.wait_drivers_idle();
    backdoor_read_compare(20,0);
    #10;
    #1ns;
    if(error_cnt ==0) begin
      $display("EXAMPLE TEST DONE : Test Completed Successfully");
    end else begin  
      $display("EXAMPLE TEST DONE ",$sformatf("Test Failed: %d Comparison Failed", error_cnt));
    end 
    $finish();
   //-step 2 no backpressure ready done
   //----------------------------------------------------------------------------------------------------
   
 end   
 
 `include "vip_memory.inc"
 
endmodule
