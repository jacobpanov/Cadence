// This file is generated using Cadence iregGen version 14.10.s003 

`ifndef REG_RM_PKG_SV
`define REG_RM_PKG_SV

// Input File: ./reg_rm.xml

// Number of AddrMaps = 1
// Number of RegFiles = 1
// Number of Registers = 8
// Number of Memories = 0

package reg_rm_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 24


class reg_zero_c extends uvm_reg;

  rand uvm_reg_field field0;
  rand uvm_reg_field field1;
  rand uvm_reg_field field2;
  rand uvm_reg_field field3;
  rand uvm_reg_field field4;
  rand uvm_reg_field field5;
  rand uvm_reg_field field6;
  rand uvm_reg_field field7;

  virtual function void build();
    field0 = uvm_reg_field::type_id::create("field0");
    field0.configure(this, 1, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    field1 = uvm_reg_field::type_id::create("field1");
    field1.configure(this, 1, 1, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>1, 1, 1, 1);
    field2 = uvm_reg_field::type_id::create("field2");
    field2.configure(this, 1, 2, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>2, 1, 1, 1);
    field3 = uvm_reg_field::type_id::create("field3");
    field3.configure(this, 1, 3, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>3, 1, 1, 1);
    field4 = uvm_reg_field::type_id::create("field4");
    field4.configure(this, 1, 4, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>4, 1, 1, 1);
    field5 = uvm_reg_field::type_id::create("field5");
    field5.configure(this, 1, 5, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>5, 1, 1, 1);
    field6 = uvm_reg_field::type_id::create("field6");
    field6.configure(this, 1, 6, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>6, 1, 1, 1);
    field7 = uvm_reg_field::type_id::create("field7");
    field7.configure(this, 1, 7, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>7, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    field0 : coverpoint field0.value[0:0];
    field1 : coverpoint field1.value[0:0];
    field2 : coverpoint field2.value[0:0];
    field3 : coverpoint field3.value[0:0];
    field4 : coverpoint field4.value[0:0];
    field5 : coverpoint field5.value[0:0];
    field6 : coverpoint field6.value[0:0];
    field7 : coverpoint field7.value[0:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    field0 : coverpoint field0.value[0:0];
    field1 : coverpoint field1.value[0:0];
    field2 : coverpoint field2.value[0:0];
    field3 : coverpoint field3.value[0:0];
    field4 : coverpoint field4.value[0:0];
    field5 : coverpoint field5.value[0:0];
    field6 : coverpoint field6.value[0:0];
    field7 : coverpoint field7.value[0:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_zero_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_zero_c, uvm_reg)
  `uvm_object_utils(reg_zero_c)
  function new(input string name="unnamed-reg_zero_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_zero_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 84


class reg_one_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_one_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_one_c, uvm_reg)
  `uvm_object_utils(reg_one_c)
  function new(input string name="unnamed-reg_one_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_one_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 103


class reg_two_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_two_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_two_c, uvm_reg)
  `uvm_object_utils(reg_two_c)
  function new(input string name="unnamed-reg_two_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_two_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 122


class reg_three_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_three_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_three_c, uvm_reg)
  `uvm_object_utils(reg_three_c)
  function new(input string name="unnamed-reg_three_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_three_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 141


class reg_four_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_four_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_four_c, uvm_reg)
  `uvm_object_utils(reg_four_c)
  function new(input string name="unnamed-reg_four_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_four_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 160


class reg_five_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_five_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_five_c, uvm_reg)
  `uvm_object_utils(reg_five_c)
  function new(input string name="unnamed-reg_five_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_five_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 179


class reg_six_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_six_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_six_c, uvm_reg)
  `uvm_object_utils(reg_six_c)
  function new(input string name="unnamed-reg_six_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_six_c

//////////////////////////////////////////////////////////////////////////////
// Register definition
//////////////////////////////////////////////////////////////////////////////
// Line Number: 198


class reg_seven_c extends uvm_reg;

  rand uvm_reg_field data;

  virtual function void build();
    data = uvm_reg_field::type_id::create("data");
    data.configure(this, 8, 0, "RW", 0, `UVM_REG_DATA_WIDTH'h00>>0, 1, 1, 1);
    wr_cg.set_inst_name($sformatf("%s.wcov", get_full_name()));
    rd_cg.set_inst_name($sformatf("%s.rcov", get_full_name()));
  endfunction

  covergroup wr_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup
  covergroup rd_cg;
    option.per_instance=1;
    data : coverpoint data.value[7:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t  data, byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if(!is_read) wr_cg.sample();
    if(is_read) rd_cg.sample();
  endfunction

  `uvm_register_cb(reg_seven_c, uvm_reg_cbs) 
  `uvm_set_super_type(reg_seven_c, uvm_reg)
  `uvm_object_utils(reg_seven_c)
  function new(input string name="unnamed-reg_seven_c");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    wr_cg=new;
    rd_cg=new;
  endfunction : new
endclass : reg_seven_c

class registers_c extends uvm_reg_block;

  rand reg_zero_c reg_zero;
  rand reg_one_c reg_one;
  rand reg_two_c reg_two;
  rand reg_three_c reg_three;
  rand reg_four_c reg_four;
  rand reg_five_c reg_five;
  rand reg_six_c reg_six;
  rand reg_seven_c reg_seven;

  virtual function void build();

    // Now create all registers

    reg_zero = reg_zero_c::type_id::create("reg_zero", , get_full_name());
    reg_one = reg_one_c::type_id::create("reg_one", , get_full_name());
    reg_two = reg_two_c::type_id::create("reg_two", , get_full_name());
    reg_three = reg_three_c::type_id::create("reg_three", , get_full_name());
    reg_four = reg_four_c::type_id::create("reg_four", , get_full_name());
    reg_five = reg_five_c::type_id::create("reg_five", , get_full_name());
    reg_six = reg_six_c::type_id::create("reg_six", , get_full_name());
    reg_seven = reg_seven_c::type_id::create("reg_seven", , get_full_name());

    // Now build the registers. Set parent and hdl_paths

    reg_zero.configure(this, null, "reg_zero");
    reg_zero.build();
    reg_one.configure(this, null, "reg_one");
    reg_one.build();
    reg_two.configure(this, null, "reg_two");
    reg_two.build();
    reg_three.configure(this, null, "reg_three");
    reg_three.build();
    reg_four.configure(this, null, "reg_four");
    reg_four.build();
    reg_five.configure(this, null, "reg_five");
    reg_five.build();
    reg_six.configure(this, null, "reg_six");
    reg_six.build();
    reg_seven.configure(this, null, "reg_seven");
    reg_seven.build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
    default_map.add_reg(reg_zero, `UVM_REG_ADDR_WIDTH'h0, "RW");
    default_map.add_reg(reg_one, `UVM_REG_ADDR_WIDTH'h1, "RW");
    default_map.add_reg(reg_two, `UVM_REG_ADDR_WIDTH'h2, "RW");
    default_map.add_reg(reg_three, `UVM_REG_ADDR_WIDTH'h3, "RW");
    default_map.add_reg(reg_four, `UVM_REG_ADDR_WIDTH'h4, "RW");
    default_map.add_reg(reg_five, `UVM_REG_ADDR_WIDTH'h5, "RW");
    default_map.add_reg(reg_six, `UVM_REG_ADDR_WIDTH'h6, "RW");
    default_map.add_reg(reg_seven, `UVM_REG_ADDR_WIDTH'h7, "RW");
  endfunction

  `uvm_object_utils(registers_c)
  function new(input string name="unnamed-registers");
    super.new(name, UVM_NO_COVERAGE);
  endfunction : new

endclass : registers_c

//////////////////////////////////////////////////////////////////////////////
// Address_map definition
//////////////////////////////////////////////////////////////////////////////
class reg_model extends uvm_reg_block;

  rand registers_c registers;

  virtual function void build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 1, UVM_LITTLE_ENDIAN);
    registers = registers_c::type_id::create("registers", , get_full_name());
    registers.configure(this, "");
    registers.build();
    registers.lock_model();
    default_map.add_submap(registers.default_map, `UVM_REG_ADDR_WIDTH'h0);
    set_hdl_path_root("top.dut");
    this.lock_model();
    default_map.set_check_on_read();
  endfunction
  `uvm_object_utils(reg_model)
  function new(input string name="unnamed-reg_model");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass : reg_model
 
endpackage //reg_rm_pkg


`endif // REG_RM_PKG_SV
