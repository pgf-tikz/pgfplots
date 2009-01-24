set terminal table; set output "gnuplot/pgfplots_pow2.table"; set format "%.5f"
set format "%.7e";; set samples 25; set logscale y 2.71828182845905; plot [x=0:10] 2**(-1.5*x -3);
