unset surface
set contour
# set cntrparam ...
set table 'plotdata/pgfplotscontourinput3.table'
splot [x=-2:7] [y=-2:7] exp(-x**2-y**2) + exp(-(x-3)**2/4 - (y-3)**2/4);
unset table
