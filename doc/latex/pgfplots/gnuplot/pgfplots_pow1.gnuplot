set terminal table; set output "gnuplot/pgfplots_pow1.table"; set format "%.5f"
set format "%.7e"; set samples 8; plot [x=0:10] 2**(-2*x + 6)
