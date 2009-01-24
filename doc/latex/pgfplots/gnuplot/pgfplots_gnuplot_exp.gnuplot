set terminal table; set output "gnuplot/pgfplots_gnuplot_exp.table"; set format "%.5f"
set format "%.7e";; set samples 25; set logscale y 2.71828182845905; plot [x=-5:10] exp(x);
