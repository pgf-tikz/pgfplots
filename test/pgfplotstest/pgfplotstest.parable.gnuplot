set terminal table; set output "pgfplotstest.parable.table"; set format "%.5f"
set samples 25; plot [x=-5:5] 4*x**2 - 5
