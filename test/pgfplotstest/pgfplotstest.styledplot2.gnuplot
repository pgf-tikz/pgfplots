set terminal table; set output "pgfplotstest.styledplot2.table"; set format "%.5f"
set samples 25; plot [x=-5:5] (x**5 - 3)/2000
