database -open waves -into waves.shm -default
probe -create -shm -all -depth all
## simvision -input simvision.svcf
assert -on -all 
## assert -off -all
## set assert_stop_level never
