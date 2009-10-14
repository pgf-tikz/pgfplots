
PDFLATEX=pdflatex -shell-escape

all: pgfplotstest.pdf
	@echo "$^ have been compiled successfully. I did NOT check for references, so you may need to rerun make several times."

%.pdf:
	mkdir -p gnuplot
	@$(PDFLATEX) $(@:.pdf=.tex)
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

%.tex: FORCE
	@$(PDFLATEX) \\\def\\pgfplotstestincludeonly{\\includeonly{$(@:.tex=)}}\\input{pgfplotstest.tex}
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

clean:
	rm -f *.aux *.ind *.idx *.toc *.out *.log *.ilg *.dvi pgfplotstest.pdf *.djs *.bbl *.blg

test: pgfplotstest.pdf
pdf: pgfplotstest.pdf

FORCE:
