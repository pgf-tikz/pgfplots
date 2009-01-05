set terminal table; set output "gnuplot/pgfplots_pow1.table"; set format "%.5f"
set format "%.7e";; set samples 8; set logscale y 2.71828182845905; plot [x=0:10] 2**(-2*x + 6);
