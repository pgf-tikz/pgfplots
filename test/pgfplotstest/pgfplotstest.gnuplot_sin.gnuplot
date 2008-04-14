set terminal table; set output "pgfplotstest.gnuplot_sin.table"; set format "%.5f"
set samples 50; plot [x=-5:5] sin(x)
