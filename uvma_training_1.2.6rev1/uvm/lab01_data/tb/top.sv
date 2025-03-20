/*-----------------------------------------------------------------
File name     : top.sv
Description   : lab01_data top module template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

module top;
// import the UVM library
    import uvm_pkg::*;
// include the UVM macros
    `include "uvm_macros.svh"

// import the YAPP package
    import yapp_pkg::*;

    yapp_packet packet;
    yapp_packet copy_packet;

// generate 5 random packets and use the print method
    uvm_table_printer custom = new();
    int ok;

    initial begin
// construct the packet for copy
    copy_packet = new("copy_packet");

    for (int i=0; i<5; i++) begin
        // allocate each packet
        packet = new($sformatf("packet%0d",i));
        ok = packet.randomize();
        packet.print();
    end
// to display the results
$display ("\n\nCOPY");
copy_packet.copy(packet);
copy_packet.print();

// experiment with the copy, clone and compare UVM method
end
endmodule : top
