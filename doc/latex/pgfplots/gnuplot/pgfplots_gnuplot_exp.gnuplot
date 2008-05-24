set terminal table; set output "gnuplot/pgfplots_gnuplot_exp.table"; set format "%.5f"
set format "\%.7e"; set samples 15; plot [x=-5:10] exp(x)
