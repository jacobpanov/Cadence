database -open -shm -into waves.shm waves -default -event
probe -create -database waves -all -memories -depth all
stop -create -condition {#integ_filt_tb.integ.Niter > 30}
