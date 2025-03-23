/*-------------------------------------------------------------------------
File name   : reg_adapter.sv
Title       : 
Project     :
Created     :
Description : 
            : 
Notes       : 
            : 
------------------------------------------------------------------------*/

class reg_adapter extends uvm_reg_adapter;

`uvm_object_utils(reg_adapter)

  function new(string name="reg_adapter");
    super.new(name);
  endfunction : new

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    reg_txn item;
    item = reg_txn::type_id::create("item");
    item.addr = rw.addr;
    item.data = rw.data;
    item.reg_wr = (rw.kind == UVM_READ) ? REG_RD : REG_WR;
    return (item);
  endfunction : reg2bus

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    reg_txn item;
    if (!$cast(item, bus_item)) begin
      `uvm_fatal("NOT_REG_TYPE",
       "Provided bus_item is not of the correct type. Expecting reg_txn")
       return;
    end
    rw.addr = item.addr;
    rw.data = item.data;
    rw.kind = (item.reg_wr == REG_RD) ? UVM_READ : UVM_WRITE;
    rw.status = UVM_IS_OK;

  endfunction  : bus2reg

endclass : reg_adapter
