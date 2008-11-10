set terminal table; set output "gnuplot/pgfplots_DoG.table"; set format "%.5f"
set format "%.7e";; set samples 100; plot [x=-15:15] 1.3*exp(-x**2/10) - exp(-x**2/20);
