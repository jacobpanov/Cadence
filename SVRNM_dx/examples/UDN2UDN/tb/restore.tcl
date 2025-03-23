database -open -shm -into waves.shm waves -default
probe -create -shm -all -depth all
probe -create -shm -aicms -all -depth all

simvision -input restore.tcl.svcf
