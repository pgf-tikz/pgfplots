set terminal table; set output "gnuplot/pgfplots_filesuffix.table"; set format "%.5f"
set format "%.7e";; set samples 25; plot [x=] (-x**5 - 242);
