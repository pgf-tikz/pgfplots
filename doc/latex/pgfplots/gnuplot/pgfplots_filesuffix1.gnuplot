set terminal table; set output "gnuplot/pgfplots_filesuffix1.table"; set format "%.5f"
set samples 25; plot [x=-5:5] (40*x**2 - 5*x +3)
