set terminal table; set output "gnuplot/gnuplot_exp.table"; set format "%.5f"
set samples 15; plot [x=-5:10] exp(x)
