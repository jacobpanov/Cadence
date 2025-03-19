module rcvr
#(
  parameter [7:0] MATCH = 8'hA5
 )
 (
  input  wire      clock   ,
  input  wire      reset   ,
  input  wire      data_in ,
  input  wire      reading ,
  output reg       ready   ,
  output reg       overrun ,
  output reg [7:0] data_out
 );

  localparam SHIFT_HEAD = 0 ,
             SHIFT_BODY = 1 ;

  reg [6:0] head_reg ;
  reg [6:0] body_reg ;
  reg [2:0] count ;
  reg phase ;

  always @(posedge clock)

    if (reset) begin

        // INITIALIZE PHASE TO SHIFTING HEADER
        // INITIALIZE HEADER TO OPPOSITE OF LEFTMOST MATCH BIT
        // INITIALIZE CONTROL REGISTERS TO INACTIVE STATE (IGNORE DATA PATH)






      end

    else begin

        // IF PHASE IS SHIFT_BODY THEN CLEAR HEAD REGISTER, ELSE
        // IF PHASE IS SHIFT_HEAD THEN SHIFT INPUT DATA LEFT INTO HEAD REGISTER





        // IF CONCATENATION OF HEAD REG AND INPUT DATA IS MATCH CHARACTER THEN
        // SET PHASE TO SHIFT_BODY, ELSE
        // IF COUNT IS 7 THEN SET PHASE BACK TO SHIFT_HEAD





        // IF PHASE IS SHIFT_BODY THEN INCREMENT COUNT


        // IF PHASE IS SHIFT_BODY THEN SHIFT INPUT DATA LEFT INTO BODY REGISTER


        // IF COUNT IS 7 THEN COPY CONCATENATION OF BODY REGISTER AND INPUT DATA
        // TO OUTPUT DATA


        // IF COUNT IS 7 THEN SET READY ELSE IF READING THEN CLEAR READY


        // IF READING THEN CLEAR OVERRUN, ELSE
        // IF COUNT IS 7 AND STILL READY THEN SET OVERRUN


      end

endmodule
