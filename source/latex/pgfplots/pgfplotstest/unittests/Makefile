
UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)
UNIT_PNGS=$(UNIT_SOURCES:.tex=.png)


.NOTPARALLEL:

.PHONY: references pdf png all

all: test.log

png: $(UNIT_PNGS)

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


%.png: %.pdf
	convert $< -append $@
	diff $@ references/$@; \
	if [ ! $$? -eq 0 ]; then \
		echo 'convert "$@" "references/$@" -compose difference -composite -colorspace gray miff:- | display' >> $(@:.pdf=.regression.sh); \
		echo "$(@:.pdf=.regression.sh)" >> regressions.sh; \
		echo "$@ WAS UNEXPECTED. See regressions.sh"; \
		false;\
	fi
	
		

OLD_BRANCH_STORE=Makefile.oldbranch

cleanreferences:
	$(MAKE) -f Makefile.references REALLY_INVOKE=1 clean

references:
	@$(MAKE) -f Makefile.references REALLY_INVOKE=1; CODE=$$?; \
	./Makefile.oldbranch; \
	echo "CHECKOUT DONE; RESUMING MAKE"; \
	exit $$CODE


