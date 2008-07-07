set terminal table; set output "gnuplot/pgfplots_sqrtabsx.table"; set format "%.5f"
set format "%.7e";; set samples 501; plot [x=-4:4] sqrt(abs(x))
