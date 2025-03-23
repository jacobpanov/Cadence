class indirect_frontdoor extends uvm_reg_frontdoor;

  `uvm_object_utils(indirect_frontdoor)
  uvm_status_e status;

  // indirect address location for register
  // set by configuration
  bit [7:0] idxaddr;
  // indirect data location for register
  bit [7:0] idxdata;
  // offset address for register
  bit [7:0] offset;

  function new(string name="indirect_frontdoor");
    super.new(name);
  endfunction

  function void configure(bit[7:0] idxaddr, idxdata);
    this.idxaddr = idxaddr;
    this.idxdata = idxdata;
  endfunction 

  function bit[7:0] offset_lut(string regname);
    case(regname)
      "reg_eight": return 8'h0; 
      "reg_nine" : return 8'h1; 
      default    : `uvm_error("indirectFD",$sformatf("Unmapped Register name: %s",regname))
    endcase
  endfunction

  virtual task body();
    uvm_reg regitem;
    reg_txn req;
    $cast(regitem, rw_info.element);
    //item = reg_txn::type_id::create("item");
    `uvm_info("indirectFD",$sformatf("Register name: %s",regitem.get_name()) ,UVM_MEDIUM)
    offset = offset_lut(regitem.get_name());

    // write address to indirect address register
    `uvm_do_with(req, {addr == idxaddr; data == offset; reg_wr == REG_WR;})
    `uvm_info("indirectFD",$sformatf("Transaction \n%s",req.sprint()),UVM_MEDIUM)
   // read/write data from indirect data register
    `uvm_do_with(req, {addr == idxdata; 
                       data == rw_info.value[0];
                       rw_info.kind == UVM_READ -> reg_wr == REG_RD;
                       rw_info.kind == UVM_WRITE -> {reg_wr == REG_WR;}})
    if (rw_info.kind == UVM_READ)
      rw_info.value[0] = req.data;
    `uvm_info("indirectFD",$sformatf("Transaction \n%s",req.sprint()),UVM_MEDIUM)

  endtask

endclass
