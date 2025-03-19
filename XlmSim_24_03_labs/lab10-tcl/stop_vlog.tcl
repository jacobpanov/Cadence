scope -set risc_test.risc_inst
stop -create -name stop_1 -condition {#opcode==7 && #ir_addr=='h0a}
stop -create -name stop_2 -line 246 memory_inst -if {#addr=='h1c}
scope -set register_ac
stop -create -name stop_3 -condition {#clk==1 && #load==1}

stop -create -name stop_4 -time 50 ns -absolute


