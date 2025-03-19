
//input ports
add mapped point clock clock -type PI PI
add mapped point select[1] select[1] -type PI PI
add mapped point select[0] select[0] -type PI PI
add mapped point in1 in1 -type PI PI
add mapped point in2 in2 -type PI PI
add mapped point in3 in3 -type PI PI

//output ports
add mapped point mux_out mux_out -type PO PO

//inout ports




//Sequential Pins
add mapped point mux_out/q mux_out_reg/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
