set terminal table; set output "pgfplotstest.styledplot.table"; set format "%.5f"
set samples 25; plot [x=-5:5] (40*x**2 - 5*x +3)/2000
