unset surface
set contour
set cntrparam levels 7
set table 'plotdata/pgfplotscontourinput2.table'
splot [x=-2:4] [y=-2:4] exp(-x**2-y**2) - exp(-(x-1)**2/4 - (y-1)**2/4);
unset table
