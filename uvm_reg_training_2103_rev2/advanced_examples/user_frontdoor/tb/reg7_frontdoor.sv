class reg7_frontdoor extends uvm_reg_frontdoor;

  `uvm_object_utils(reg7_frontdoor)
  uvm_status_e status;

  function new(string name="reg7_frontdoor");
    super.new(name);
  endfunction

//  function void configure(uvm_reg idx, uvm_reg data, bit [7:0] addr);
//    m_idx = idx;;
//    m_data = data;
//    m_addr = addr;
//  endfunction: new

  virtual task body();
    uvm_reg regitem;
    reg_txn req;
    $cast(regitem, rw_info.element);
    //item = reg_txn::type_id::create("item");
    `uvm_create(req)
    req.addr = regitem.get_address();
    req.data = rw_info.value[0];
    req.reg_wr = (rw_info.kind == UVM_READ) ? REG_RD : REG_WR;
    `uvm_send(req)
    if (rw_info.kind == UVM_READ)
      rw_info.value[0] = req.data;
    `uvm_info("reg7FD",$sformatf("Transaction \n%s",req.sprint()),UVM_LOW)
  endtask

endclass
