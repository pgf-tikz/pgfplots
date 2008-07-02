set terminal table; set output "gnuplot/pgfplots_gnuplot_ppp.table"; set format "%.5f"
set format "%.7e";; set samples 120; plot [x=-40:40] 10000*sin(x/3)
