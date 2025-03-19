module fileread2001;
 reg [4*8-1:0] cmd;
 reg [1:0] addr;
 reg [3:0] data;

 integer fid, c1;
 integer i;

 initial
 begin

/* write a procedure using the system task $fopen to get the commands from cmd.txt 
1. Have fid= fopen the cmd.txt
2. while it is not the end-of-file of fid, scanf the cmd, addr.
3. IN teh second part of the loop, for cmds, SEND, ADDR, NEXT use the below tasks created
4. if any other cmd is encountered have a default display "unknown command".
5. Following tasks have been created for helping the creation of the second part of the loop in this procedure.
*/


     end    // initial

  task do_addr(input [1:0] addr);
    begin
    $display("do_addr with addr = %b",addr);
    end
  endtask

  task do_send(input [1:0] addr, input [3:0] dat);
    begin
    $display("do_send with addr = %b, data = %h",addr,dat);
    end
  endtask

  task do_next(input [1:0] addr);
    begin
    $display("do_next with addr = %b",addr);
    end
  endtask

endmodule

