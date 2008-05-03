set terminal table; set output "gnuplot/pgfplots_parablex.table"; set format "%.5f"
set samples 8; plot [x=-5:0] 4*x**2 - 5
