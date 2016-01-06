
all: mkii mkiv

mkii:
	texexec --passon="--shell-escape"  --once --pdf pgfplotstest
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done

mkiv:
	. ~/context/tex/setuptex && context --once pgfplotstest_mkiv
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done
