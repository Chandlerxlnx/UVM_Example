
  /***********************************************************************************************
  * byte_compare task
  * 1.open binary file
  * if the line is not the end line of the file, do
  *   2.use $fgetc to get char and save it to payload
  *   3.assign payload to corresponding tmp_payload index, tmp_payload is related to DATA_WIDTH of 
  *     this IP
  * 4. repeat 2 and 3 till tmp_payload is being filled 
  * 5. back door read data out of memory from memory model with start address which has been used
  *    to do pre_load_memory and assign it to mem_payload
  * 6. compare tmp_payload and mem_payload
  * repeat 2,3,4,5,6 till the end line of the binary file.
  ***********************************************************************************************/
  function automatic void byte_compare (string data_file,xil_axi_ulong addr);
    xil_axi_uint                           file_handle;
    //Use $fgetc to get char and save it to payload
    xil_axi_payload_byte                   payload;
    // tmp_data used to fill memory model
    //File line number
    xil_axi_boolean_t                      file_empty;
    xil_axi_uint                           addr_offset;
    bit [32-1:0]            mem_payload;
    bit [32-1:0]            tmp_payload;
    xil_axi_uint                           byte_cnt;
    
    addr_offset = addr%(32/8);     
    file_empty = XIL_AXI_TRUE;
    byte_cnt =0;
    file_handle = $fopen(data_file,"rb");
    if (file_handle == 0) begin
      $display("ERROR",$sformatf("file %s planned to be loaded into memory doesn't exist, please make sure the right file is being called", data_file));
    end else begin
      while (! $feof(file_handle) && (addr<(1<<(32) -1)) ) begin
        payload = $fgetc(file_handle);
        if(payload != 8'hff) begin
          if( file_empty == XIL_AXI_TRUE) begin  
            file_empty = XIL_AXI_FALSE;  
          end
          tmp_payload[(byte_cnt+addr_offset)*8+:8] = payload;  
          byte_cnt +=1;
          if((byte_cnt+addr_offset) == (32/8)) begin
            mem_payload = slv_mem_agent.mem_model.backdoor_memory_read(addr);
            if (mem_payload != tmp_payload) begin
              $error("back_door_read %h doesn't match expected %h",mem_payload, tmp_payload);
              error_cnt++;
            end
            byte_cnt =0;
            addr_offset =0;
            addr +=(32/8);
            tmp_payload ='bx;
          end     
        end   
      end
      if(((byte_cnt+addr_offset)!= 32/8) && (byte_cnt >0)) begin
        mem_payload = slv_mem_agent.mem_model.backdoor_memory_read(addr);
        if (mem_payload != tmp_payload) begin
          $error("back_door_read %h doesn't match expected %h",mem_payload, tmp_payload);
          error_cnt++;
        end
      end                 
      if(file_empty == XIL_AXI_TRUE) begin
        $display("Error",$sformatf("file %s planned to be load into memory is empty, please make sure it has contents", data_file));
      end
      $fclose(file_handle);
    end    
  endfunction : byte_compare

  /*************************************************************************************************
  *  Task set_mem_default_value_fixed is to first fill in memory with policy
  *   XIL_AXI_MEMORY_FILL_FIXED, then it will fill in default memory value with
  *   input bit[DATA_WIDTH-1:0] fill_payload
  *   Note: user has to make sure that fill_payload is DATA_WIDTH wide bit to match
  *   memory model width. 
  *************************************************************************************************/
  task set_mem_default_value_fixed(input bit [32-1:0] fill_payload);
    slv_mem_agent.mem_model.set_memory_fill_policy(XIL_AXI_MEMORY_FILL_FIXED);
    slv_mem_agent.mem_model.set_default_memory_value(fill_payload);
  endtask

  /*************************************************************************************************
  * Task set_mem_default_value_rand is to fill in memory with policy
  * XIL_AXI_MEMORY_FILL_RADNOM, default memory value will be randomized generated
  * when the address is being accessed 
  *************************************************************************************************/
  task set_mem_default_value_rand();
    slv_mem_agent.mem_model.set_memory_fill_policy(XIL_AXI_MEMORY_FILL_RANDOM);
  endtask

  /*************************************************************************************************
  * Task backdoor_mem_write shows how to write to some address of memory with data and strobe 
  * information.
  * User has to make sure that the inputs to this task has to follow below rules to match
  * memory width, also user has to make sure that strobe bits can not be asserted on if lower 
  * than the address offset.
  * Address offset calculation is: address offset = address &((1 << (log2(DATA_WIDTH/8)) -1))
  *  input xil_axi_ulong                         addr, 
  *  input bit [DATA_WIDTH-1:0]                  wr_data
  *  input bit [(DATA_WIDTH/8)-1:0]              wr_strb 
  *************************************************************************************************/
  task backdoor_mem_write(
    input xil_axi_ulong                         addr, 
    input bit [32-1:0]           wr_data,
    input bit [(32/8)-1:0]       wr_strb ={(32/8){1'b1}}
  );
    slv_mem_agent.mem_model.backdoor_memory_write(addr, wr_data, wr_strb);

  endtask

  /*************************************************************************************************
  * Task backdoor_mem_read shows how user can do backdoor read data from memory model
  * it has one input which is backdoor memory read address and one output which is read out data
  * User has to note to declare memory read address and data like below
  * input xil_axi_ulong mem_rd_addr,
  * output bit [DATA_WIDTH-1:0] mem_rd_data 
  *************************************************************************************************/
  task backdoor_mem_read(
    input xil_axi_ulong mem_rd_addr,
    output bit [32-1:0] mem_rd_data
   );
    mem_rd_data= slv_mem_agent.mem_model.backdoor_memory_read(mem_rd_addr);

  endtask

  /*************************************************************************************************
  * Task write_memory_to_binary shows how user can read the memory information to a binary file
  * with a start address till the end of the memory if the address width of this IP is smaller than
  * 20, else if will stop at address (1<<20 -1)
  *************************************************************************************************/
  task write_memory_to_binary(string file_name, xil_axi_ulong addr);
    xil_axi_uint                   file_handle;
    xil_axi_uint                   addr_width;
    bit[32-1:0]     tmp_payload;

    if(addr > ( (1 << (32))-1) ) begin
      $error($sformatf("Addr(0x%0x) is out of range(0x%0x). Address will be truncated.",addr,( (1 << (32))-1)));
      addr &= ( (1 << (32)) - 1);
    end

    addr_width = 32;
    if (addr_width >20) begin
      addr_width =20;
    end
    file_handle = $fopen(file_name, "wb");
    while (addr < ( 1 << (addr_width -1)) ) begin
      backdoor_mem_read(addr, tmp_payload);
        for(xil_axi_uint byte_cnt =0; byte_cnt < (32/8); byte_cnt++) begin
          $fwrite(file_handle,"%c",tmp_payload[byte_cnt*8+:8]);
        end  
      addr += (32/8);
    end
    $fclose(file_handle);
  endtask :write_memory_to_binary

  /*************************************************************************************************
  * Partial randomization of transaction
  * This simple task shows paritaly randomize one transaction with fixed value for ID,ADDR,LENGTH,
  * SIZE and BURST.User can following this task and create some other partial randomized transaction
  * Fatal will show up if randomizaiton failed
  * NOTE: Please don't use this task in VIVADO Simulator for it's limitiaton of SV support.
  *************************************************************************************************/

  task automatic inline_randomize_transaction(inout axi_transaction trans,
                                              input xil_axi_uint id_val,
                                              input xil_axi_ulong addr_val,
                                              input xil_axi_len_t len_val,
                                              input xil_axi_size_t size_val,
                                              input xil_axi_burst_t burst_val); 
    if(! ((trans.randomize() with {
         id == id_val; 
         addr==addr_val; 
         len==len_val;
         size ==size_val;
         burst ==burst_val;
     }))) begin
        $fatal(1,"inline_randomize_transaction of %s failed at time =%t",trans.get_name(), $realtime);     
       end
  endtask : inline_randomize_transaction


  /************************************************************************************************* 
  * This task is to queue up multiple transactions with the same id, length,size, burst type
  * and incrementd addr with different data. then it send out all these transactions 
  * 1. Declare a handle for write transaction
  * 2. set delay range if user set there transction is of no delay
  * 3. constraint randomize the transaction
  * 4. increment the addr
  * 5. repeat 1-4 to generate num_xfer transaction
  * 6. send out the transaction
  *************************************************************************************************/
  
  task automatic multiple_write_transaction_partial_rand(
                              input xil_axi_uint    num_xfer =1,
                              input xil_axi_ulong   start_addr =0,
                              input xil_axi_uint    id =0,
                              input xil_axi_len_t   len =0,
                              input xil_axi_size_t  size =xil_axi_size_t'(xil_clog2((32)/8)),
                              input xil_axi_burst_t burst = XIL_AXI_BURST_TYPE_INCR,
                              input bit             no_xfer_delays =0  
                                        );
    axi_transaction                                          wr_tran[];
    xil_axi_ulong                                            addr;
    xil_axi_data_beat                                        dbeat;

    wr_tran =new[num_xfer];
    addr = start_addr;

    // queue up transactions
    for (int i =0; i <num_xfer; i++) begin
      wr_tran[i] = mst_agent.wr_driver.create_transaction($sformatf("write_multiple_transaction id =%0d",i));
      if(no_xfer_delays ==1) begin
        wr_tran[i].set_data_insertion_delay_range(0,0);
        wr_tran[i].set_addr_delay_range(0,0);
        wr_tran[i].set_beat_delay_range(0,0);
      end  
      inline_randomize_transaction(.trans(wr_tran[i]), 
                                   .id_val(id), 
                                   .addr_val(addr),
                                   .len_val(len),
                                   .size_val(size), 
                                   .burst_val(burst));
      //put transaction data into byte memory
      for(xil_axi_uint beat_cnt=0; beat_cnt < wr_tran[i].get_len()+1; beat_cnt++) begin
        dbeat = wr_tran[i].get_data_beat(beat_cnt);
        for(xil_axi_uint byte_cnt =0; byte_cnt < (1<<wr_tran[i].get_size()); byte_cnt++) begin
          byte_mem[addr] = dbeat[(byte_cnt * 8)+:8];
          addr +=1;
        end  
      end
    end
    //send out transaction
    for (int i =0; i <num_xfer; i++) begin
       mst_agent.wr_driver.send(wr_tran[i]);
    end
  endtask :multiple_write_transaction_partial_rand

  /***********************************************************************************************
  * backdoor_read_compare : this task is to read data out from memory model of slave VIP 
  * with start address and a number of reads.
  ***********************************************************************************************/
  task backdoor_read_compare(xil_axi_uint length,xil_axi_ulong addr);
    bit[32-1:0]    temp_payload;
    for(xil_axi_uint len =0; len < length; len++) begin
      temp_payload = slv_mem_agent.mem_model.backdoor_memory_read(addr);
      for(xil_axi_uint byte_cnt=0; byte_cnt < (32/8); byte_cnt++) begin
        if(byte_mem[addr] != temp_payload[(byte_cnt * 8)+:8]) begin
          $error("read back %h doesn't match write in %h",temp_payload[(byte_cnt * 8)+:8], byte_mem[addr]);
          error_cnt++;
        end  
        addr +=1;
      end  
    end
  endtask: backdoor_read_compare

