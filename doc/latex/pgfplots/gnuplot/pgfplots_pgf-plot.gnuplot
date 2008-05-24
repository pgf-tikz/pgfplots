set terminal table; set output "gnuplot/pgfplots_pgf-plot.table"; set format "%.5f"
set samples 25; plot [x=0:10] 2**(-1.5*x -3)
