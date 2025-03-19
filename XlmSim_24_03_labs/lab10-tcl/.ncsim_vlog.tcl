scope -show
scope -set cpu_i
scope -show
scope -describe mem_i -sort name
scope -list mem_i
probe -create -name probe_1 mem_i -shm
input stop_vlog.tcl
run 60 ns
stop -show
run
stop -disable stop_3
run
run 50 ns
stop -create -name stop_5 -time 80 ns -relative
run
run
stop -delete stop_5
run
exit
