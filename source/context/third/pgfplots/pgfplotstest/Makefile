
all: mkii mkiv

mkii:
	# ATTENTION: this may need >> . ~/context/tex/setuptex 
	texexec --passon="--shell-escape"  --once --pdf pgfplotstest
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done

mkiv:
	# ATTENTION: this may need >> . ~/context/tex/setuptex 
	context --once pgfplotstest_mkiv
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done
