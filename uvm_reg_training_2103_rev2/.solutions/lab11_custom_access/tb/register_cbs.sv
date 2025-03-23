/*-----------------------------------------------------------------
File name     : register_cbs.sv
Developers    : Brian Dickinson
Created       : 01/04/22
Description   : This file implements the callbacks for the custom register access lab
Notes         : 
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2022 
-----------------------------------------------------------------*/

// write set 8'h5A access policy

class write_set_5a_read_set_cb extends uvm_reg_cbs;
    
  `uvm_object_utils(write_set_5a_read_set_cb)
  
  function new(string name = "write_set_5a_read_set_cb");
    super.new(name);
  endfunction: new
  
  virtual function void post_predict(input uvm_reg_field  fld,
                                     input uvm_reg_data_t previous,
                                     inout uvm_reg_data_t value,
                                     input uvm_predict_e  kind,
                                     input uvm_path_e     path,
                                     input uvm_reg_map    map);

    `uvm_info("REG_CB", $sformatf("post_predict() called for field %s, value: %2h, previous: %2h, kind: %s, path: %s",
             fld.get_name(), value, previous, kind.name(), path.name()), UVM_HIGH); 
    
    if (kind == UVM_PREDICT_WRITE) 
      value = 8'h5A;
    else if (kind == UVM_PREDICT_READ) 
      value = 8'hFF;
      
  endfunction

endclass

// enabled register write. enable property is write-enable bit for register

class enable_bits_cb extends uvm_reg_cbs;
    
  //`uvm_object_utils(enable_bits_cb)

  uvm_reg_field enable;
  
  function new(string name = "enable_bits_cb",uvm_reg_field enb);
    super.new(name);
    enable = enb;
  endfunction: new
  
  virtual function void post_predict(input uvm_reg_field  fld,
                                     input uvm_reg_data_t previous,
                                     inout uvm_reg_data_t value,
                                     input uvm_predict_e  kind,
                                     input uvm_path_e     path,
                                     input uvm_reg_map    map);

    `uvm_info("REG_CB", $sformatf("\n\nenable_bits_cb called for field %s, value: %2h, previous: %2h, kind: %s, path: %s, enable %h",
             fld.get_name(), value, previous, kind.name(), path.name(), enable.get()), UVM_HIGH); 
    
    if (kind == UVM_PREDICT_WRITE)
      if (!enable.get_mirrored_value())
        value = previous;

  endfunction

endclass


// aliased register write. aliased property is register which is written when current register is written

class alias_reg_cb extends uvm_reg_cbs;
    
  //`uvm_object_utils(alias_reg_cb)
  uvm_reg_field aliased;
  int ok;
  
  function new(string name = "alias_reg_cb", uvm_reg_field al);
    super.new(name);
    aliased = al;
  endfunction: new
  
  virtual function void post_predict(input uvm_reg_field  fld,
                                     input uvm_reg_data_t previous,
                                     inout uvm_reg_data_t value,
                                     input uvm_predict_e  kind,
                                     input uvm_path_e     path,
                                     input uvm_reg_map    map);

    `uvm_info("REG_CB", $sformatf("post_predict() called for field %s, value: %2h, previous: %2h, kind: %s, path: %s",
             fld.get_name(), value, previous, kind.name(), path.name()), UVM_HIGH); 
    
      if (kind == UVM_PREDICT_WRITE) 
        ok = aliased.predict(value, -1, UVM_PREDICT_DIRECT, path, map);

      
  endfunction

endclass

