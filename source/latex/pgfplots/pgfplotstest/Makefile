
PDFLATEX=pdflatex -shell-escape

all: pgfplotstest.pdf
	@echo "$^ have been compiled successfully. I did NOT check for references, so you may need to rerun make several times."

referenceimages: FORCE
	mkdir -p gnuplot
	cp ../../../../tex/latex/pgfplots/pgfregressiontest.sty .
	@REVISION=`git describe --tags HEAD` && \
	$(PDFLATEX) '\def\referencemode{1}\def\pgfplotstestautoregression{1}\input{$(@:.pdf=.tex)}'; \
	git checkout $$REVISION; \
	rm -f pgfregressiontest.sty
	@echo ""
	@echo "All reference images compiled successfully."
	

%.pdf: FORCE
	mkdir -p gnuplot
	@$(PDFLATEX) '\def\pgfplotstestautoregression{1}\input{$(@:.pdf=.tex)}'
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

%.tex: FORCE
	@$(PDFLATEX) '\def\pgfplotstestautoregression{1}\def\pgfplotstestincludeonly{\includeonly{$(@:.tex=)}}\input{pgfplotstest.tex}'
	@echo ""
	@echo "$@ compiled successfully. You may need to re-run make several times to get all cross-references right."

clean:
	rm -f *.aux *.ind *.idx *.toc *.out *.log *.ilg *.dvi pgfplotstest.pdf *.djs *.bbl *.blg

test: pgfplotstest.pdf
pdf: pgfplotstest.pdf

FORCE:
