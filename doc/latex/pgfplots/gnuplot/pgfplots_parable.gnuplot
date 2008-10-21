set terminal table; set output "gnuplot/pgfplots_parable.table"; set format "%.5f"
set format "%.7e";; set samples 25; plot [x=-5:5]  4*x**2 - 5;
