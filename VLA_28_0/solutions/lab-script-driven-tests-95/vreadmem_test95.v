
module fileread95;
 reg [15:0] cmdarr [0:6];
 reg [15:0] cmd;
 integer i;

 parameter SEND = 4'h0, ADDR = 4'h1, NEXT = 4'h2;
  initial
  begin

  $readmemh("data.txt", cmdarr);
   for (i=0;i<7;i=i+1) begin
     cmd = cmdarr[i];
     if (cmd === 16'bx) begin
       $display("end of commands");
       $finish;
     end
     else
       case (cmd[15:12])
         SEND:do_send(cmd[11:4],cmd[3:0]);
         ADDR:do_addr(cmd[11:4]);
         NEXT:do_next(cmd[11:4]);
         default:$display("unknown command %h",cmd);
       endcase
     end
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

