set terminal table; set output "gnuplot/pgfplots_pgf-plot.table"; set format "%.5f"
set format "%.7e"; set samples 100; plot [x=-5:5] exp(-x**2/10) - exp(-x**2/20)
