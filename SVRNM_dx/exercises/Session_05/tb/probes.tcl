database -open waves -into waves.shm -default
probe -create vco_ds_TB -depth all -all -database waves
simvision -input ./simvision.svcf
