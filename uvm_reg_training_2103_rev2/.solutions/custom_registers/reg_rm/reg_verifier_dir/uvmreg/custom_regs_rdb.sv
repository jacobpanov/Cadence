//*************************************************************//
//   ** File Generated Automatically
//   ** Please donot edit manually
//*************************************************************//


package custom_regs_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import cdns_uvmreg_utils_pkg::*;

  bit no_factory = 0; 

/////////////////////////////////////////////////////
//                reg_five
/////////////////////////////////////////////////////
class T_reg_five_22 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_five_22)
  rand uvm_reg_field reg_five_fld;
  
  covergroup wr_fld_covg;
    reg_five_fld: coverpoint reg_five_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_five_fld: coverpoint reg_five_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_five_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_five_22");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_four
/////////////////////////////////////////////////////
class T_reg_four_21 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_four_21)
  rand uvm_reg_field reg_four_fld;
  
  covergroup wr_fld_covg;
    reg_four_fld: coverpoint reg_four_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_four_fld: coverpoint reg_four_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_four_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_four_21");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_one
/////////////////////////////////////////////////////
class T_reg_one_18 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_one_18)
  rand uvm_reg_field reg_one_fld;
  
  covergroup wr_fld_covg;
    reg_one_fld: coverpoint reg_one_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_one_fld: coverpoint reg_one_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_one_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_one_18");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_seven
/////////////////////////////////////////////////////
class T_reg_seven_24 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_seven_24)
  rand uvm_reg_field reg_seven_fld;
  
  covergroup wr_fld_covg;
    reg_seven_fld: coverpoint reg_seven_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_seven_fld: coverpoint reg_seven_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_seven_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_seven_24");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_six
/////////////////////////////////////////////////////
class T_reg_six_23 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_six_23)
  rand uvm_reg_field reg_six_fld;
  
  covergroup wr_fld_covg;
    reg_six_fld: coverpoint reg_six_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_six_fld: coverpoint reg_six_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_six_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_six_23");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_three
/////////////////////////////////////////////////////
class T_reg_three_20 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_three_20)
  rand uvm_reg_field reg_three_fld;
  
  covergroup wr_fld_covg;
    reg_three_fld: coverpoint reg_three_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_three_fld: coverpoint reg_three_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_three_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_three_20");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_two
/////////////////////////////////////////////////////
class T_reg_two_19 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_two_19)
  rand uvm_reg_field reg_two_fld;
  
  covergroup wr_fld_covg;
    reg_two_fld: coverpoint reg_two_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    reg_two_fld: coverpoint reg_two_fld.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    reg_two_fld = fld_set[0];
  endfunction

  function new(input string name="T_reg_two_19");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                reg_zero
/////////////////////////////////////////////////////
class T_reg_zero_17 extends cdns_uvm_reg;

  `uvm_object_utils(T_reg_zero_17)
  rand uvm_reg_field field0;
  rand uvm_reg_field field1;
  rand uvm_reg_field field2;
  rand uvm_reg_field field3;
  rand uvm_reg_field field4;
  rand uvm_reg_field field5;
  rand uvm_reg_field field6;
  rand uvm_reg_field field7;
  
  covergroup wr_fld_covg;
    field0: coverpoint field0.value[0:0];
    field1: coverpoint field1.value[0:0];
    field2: coverpoint field2.value[0:0];
    field3: coverpoint field3.value[0:0];
    field4: coverpoint field4.value[0:0];
    field5: coverpoint field5.value[0:0];
    field6: coverpoint field6.value[0:0];
    field7: coverpoint field7.value[0:0];
  endgroup
  covergroup rd_fld_covg;
    field0: coverpoint field0.value[0:0];
    field1: coverpoint field1.value[0:0];
    field2: coverpoint field2.value[0:0];
    field3: coverpoint field3.value[0:0];
    field4: coverpoint field4.value[0:0];
    field5: coverpoint field5.value[0:0];
    field6: coverpoint field6.value[0:0];
    field7: coverpoint field7.value[0:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    field0 = fld_set[0];
    field1 = fld_set[1];
    field2 = fld_set[2];
    field3 = fld_set[3];
    field4 = fld_set[4];
    field5 = fld_set[5];
    field6 = fld_set[6];
    field7 = fld_set[7];
  endfunction

  function new(input string name="T_reg_zero_17");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                custom_registers
/////////////////////////////////////////////////////
class T_registers_25 extends cdns_uvm_reg_block;

  `uvm_object_utils(T_registers_25)
  rand T_reg_five_22 reg_five;
  rand T_reg_four_21 reg_four;
  rand T_reg_one_18 reg_one;
  rand T_reg_seven_24 reg_seven;
  rand T_reg_six_23 reg_six;
  rand T_reg_three_20 reg_three;
  rand T_reg_two_19 reg_two;
  rand T_reg_zero_17 reg_zero;



  virtual function void build();
    uvm_reg  reg_set[$];
    string config_path = get_hier_path();
    default_map = create_map(get_name(), `UVM_REG_ADDR_WIDTH'h0, 1, UVM_LITTLE_ENDIAN, 1);
    begin
       uvm_reg_config_ta ta = get_reg_config({"custom_regs", config_path});
       build_uvm_regs(default_map, this, null, ta, reg_set);
    end
    if(! $cast(reg_five, reg_set[0]))
      `uvm_error("UVM_REG", "reg_five register casting error")
    if(! $cast(reg_four, reg_set[1]))
      `uvm_error("UVM_REG", "reg_four register casting error")
    if(! $cast(reg_one, reg_set[2]))
      `uvm_error("UVM_REG", "reg_one register casting error")
    if(! $cast(reg_seven, reg_set[3]))
      `uvm_error("UVM_REG", "reg_seven register casting error")
    if(! $cast(reg_six, reg_set[4]))
      `uvm_error("UVM_REG", "reg_six register casting error")
    if(! $cast(reg_three, reg_set[5]))
      `uvm_error("UVM_REG", "reg_three register casting error")
    if(! $cast(reg_two, reg_set[6]))
      `uvm_error("UVM_REG", "reg_two register casting error")
    if(! $cast(reg_zero, reg_set[7]))
      `uvm_error("UVM_REG", "reg_zero register casting error")

  endfunction

  function new(input string name="custom_registers");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass


/////////////////////////////////////////////////////
//                custom_regs
/////////////////////////////////////////////////////
class custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0 extends cdns_uvm_reg_block;

  `uvm_object_utils(custom_regs_vendor_Cadence_Design_Systems_library_flat_version_2_0)

  uvm_reg_map default_map;
  uvm_reg_map custom;
  rand T_registers_25 custom_registers;

  virtual function void build();
    custom = create_map("custom", `UVM_REG_ADDR_WIDTH'h0, 1, UVM_LITTLE_ENDIAN, 1);
    default_map = custom;
    custom_registers = T_registers_25::type_id::create("custom_registers", , get_full_name());
    custom_registers.configure(this);
    custom_registers.build();

    //Mapping custom map
    custom_registers.default_map.add_parent_map(custom,`UVM_REG_ADDR_WIDTH'h0);
    custom.set_submap_offset(custom_registers.default_map, `UVM_REG_ADDR_WIDTH'h0);
    //Apply hdl_paths
    apply_hdl_paths(this);

  endfunction



  function new(input string name="custom_regs");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass


//*************************************************//
//Factory Methods
//*************************************************//
class reg_verifier_factory extends cdns_factory_base;
   virtual function uvm_object create(string typename, string pathname,string objectname);
      case(typename)
         "T_reg_five_22": begin T_reg_five_22 reg_five = new(objectname); create = reg_five;  end
         "T_reg_four_21": begin T_reg_four_21 reg_four = new(objectname); create = reg_four;  end
         "T_reg_one_18": begin T_reg_one_18 reg_one = new(objectname); create = reg_one;  end
         "T_reg_seven_24": begin T_reg_seven_24 reg_seven = new(objectname); create = reg_seven;  end
         "T_reg_six_23": begin T_reg_six_23 reg_six = new(objectname); create = reg_six;  end
         "T_reg_three_20": begin T_reg_three_20 reg_three = new(objectname); create = reg_three;  end
         "T_reg_two_19": begin T_reg_two_19 reg_two = new(objectname); create = reg_two;  end
         "T_reg_zero_17": begin T_reg_zero_17 reg_zero = new(objectname); create = reg_zero;  end

      endcase
   endfunction
endclass


//get_factory() function to select the factory
function automatic cdns_factory_base get_factory(bit no_factory);
   static cdns_factory_base factory;
   if(factory == null) begin
      if(no_factory == 1) begin
         reg_verifier_factory rv_factory = new;
         factory = rv_factory;
      end
      else begin
         uvm_factory_proxy rv_factory = new;
         factory = rv_factory;
      end
   end
   cdns_uvmreg_utils_pkg::factory=factory;


   return factory;
endfunction
cdns_factory_base factory = get_factory(no_factory);

endpackage



