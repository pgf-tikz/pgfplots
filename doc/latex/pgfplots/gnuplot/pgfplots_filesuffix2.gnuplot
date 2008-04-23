set terminal table; set output "gnuplot/pgfplots_filesuffix2.table"; set format "%.5f"
set samples 10; plot [x=-5:5] (-x**5 - 242 + 50*rand(0))
