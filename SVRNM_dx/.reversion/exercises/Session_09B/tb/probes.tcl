database -open -shm -into waves.shm waves -default
# Use following line to save all signals
probe -create -database waves -all -depth all -flow
# run 20ms
