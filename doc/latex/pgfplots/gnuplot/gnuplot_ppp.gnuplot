set terminal table; set output "gnuplot/gnuplot_ppp.table"; set format "%.5f"
set samples 120; plot [x=-40:40] 10000*sin(x/3)
