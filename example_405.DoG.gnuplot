set table "example_405.DoG.table"; set format "%.5f"
set format "%.7e";; set samples 100; set dummy x; plot [x=-15:15] 1.3*exp(-x**2/10) - exp(-x**2/20);
