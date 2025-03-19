module fileread2001;
 reg [4*8-1:0] cmd;
 reg [1:0] addr;
 reg [3:0] data;

 integer fid, c1;
 integer i;

 initial
 begin

 fid = $fopen("cmd.txt","r");
   while(!$feof(fid)) begin
     c1 = $fscanf(fid,"%4c %2h",cmd,addr);
     case (cmd)
       "SEND":begin
              c1 = $fscanf(fid," %h",data);
              do_send(addr,data);
              end
       "ADDR":do_addr(addr);
       "NEXT":do_next(addr);
       default:$display("unknown command %s",cmd);
     endcase
     c1 = $fscanf(fid,"\n");
   end   // while
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

