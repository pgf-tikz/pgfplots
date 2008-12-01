set terminal table; set output "gnuplot/pgfplots_pgf-plot.table"; set format "%.5f"
set format "%.7e";; set samples 25; plot [x=0:10000] x**-2;
