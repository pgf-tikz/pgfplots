
PDFLATEX=pdflatex -shell-escape

all: pgfplots.pdf pgfplotstable.pdf TeX-programming-notes.pdf pgfplotstodo.pdf
	@echo "$^ have been compiled successfully. I did NOT check for references, so you may need to rerun make several times."

notes: TeX-programming-notes.pdf
todo: pgfplotstodo.pdf
pgfplots: pgfplots.pdf
pgfplotstable: pgfplotstable.pdf

# was: 
# export TEXMFCNF=.:
# but it seems as if that is ignored for some reason
TEXMFCNF_FOR_MEMLIMITS=export TEXMFCNF=~/texmf/mytexcnf:

include pgfplots.makefile

%.pdf: FORCE
	mkdir -p gnuplot
	@$(TEXMFCNF_FOR_MEMLIMITS) && $(PDFLATEX) $(@:.pdf=.tex)
	@bibtex $(@:.pdf=) || exit 0
	@makeindex $(@:.pdf=) || exit 0
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

html: FORCE
	mkdir -p html/figures/generated
	mkdir -p gnuplot
	@cd html && \
		$(TEXMFCNF_FOR_MEMLIMITS) && \
		export TEXINPUTS=../$$TEXINPUTS; \
		$(PDFLATEX) '\def\pgfplotsmanualhtlatexmode{1} \input $(@:.pdf=.tex)'

pgfplots.pdf: $(ALL_FIGURES)

pgfplots.makefile:
	@$(TEXMFCNF_FOR_MEMLIMITS) && $(PDFLATEX) pgfplots
	
clean:
	rm -f *.aux *.ind *.idx *.toc *.out *.log *.ilg *.dvi pgfplots.makefile pgfplots.pdf pgfplotstable.pdf *.djs *.bbl *.blg figures/expensiveexample*


FORCE:
