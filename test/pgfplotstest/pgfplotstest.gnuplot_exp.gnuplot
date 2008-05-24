set terminal table; set output "pgfplotstest.gnuplot_exp.table"; set format "%.5f"
set format "\%.7e"; set samples 50; plot [x=-5:15] exp(x)
