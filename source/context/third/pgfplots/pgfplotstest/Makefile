# ATTENTION: this may need ~/context/tex/setuptex in advance

all: mkii mkiv

mkii:
	texexec --passon="--shell-escape"  --once --pdf pgfplotstest
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done

mkiv:
	context --once pgfplotstest_mkiv
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done
