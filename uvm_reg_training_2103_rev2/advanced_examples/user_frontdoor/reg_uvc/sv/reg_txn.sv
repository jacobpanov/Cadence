/*-----------------------------------------------------------------
File name     : reg_txn.sv
Developers    : Kathleen Meade, Brian Dickinson
Created       : 
Description   : 
              : 
Notes         :
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

typedef enum bit {REG_RD, REG_WR} reg_wr_t;
typedef enum {any, ascii, uc, lc, uclc} control_t;

class reg_txn extends uvm_sequence_item;     

  rand bit [7:0] data;
  rand bit [4:0] addr;

  rand reg_wr_t reg_wr;
  control_t cntrl;

  constraint datadist { cntrl == ascii -> data inside {[8'h20:8'h7F]};
                        cntrl == uc    -> data inside {[8'h41:8'h5A]};
                        cntrl == lc    -> data inside {[8'h61:8'h7A]};
                        cntrl == uclc  -> data dist {[8'h41:8'h5a]:=4, [8'h61:8'h7a]:=1};}

  `uvm_object_utils_begin(reg_txn)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_enum(reg_wr_t, reg_wr, UVM_ALL_ON)
    `uvm_field_enum(control_t, cntrl, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor - required syntax for UVM automation and utilities
  function new (string name = "reg_txn");
    super.new(name);
  endfunction : new

endclass : reg_txn

