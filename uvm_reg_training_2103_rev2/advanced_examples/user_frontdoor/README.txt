User-defined Frontdoor example using indirect register space

See slides for details of implementation.

Specification:
  Indirect registers
    reg_eight + reg_nine access through separate addr/data interface

  Indirect registers address location is 8'h10
  Indirect registers data location is 8'h11

  reg_eight address in indirect space is 8'h00
  reg_nine address in indirect space is 8'h01

  Therefore any access to reg_eight or reg_nine must be mapped to two transactions:
  1) Write reg_eight or reg_nine indirect address to 8'h10
  2) Read/write register data to 8'h11


Instructions:

cd tb
xrun -f run.f 


topology:

    reg_rm                    custom_regs_vendor_cadence_com_library_v1_version_1_5  -     @3018                   
      custom_registers        T_registers_29                                         -     @3078                   
        reg_eight             T_reg_eight_27                                         -     @3114                   
          reg_eight_fld       uvm_reg_field                                          ...    RW reg_eight[7:0]=8'h00
        reg_five              T_reg_five_24                                          -     @3124                   
          reg_five_fld        uvm_reg_field                                          ...    RW reg_five[7:0]=8'h00 
        reg_four              T_reg_four_23                                          -     @3140                   
          reg_four_fld        uvm_reg_field                                          ...    RW reg_four[7:0]=8'h00 
        reg_nine              T_reg_nine_28                                          -     @3155                   
          reg_nine_fld        uvm_reg_field                                          ...    RW reg_nine[7:0]=8'h00 
        reg_one               T_reg_one_20                                           -     @3170                   
          reg_one_fld         uvm_reg_field                                          ...    RW reg_one[7:0]=8'h00  
        reg_seven             T_reg_seven_26                                         -     @3185                   
          reg_seven_fld       uvm_reg_field                                          ...    RW reg_seven[7:0]=8'h00
        reg_six               T_reg_six_25                                           -     @3200                   
          reg_six_fld         uvm_reg_field                                          ...    RW reg_six[7:0]=8'h00  
        reg_three             T_reg_three_22                                         -     @3215                   
          reg_three_fld       uvm_reg_field                                          ...    RW reg_three[7:0]=8'h00
        reg_two               T_reg_two_21                                           -     @3230                   
          reg_two_fld         uvm_reg_field                                          ...    RW reg_two[7:0]=8'h00  
        reg_zero              T_reg_zero_19                                          -     @3245                   
          field0              uvm_reg_field                                          ...    RW reg_zero[0:0]=1'h0  
          field1              uvm_reg_field                                          ...    RW reg_zero[1:1]=1'h0  
          field2              uvm_reg_field                                          ...    RW reg_zero[2:2]=1'h0  
          field3              uvm_reg_field                                          ...    RW reg_zero[3:3]=1'h0  
          field4              uvm_reg_field                                          ...    RW reg_zero[4:4]=1'h0  
          field5              uvm_reg_field                                          ...    RW reg_zero[5:5]=1'h0  
          field6              uvm_reg_field                                          ...    RW reg_zero[6:6]=1'h0  
          field7              uvm_reg_field                                          ...    RW reg_zero[7:7]=1'h0  
    recording_detail          integral                                               32    'd1    

