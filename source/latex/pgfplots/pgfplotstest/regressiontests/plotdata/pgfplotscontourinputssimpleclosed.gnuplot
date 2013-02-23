unset surface
set contour
# set cntrparam levels 7
set table 'plotdata/pgfplotscontourinputsimpleclosed.table'
set samples 20
splot [x=-2:2] [y=-2:2] exp(-x**2-y**2);
unset table
