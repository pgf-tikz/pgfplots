set terminal table; set output "gnuplot/pgfplots_pgf-plot.table"; set format "%.5f"
set format "%.7e";; set samples 25; set logscale xy 2.71828182845905; plot [x=1:10000] x**-2;
