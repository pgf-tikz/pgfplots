set isosamples 255,255
unset border
unset xtics
unset ytics
unset ztics
unset colorbox
set view 0, 0
set output "external1.png"
set terminal png size 1500,1300 crop
# set palette defined (-3 "blue", 0 "white", 1 "red")
# set palette rgbformulae 21,22,23
set palette defined (0 0 0 0.56, 1 0 0.125 1, 2 0.5 1 0.5, 3 1 0.5 0, 4 1 0 0, 5 0.5 0  0)
set pm3d map
splot [x=-3:3] [y=-3:3] exp( -(x-y)**2 -x**2 ) notitle
