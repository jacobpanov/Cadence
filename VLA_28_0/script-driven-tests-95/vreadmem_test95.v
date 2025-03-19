
module fileread95;
 reg [15:0] cmdarr [0:6];
 reg [15:0] cmd;
 integer i;

 parameter SEND = 4'h0, ADDR = 4'h1, NEXT = 4'h2;
  initial
  begin

  /* 1. write a procedure using the system task $readmemh to get the commands from data.txt into the cmdarray "cmdarr" 
defined above. 
2. Create a loop where in 8 commands are read, corresponding to each bit of the cmdarray and then when
 encountered the 16'bx or Fh there is a display "end of commands" and then stop reading using $STOP.
3. In the next part of the loop check for the the SEND, ADDR, NEXT commands and sue the respective tasks created below.
4. And have the default display as "unknown command" for any other command encountered.
5. Following tasks have been created for helping the creation of the second part of the loop in this procedure.*/

   end

  task do_addr(input [7:0] addr);
    begin
    $display("do_addr with addr = %h",addr);
    end
  endtask

  task do_send(input [7:0] addr, input [3:0] dat);
    begin
    $display("do_send with addr = %h, data = %h",addr,dat);
    end
  endtask

  task do_next(input [7:0] addr);
    begin
    $display("do_next with addr = %h",addr);
    end
  endtask

endmodule

