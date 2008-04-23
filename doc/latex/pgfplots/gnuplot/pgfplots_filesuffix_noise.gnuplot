set terminal table; set output "gnuplot/pgfplots_filesuffix_noise.table"; set format "%.5f"
set samples 10; plot [x=-6:5] (-x**5 - 242 + (-300 + 600*rand(0)))
