unset surface
set contour
# set cntrparam ...
set table 'plotdata/pgfplotscontourinput.table'
splot [x=0:1] [y=0:1] x*y;
unset table
