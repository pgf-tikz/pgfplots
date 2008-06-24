set terminal table; set output "gnuplot/pgfplots_sinneg.table"; set format "%.5f"
set format "%.7e"; set samples 40; plot [x=-10:0] sin(x)
