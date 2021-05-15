# needs (at least):
# $ tlmgr install zapfding symbol units

# LATEX=pdflatex -shell-escape
LATEX=lualatex -shell-escape

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
TEXINPUTS:=./plotdata/:$(TEXINPUTS)
export TEXINPUTS

vpath %.dat ./plotdata

$(info TEXINPUTS = $(TEXINPUTS))

include pgfplots.makefile

TeX-programming-notes.pdf: revisionfile FORCE
	mkdir -p gnuplot figures/expensiveexamples
	@$(TEXMFCNF_FOR_MEMLIMITS) && pdflatex $(@:.pdf=.tex)
	@bibtex $(@:.pdf=) || exit 0
	@makeindex $(@:.pdf=) || exit 0
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

%.pdf: revisionfile FORCE
	mkdir -p gnuplot figures/expensiveexamples
	@$(TEXMFCNF_FOR_MEMLIMITS) && $(LATEX) $(@:.pdf=.tex)
	@bibtex $(@:.pdf=) || exit 0
	@makeindex $(@:.pdf=) || exit 0
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

html: FORCE
	mkdir -p html/figures/generated
	mkdir -p html/gnuplot
	# note: I could also change TEXINPUTS. But that would also include .aux files from the pdf version.
	# prefer a copy:
	cd html && ln -f -s ../*.tex ../*.sty ../*.dat ../plotdata .
	cd html/figures && ln -f -s `find ../../figures ! -name 'expensive*' -type f` .
	@cd html && \
		$(LATEX) '\def\pgfplotsmanualhtlatexmode{1} \input pgfplots.tex'
	@cd html && \
		$(TEXMFCNF_FOR_MEMLIMITS) && \
		make -k -f pgfplots.makefile
	@cd html && \
		htlatex pgfplots.tex "../pgfplots.tex4ht.cfg"
	
pgfplots.pdf: $(ALL_FIGURES)

pgfplots.makefile:
	mkdir -p gnuplot figures/expensiveexamples
	@$(TEXMFCNF_FOR_MEMLIMITS) && $(LATEX) pgfplots

clean:
	rm -f *.aux *.ind *.idx *.toc *.out *.log *.ilg *.dvi pgfplots.makefile pgfplots.pdf pgfplotstable.pdf *.djs *.bbl *.blg figures/expensiveexample*


revisionfile:
	cd ../../.. && ./scripts/pgfplots/pgfplotsrevisionfile.sh

FORCE:
