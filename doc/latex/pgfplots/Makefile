
PDFLATEX=pdflatex -shell-escape

all: pgfplots.pdf pgfplotstable.pdf TeX-programming-notes.pdf
	@echo "$^ have been compiled successfully. I did NOT check for references, so you may need to rerun make several times."

notes: TeX-programming-notes.pdf
pgfplots: pgfplots.pdf
pgfplotstable: pgfplotstable.pdf

include pgfplots.makefile

%.pdf: FORCE
	mkdir -p gnuplot
	@export TEXMFCNF=.: && $(PDFLATEX) $(@:.pdf=.tex)
	@bibtex $(@:.pdf=) || exit 0
	@makeindex $(@:.pdf=) || exit 0
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

pgfplots.pdf: $(ALL_FIGURES)

pgfplots.makefile:
	@export TEXMFCNF=.: && $(PDFLATEX) pgfplots
	
clean:
	rm -f *.aux *.ind *.idx *.toc *.out *.log *.ilg *.dvi pgfplots.makefile pgfplots.pdf pgfplotstable.pdf *.djs *.bbl *.blg figures/expensiveexample*


FORCE:
