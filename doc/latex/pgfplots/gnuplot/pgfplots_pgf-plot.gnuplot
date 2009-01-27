set terminal table; set output "gnuplot/pgfplots_pgf-plot.table"; set format "%.5f"
set format "%.7e";; set samples 300; plot [x=0:2*pi] sin(x)*sin(2*x);
