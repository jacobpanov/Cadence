database -open waves -into waves.shm -default
probe -create -shm -all -depth all
simvision -input ./simvision_slew_rate.svcf
