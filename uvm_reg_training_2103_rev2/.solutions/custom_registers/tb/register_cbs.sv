class write_set_5a_cb extends uvm_reg_cbs;
    
  `uvm_object_utils(write_set_5a_cb)
  
  function new(string name = "write_set_5a_cb");
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
    
    if (kind == UVM_PREDICT_WRITE) begin
      value = 8'h5A;
    end
      
  endfunction

endclass

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
      if (!enable.get())
        value = previous;

  endfunction

endclass

class alias_reg_cb extends uvm_reg_cbs;
    
  //`uvm_object_utils(alias_reg_cb)
  uvm_reg_field aliased;
  
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
        void'(aliased.predict(value, -1, UVM_PREDICT_DIRECT, path, map));

      
  endfunction

endclass

