//*************************************************************//
//   ** File Generated Automatically
//   ** Please donot edit manually
//*************************************************************//


package yapp_router_reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import cdns_uvmreg_utils_pkg::*;

  bit no_factory = 0; 

/////////////////////////////////////////////////////
//                addr0_cnt_reg
/////////////////////////////////////////////////////
class T_addr0_cnt_reg_23 extends cdns_uvm_reg;

  `uvm_object_utils(T_addr0_cnt_reg_23)
  rand uvm_reg_field addr0_cnt_fld;
  
  covergroup wr_fld_covg;
    addr0_cnt_fld: coverpoint addr0_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    addr0_cnt_fld: coverpoint addr0_cnt_fld.value[7:0];
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
    
    addr0_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_addr0_cnt_reg_23");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                addr1_cnt_reg
/////////////////////////////////////////////////////
class T_addr1_cnt_reg_24 extends cdns_uvm_reg;

  `uvm_object_utils(T_addr1_cnt_reg_24)
  rand uvm_reg_field addr1_cnt_fld;
  
  covergroup wr_fld_covg;
    addr1_cnt_fld: coverpoint addr1_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    addr1_cnt_fld: coverpoint addr1_cnt_fld.value[7:0];
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
    
    addr1_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_addr1_cnt_reg_24");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                addr2_cnt_reg
/////////////////////////////////////////////////////
class T_addr2_cnt_reg_25 extends cdns_uvm_reg;

  `uvm_object_utils(T_addr2_cnt_reg_25)
  rand uvm_reg_field addr2_cnt_fld;
  
  covergroup wr_fld_covg;
    addr2_cnt_fld: coverpoint addr2_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    addr2_cnt_fld: coverpoint addr2_cnt_fld.value[7:0];
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
    
    addr2_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_addr2_cnt_reg_25");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                addr3_cnt_reg
/////////////////////////////////////////////////////
class T_addr3_cnt_reg_22 extends cdns_uvm_reg;

  `uvm_object_utils(T_addr3_cnt_reg_22)
  rand uvm_reg_field addr3_cnt_fld;
  
  covergroup wr_fld_covg;
    addr3_cnt_fld: coverpoint addr3_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    addr3_cnt_fld: coverpoint addr3_cnt_fld.value[7:0];
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
    
    addr3_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_addr3_cnt_reg_22");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                ctrl_reg
/////////////////////////////////////////////////////
class T_ctrl_reg_18 extends cdns_uvm_reg;

  `uvm_object_utils(T_ctrl_reg_18)
  rand uvm_reg_field max_pkt_size;
  
  covergroup wr_fld_covg;
    max_pkt_size: coverpoint max_pkt_size.value[5:0];
  endgroup
  covergroup rd_fld_covg;
    max_pkt_size: coverpoint max_pkt_size.value[5:0];
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
    
    max_pkt_size = fld_set[0];
  endfunction

  function new(input string name="T_ctrl_reg_18");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                en_reg
/////////////////////////////////////////////////////
class T_en_reg_19 extends cdns_uvm_reg;

  `uvm_object_utils(T_en_reg_19)
  rand uvm_reg_field router_en;
  rand uvm_reg_field parity_err_cnt_en;
  rand uvm_reg_field oversized_pkt_cnt_en;
  rand uvm_reg_field addr0_cnt_en;
  rand uvm_reg_field addr1_cnt_en;
  rand uvm_reg_field addr2_cnt_en;
  rand uvm_reg_field addr3_cnt_en;
  
  covergroup wr_fld_covg;
    router_en: coverpoint router_en.value[0:0];
    parity_err_cnt_en: coverpoint parity_err_cnt_en.value[0:0];
    oversized_pkt_cnt_en: coverpoint oversized_pkt_cnt_en.value[0:0];
    addr0_cnt_en: coverpoint addr0_cnt_en.value[0:0];
    addr1_cnt_en: coverpoint addr1_cnt_en.value[0:0];
    addr2_cnt_en: coverpoint addr2_cnt_en.value[0:0];
    addr3_cnt_en: coverpoint addr3_cnt_en.value[0:0];
  endgroup
  covergroup rd_fld_covg;
    router_en: coverpoint router_en.value[0:0];
    parity_err_cnt_en: coverpoint parity_err_cnt_en.value[0:0];
    oversized_pkt_cnt_en: coverpoint oversized_pkt_cnt_en.value[0:0];
    addr0_cnt_en: coverpoint addr0_cnt_en.value[0:0];
    addr1_cnt_en: coverpoint addr1_cnt_en.value[0:0];
    addr2_cnt_en: coverpoint addr2_cnt_en.value[0:0];
    addr3_cnt_en: coverpoint addr3_cnt_en.value[0:0];
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
    
    router_en = fld_set[0];
    parity_err_cnt_en = fld_set[1];
    oversized_pkt_cnt_en = fld_set[2];
    addr0_cnt_en = fld_set[3];
    addr1_cnt_en = fld_set[4];
    addr2_cnt_en = fld_set[5];
    addr3_cnt_en = fld_set[6];
  endfunction

  function new(input string name="T_en_reg_19");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                mem_size_reg
/////////////////////////////////////////////////////
class T_mem_size_reg_26 extends cdns_uvm_reg;

  `uvm_object_utils(T_mem_size_reg_26)
  rand uvm_reg_field mem_size_fld;
  
  covergroup wr_fld_covg;
    mem_size_fld: coverpoint mem_size_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    mem_size_fld: coverpoint mem_size_fld.value[7:0];
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
    
    mem_size_fld = fld_set[0];
  endfunction

  function new(input string name="T_mem_size_reg_26");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                oversized_pkt_cnt_reg
/////////////////////////////////////////////////////
class T_oversized_pkt_cnt_reg_21 extends cdns_uvm_reg;

  `uvm_object_utils(T_oversized_pkt_cnt_reg_21)
  rand uvm_reg_field oversized_pkt_cnt_fld;
  
  covergroup wr_fld_covg;
    oversized_pkt_cnt_fld: coverpoint oversized_pkt_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    oversized_pkt_cnt_fld: coverpoint oversized_pkt_cnt_fld.value[7:0];
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
    
    oversized_pkt_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_oversized_pkt_cnt_reg_21");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                parity_err_cnt_reg
/////////////////////////////////////////////////////
class T_parity_err_cnt_reg_20 extends cdns_uvm_reg;

  `uvm_object_utils(T_parity_err_cnt_reg_20)
  rand uvm_reg_field parity_err_cnt_fld;
  
  covergroup wr_fld_covg;
    parity_err_cnt_fld: coverpoint parity_err_cnt_fld.value[7:0];
  endgroup
  covergroup rd_fld_covg;
    parity_err_cnt_fld: coverpoint parity_err_cnt_fld.value[7:0];
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
    
    parity_err_cnt_fld = fld_set[0];
  endfunction

  function new(input string name="T_parity_err_cnt_reg_20");
    super.new(name, 8, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


//////////////////////////////////////////////////////
//              router_yapp_mem 
//////////////////////////////////////////////////////
class T_yapp_mem_27 extends uvm_mem;

  `uvm_object_utils(T_yapp_mem_27) 

  function new(input string name="router_yapp_mem");
    super.new(name, 'h100, 8, "RW", UVM_NO_COVERAGE);
  endfunction

endclass



//////////////////////////////////////////////////////
//              router_yapp_pkt_mem 
//////////////////////////////////////////////////////
class T_yapp_pkt_mem_28 extends uvm_mem;

  `uvm_object_utils(T_yapp_pkt_mem_28) 

  function new(input string name="router_yapp_pkt_mem");
    super.new(name, 'h40, 8, "RO", UVM_NO_COVERAGE);
  endfunction

endclass



/////////////////////////////////////////////////////
//                router_yapp_regs
/////////////////////////////////////////////////////
class yapp_regs_block extends cdns_uvm_reg_block;

  `uvm_object_utils(yapp_regs_block)
  rand T_addr0_cnt_reg_23 addr0_cnt_reg;
  rand T_addr1_cnt_reg_24 addr1_cnt_reg;
  rand T_addr2_cnt_reg_25 addr2_cnt_reg;
  rand T_addr3_cnt_reg_22 addr3_cnt_reg;
  rand T_ctrl_reg_18 ctrl_reg;
  rand T_en_reg_19 en_reg;
  rand T_mem_size_reg_26 mem_size_reg;
  rand T_oversized_pkt_cnt_reg_21 oversized_pkt_cnt_reg;
  rand T_parity_err_cnt_reg_20 parity_err_cnt_reg;



  virtual function void build();
    uvm_reg  reg_set[$];
    string config_path = get_hier_path();
    default_map = create_map(get_name(), `UVM_REG_ADDR_WIDTH'h1000, 1, UVM_LITTLE_ENDIAN, 1);
    begin
       uvm_reg_config_ta ta = get_reg_config({"yapp_registers", config_path});
       build_uvm_regs(default_map, this, null, ta, reg_set);
    end
    if(! $cast(addr0_cnt_reg, reg_set[0]))
      `uvm_error("UVM_REG", "addr0_cnt_reg register casting error")
    if(! $cast(addr1_cnt_reg, reg_set[1]))
      `uvm_error("UVM_REG", "addr1_cnt_reg register casting error")
    if(! $cast(addr2_cnt_reg, reg_set[2]))
      `uvm_error("UVM_REG", "addr2_cnt_reg register casting error")
    if(! $cast(addr3_cnt_reg, reg_set[3]))
      `uvm_error("UVM_REG", "addr3_cnt_reg register casting error")
    if(! $cast(ctrl_reg, reg_set[4]))
      `uvm_error("UVM_REG", "ctrl_reg register casting error")
    if(! $cast(en_reg, reg_set[5]))
      `uvm_error("UVM_REG", "en_reg register casting error")
    if(! $cast(mem_size_reg, reg_set[6]))
      `uvm_error("UVM_REG", "mem_size_reg register casting error")
    if(! $cast(oversized_pkt_cnt_reg, reg_set[7]))
      `uvm_error("UVM_REG", "oversized_pkt_cnt_reg register casting error")
    if(! $cast(parity_err_cnt_reg, reg_set[8]))
      `uvm_error("UVM_REG", "parity_err_cnt_reg register casting error")

  endfunction

  function new(input string name="router_yapp_regs");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass


/////////////////////////////////////////////////////
//                yapp_registers
/////////////////////////////////////////////////////
class yapp_registers_vendor_cadence_com_library_flat_version_2_0 extends cdns_uvm_reg_block;

  `uvm_object_utils(yapp_registers_vendor_cadence_com_library_flat_version_2_0)

  uvm_reg_map default_map;
  uvm_reg_map router;
  rand T_yapp_mem_27 router_yapp_mem;
  rand T_yapp_pkt_mem_28 router_yapp_pkt_mem;
  rand yapp_regs_block router_yapp_regs;

  virtual function void build();
    router = create_map("router", `UVM_REG_ADDR_WIDTH'h0, 1, UVM_LITTLE_ENDIAN, 1);
    default_map = router;
    router_yapp_mem = T_yapp_mem_27::type_id::create("router_yapp_mem");
    router_yapp_mem.configure(this, "router_yapp_mem");
    router_yapp_pkt_mem = T_yapp_pkt_mem_28::type_id::create("router_yapp_pkt_mem");
    router_yapp_pkt_mem.configure(this, "router_yapp_pkt_mem");
    router_yapp_regs = yapp_regs_block::type_id::create("router_yapp_regs", , get_full_name());
    router_yapp_regs.configure(this);
    router_yapp_regs.build();

    //Mapping router map
    router.add_mem(router_yapp_mem, `UVM_REG_ADDR_WIDTH'h1100);
    router.add_mem(router_yapp_pkt_mem, `UVM_REG_ADDR_WIDTH'h1010);
    router_yapp_regs.default_map.add_parent_map(router,`UVM_REG_ADDR_WIDTH'h1000);
    router.set_submap_offset(router_yapp_regs.default_map, `UVM_REG_ADDR_WIDTH'h1000);
    //Apply hdl_paths
    apply_hdl_paths(this);

  endfunction



  function new(input string name="yapp_registers");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass

//This typedef is defined for user-defined top level class name
typedef yapp_registers_vendor_cadence_com_library_flat_version_2_0 yapp_router_regs_t;


//*************************************************//
//Factory Methods
//*************************************************//
class reg_verifier_factory extends cdns_factory_base;
   virtual function uvm_object create(string typename, string pathname,string objectname);
      case(typename)
         "T_addr0_cnt_reg_23": begin T_addr0_cnt_reg_23 addr0_cnt_reg = new(objectname); create = addr0_cnt_reg;  end
         "T_addr1_cnt_reg_24": begin T_addr1_cnt_reg_24 addr1_cnt_reg = new(objectname); create = addr1_cnt_reg;  end
         "T_addr2_cnt_reg_25": begin T_addr2_cnt_reg_25 addr2_cnt_reg = new(objectname); create = addr2_cnt_reg;  end
         "T_addr3_cnt_reg_22": begin T_addr3_cnt_reg_22 addr3_cnt_reg = new(objectname); create = addr3_cnt_reg;  end
         "T_ctrl_reg_18": begin T_ctrl_reg_18 ctrl_reg = new(objectname); create = ctrl_reg;  end
         "T_en_reg_19": begin T_en_reg_19 en_reg = new(objectname); create = en_reg;  end
         "T_mem_size_reg_26": begin T_mem_size_reg_26 mem_size_reg = new(objectname); create = mem_size_reg;  end
         "T_oversized_pkt_cnt_reg_21": begin T_oversized_pkt_cnt_reg_21 oversized_pkt_cnt_reg = new(objectname); create = oversized_pkt_cnt_reg;  end
         "T_parity_err_cnt_reg_20": begin T_parity_err_cnt_reg_20 parity_err_cnt_reg = new(objectname); create = parity_err_cnt_reg;  end

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



