database -open waves -into waves.shm -default
probe -create tb -depth all -all -database waves
simvision -input ../solution/simvision.svcf
