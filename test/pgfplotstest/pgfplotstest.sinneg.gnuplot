set terminal table; set output "pgfplotstest.sinneg.table"; set format "%.5f"
set format "%.7e";; set samples 40; plot [x=-5:5] sin(x)
