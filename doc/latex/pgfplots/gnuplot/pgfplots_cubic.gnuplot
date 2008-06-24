set terminal table; set output "gnuplot/pgfplots_cubic.table"; set format "%.5f"
set format "%.7e"; set samples 8; plot [x=-5:0] 0.7*x**3 + 50
