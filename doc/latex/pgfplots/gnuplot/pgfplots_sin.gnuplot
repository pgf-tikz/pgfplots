set terminal table; set output "gnuplot/pgfplots_sin.table"; set format "%.5f"
set format "%.7e";; set samples 25; plot [x=-5:5]  sin(x);
