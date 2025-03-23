#!/bin/tcsh
gnuplot -persist -e "plot 'fft0.txt' with lines title 'Sinusoidal Input'"
gnuplot -persist -e "plot 'fft1.txt' with lines title 'Slew Filter'"

