
//input ports
add mapped point clock clock -type PI PI
add mapped point reset reset -type PI PI
add mapped point data_in data_in -type PI PI
add mapped point reading reading -type PI PI

//output ports
add mapped point ready ready -type PO PO
add mapped point overrun overrun -type PO PO
add mapped point data_out[7] data_out[7] -type PO PO
add mapped point data_out[6] data_out[6] -type PO PO
add mapped point data_out[5] data_out[5] -type PO PO
add mapped point data_out[4] data_out[4] -type PO PO
add mapped point data_out[3] data_out[3] -type PO PO
add mapped point data_out[2] data_out[2] -type PO PO
add mapped point data_out[1] data_out[1] -type PO PO
add mapped point data_out[0] data_out[0] -type PO PO

//inout ports




//Sequential Pins
add mapped point phase/q phase_reg/Q -type DFF DFF
add mapped point head_reg[6]/q head_reg_reg[6]/Q -type DFF DFF
add mapped point head_reg[5]/q head_reg_reg[5]/Q -type DFF DFF
add mapped point head_reg[4]/q head_reg_reg[4]/Q -type DFF DFF
add mapped point head_reg[3]/q head_reg_reg[3]/Q -type DFF DFF
add mapped point head_reg[2]/q head_reg_reg[2]/Q -type DFF DFF
add mapped point count[2]/q count_reg[2]/Q -type DFF DFF
add mapped point overrun/q overrun_reg/Q -type DFF DFF
add mapped point ready/q ready_reg/Q -type DFF DFF
add mapped point data_out[3]/q data_out_reg[3]/Q -type DFF DFF
add mapped point data_out[1]/q data_out_reg[1]/Q -type DFF DFF
add mapped point data_out[2]/q data_out_reg[2]/Q -type DFF DFF
add mapped point data_out[5]/q data_out_reg[5]/Q -type DFF DFF
add mapped point data_out[4]/q data_out_reg[4]/Q -type DFF DFF
add mapped point data_out[7]/q data_out_reg[7]/Q -type DFF DFF
add mapped point data_out[6]/q data_out_reg[6]/Q -type DFF DFF
add mapped point data_out[0]/q data_out_reg[0]/Q -type DFF DFF
add mapped point head_reg[1]/q head_reg_reg[1]/Q -type DFF DFF
add mapped point count[1]/q count_reg[1]/Q -type DFF DFF
add mapped point count[0]/q count_reg[0]/Q -type DFF DFF
add mapped point body_reg[6]/q body_reg_reg[6]/Q -type DFF DFF
add mapped point body_reg[0]/q body_reg_reg[0]/Q -type DFF DFF
add mapped point body_reg[2]/q body_reg_reg[2]/Q -type DFF DFF
add mapped point body_reg[3]/q body_reg_reg[3]/Q -type DFF DFF
add mapped point head_reg[0]/q head_reg_reg[0]/Q -type DFF DFF
add mapped point body_reg[1]/q body_reg_reg[1]/Q -type DFF DFF
add mapped point body_reg[5]/q body_reg_reg[5]/Q -type DFF DFF
add mapped point body_reg[4]/q body_reg_reg[4]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
