Custom register access example using iregGen.

Specification:

Enable bits
  Field 1 of reg_zero is write-enable bit for reg_one
  e.g. if reg_zero[1] = 1'b0, reg_one is read-only.
Write set 5a
  register reg_three has a write-set-8'h5A access policy.
  i.e. when written to any value, register is set to 8'h5A
Aliased register
  reg_four and reg_five are aliased - writes to either address affect both

Instructions:

cd tb
irun -f run.f 


topology:

--------------------------------------------------------------
Name             Type           Size  Value
--------------------------------------------------------------
reg_block        reg_model      -     @3207
  registers      registers_c    -     @3220
    reg_zero     reg_zero_c     -     @3231
      field0     uvm_reg_field  ...    RW reg_zero[0:0]=1'h0
      field1     uvm_reg_field  ...    RW reg_zero[1:1]=1'h0
      field2     uvm_reg_field  ...    RW reg_zero[2:2]=1'h0
      field3     uvm_reg_field  ...    RW reg_zero[3:3]=1'h0
      field4     uvm_reg_field  ...    RW reg_zero[4:4]=1'h0
      field5     uvm_reg_field  ...    RW reg_zero[5:5]=1'h0
      field6     uvm_reg_field  ...    RW reg_zero[6:6]=1'h0
      field7     uvm_reg_field  ...    RW reg_zero[7:7]=1'h0
    reg_one      reg_one_c      -     @3255
      data       uvm_reg_field  ...    RW reg_one[7:0]=8'h00
    reg_two      reg_two_c      -     @3270
      data       uvm_reg_field  ...    RW reg_two[7:0]=8'h00
    reg_three    reg_three_c    -     @3283
      data       uvm_reg_field  ...    RW reg_three[7:0]=8'h00
    reg_four     reg_four_c     -     @3296
      data       uvm_reg_field  ...    RW reg_four[7:0]=8'h00
    reg_five     reg_five_c     -     @3309
      data       uvm_reg_field  ...    RW reg_five[7:0]=8'h00
    reg_six      reg_six_c      -     @3322
      data       uvm_reg_field  ...    RW reg_six[7:0]=8'h00
    reg_seven    reg_seven_c    -     @3335
      data       uvm_reg_field  ...    RW reg_seven[7:0]=8'h00
    default_map  uvm_reg_map    -     @3507
      endian                    ...   UVM_LITTLE_ENDIAN
      reg_zero   reg_zero_c     ...   @3231 +'h0
      reg_one    reg_one_c      ...   @3255 +'h1
      reg_two    reg_two_c      ...   @3270 +'h2
      reg_three  reg_three_c    ...   @3283 +'h3
      reg_four   reg_four_c     ...   @3296 +'h4
      reg_five   reg_five_c     ...   @3309 +'h5
      reg_six    reg_six_c      ...   @3322 +'h6
      reg_seven  reg_seven_c    ...   @3335 +'h7
  default_map    uvm_reg_map    -     @3206
    endian                      ...   UVM_LITTLE_ENDIAN
    default_map  uvm_reg_map    -     @3507
      endian                    ...   UVM_LITTLE_ENDIAN
      reg_zero   reg_zero_c     ...   @3231 +'h0
      reg_one    reg_one_c      ...   @3255 +'h1
      reg_two    reg_two_c      ...   @3270 +'h2
      reg_three  reg_three_c    ...   @3283 +'h3
      reg_four   reg_four_c     ...   @3296 +'h4
      reg_five   reg_five_c     ...   @3309 +'h5
      reg_six    reg_six_c      ...   @3322 +'h6
      reg_seven  reg_seven_c    ...   @3335 +'h7
--------------------------------------------------------------

