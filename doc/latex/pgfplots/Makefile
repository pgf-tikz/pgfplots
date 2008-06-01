
PDFLATEX=pdflatex -shell-escape


pgfplots.pdf: FORCE
	@$(PDFLATEX) pgfplots.tex
	@bibtex pgfplots
	@makeindex pgfplots
	@echo "pgfplots.pdf compiled successfully. You may need to re-run make several times to get all cross-references right."
	
FORCE:
