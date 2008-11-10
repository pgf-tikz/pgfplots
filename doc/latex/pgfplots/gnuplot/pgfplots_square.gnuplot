set terminal table; set output "gnuplot/pgfplots_square.table"; set format "%.5f"
set format "%.7e";; set samples 20; plot [x=-4:4] x*x+x+104;
