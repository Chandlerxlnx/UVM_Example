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

module axi_vip_0_lab1_tb(
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
  xil_axi_uint                           mem_agent_verbosity = 0;
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
  ex_sim_axi_vip_slv_0_slv_mem_t                                  mem_agent;
  ex_sim_axi_vip_passthrough_0_passthrough_mem_t                  passthrough_mem_agent;

  //+--------------------------------------------------------------------------------------
  // step 3 defines for transactions
  
  //Simple loop integer
  integer                                 i; 
  // Simple loop integer. 
  integer                                 j; 
  // Error count to check how many comparison failed
  xil_axi_uint                            error_cnt = 0; 
  // Comparison count to check how many comparsion happened
  xil_axi_uint                            comparison_cnt = 0;

  axi_transaction                                          wr_trans;            // Write transaction
  axi_transaction                                          rd_trans;            // Read transaction
  xil_axi_uint                                             mtestWID;            // Write ID  
  xil_axi_ulong                                            mtestWADDR;          // Write ADDR  
  xil_axi_len_t                                            mtestWBurstLength;   // Write Burst Length   
  xil_axi_size_t                                           mtestWDataSize;      // Write SIZE  
  xil_axi_burst_t                                          mtestWBurstType;     // Write Burst Type  
  xil_axi_uint                                             mtestRID;            // Read ID  
  xil_axi_ulong                                            mtestRADDR;          // Read ADDR  
  xil_axi_len_t                                            mtestRBurstLength;   // Read Burst Length   
  xil_axi_size_t                                           mtestRDataSize;      // Read SIZE  
  xil_axi_burst_t                                          mtestRBurstType;     // Read Burst Type  

  /*************************************************************************************************  
  * the following monitor transactions are for simple scoreboards doing self-checking
  * two Scoreboards are built here
  * one scoreboard checks master vip against passthrough VIP (scoreboard 1)
  * the other one checks passthrough VIP against slave VIP (scoreboard 2)
  * monitor transaction from master VIP
  ***********************************************************************************************/
  axi_monitor_transaction                 mst_monitor_transaction;
  axi_monitor_transaction                 master_moniter_transaction_queue[$];
  xil_axi_uint                            master_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 mst_scb_transaction;
  axi_monitor_transaction                 passthrough_monitor_transaction;
  axi_monitor_transaction                 passthrough_master_moniter_transaction_queue[$];
  xil_axi_uint                            passthrough_master_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 passthrough_mst_scb_transaction;
  axi_monitor_transaction                 passthrough_slave_moniter_transaction_queue[$];
  xil_axi_uint                            passthrough_slave_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 passthrough_slv_scb_transaction;
  axi_monitor_transaction                 slv_monitor_transaction;
  axi_monitor_transaction                 slave_moniter_transaction_queue[$];
  xil_axi_uint                            slave_moniter_transaction_queue_size =0;
  axi_monitor_transaction                 slv_scb_transaction;
  //- end step 3 defines
  //----------------------------------------------------------------------------------------
  
     
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
    mem_agent = new("slave vip agent with memory model",DUT.ex_sim_i.axi_vip_slv.inst.IF);
    passthrough_mem_agent = new("passthrough vip agent with memory model",DUT.ex_sim_i.axi_vip_passthrough.inst.IF);
    $timeformat (-12, 1, " ps", 1);
    /*************************************************************************************************  
    * set tag for agents for easy debug,if not set here, it will be hard to tell which driver is filing 
    * if multiple agents are called in one testbench
    ***********************************************************************************************/
    $display("======= Debug: agent set_agent_tags");
    mst_agent.set_agent_tag("Master VIP");
    mem_agent.set_agent_tag("Slave VIP");
    passthrough_mem_agent.set_agent_tag("Passthrough VIP");
    // set print out verbosity level.
    mst_agent.set_verbosity(mst_agent_verbosity);
    mem_agent.set_verbosity(mem_agent_verbosity);
    passthrough_mem_agent.set_verbosity(passthrough_agent_verbosity);
    /*************************************************************************************************  
    * master,slave agents start to run 
    * turn monitor on passthrough agent
    ***********************************************************************************************/
    mst_agent.start_master();
    mem_agent.start_slave();
    passthrough_mem_agent.start_monitor();
    $display("Debug: agents have been started");
    /*************************************************************************************************/
    // -end step 2
    
    //+----------------------------------------------------------------------------------------------
    // Step 3, add transactions
    /*************************************************************************************************  
    * parallel process 
    * 1. Master VIP create write/read transaction,
    * 2. Master VIP and Slave VIP generate no backpressure signals.
    *  2.1 generate an no backpressure arready signal  
    *  2.2 generate an no backpressure awready signal  
    *  2.3 generate an no backpressure wready signal  
    *  2.4 generate an no backpressure rready signal  
    *  2.5 generate an no backpressure bready signal  
    ***********************************************************************************************/
    $display("Debug: to set no backpressure mode");
    slv_no_backpressure_readies();
    mst_no_backpressure_readies();
    $display("Debug: config master and slave to no back pressure mode");
   
    fork
 
      begin
        mtestWID = $urandom_range(0,(1<<(0)-1)); 
        mtestWADDR = 0;
        mtestWBurstLength = 0;
        mtestWDataSize = xil_axi_size_t'(xil_clog2((32)/8));
        mtestWBurstType = XIL_AXI_BURST_TYPE_INCR;
        //multiple write transactions with the same inline randomization 
        multiple_write_transaction_partial_rand(.num_xfer(10),
                                              .start_addr(mtestWADDR),
                                              .id(mtestWID),
                                              .len(mtestWBurstLength),
                                              .size(mtestWDataSize),
                                              .burst(mtestWBurstType),
                                              .no_xfer_delays(1)
                                             );
       end
 
      begin
        mtestRID = $urandom_range(0,(1<<(0)-1));
        mtestRADDR = $urandom_range(0,(1<<(32)-1));
        mtestRBurstLength = 0;
        mtestRDataSize = xil_axi_size_t'(xil_clog2((32)/8)); 
        mtestRBurstType = XIL_AXI_BURST_TYPE_INCR;
        multiple_read_transaction_partial_rand( .num_xfer(10),
                                                .start_addr(mtestRADDR),
                                                .id(mtestRID),
                                                .len(mtestRBurstLength),
                                                .size(mtestRDataSize),
                                                .burst(mtestRBurstType),
                                                .no_xfer_delays(1)
                                               ); 
      end
  
    join
    mst_agent.wait_drivers_idle();
    
 
   
   $display("Debug: step3, 1 test no back pressure ready done");
   //-step 3 no backpressure ready done
   //----------------------------------------------------------------------------------------------------
   
 end   
 
 `include "lab1_step3_ready_task.inc"
 
endmodule
