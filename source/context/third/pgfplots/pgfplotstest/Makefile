
all:
	texexec --passon="--shell-escape"  --once --pdf pgfplotstest
	for A in gnuplot/*.gnuplot; do gnuplot <$$A; done
