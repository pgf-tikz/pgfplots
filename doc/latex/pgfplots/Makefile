
PDFLATEX=pdflatex -shell-escape

all: pgfplots.pdf pgfplotstable.pdf
	@echo "$^ have been compiled successfully. I did NOT check for references, so you may need to rerun make several times."

pgfplots: pgfplots.pdf
pgfplotstable: pgfplotstable.pdf

%.pdf: FORCE
	@$(PDFLATEX) $(@:.pdf=.tex)
	@bibtex $(@:.pdf=) || exit 0
	@makeindex $(@:.pdf=) || exit 0
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."
	
FORCE:
