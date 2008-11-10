set terminal table; set output "gnuplot/pgfplots_gnuplot_expv.table"; set format "%.5f"
set format "%.7e";; set samples 15; plot [x=-5:10] exp(2*x);
