
UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)
UNIT_PNGS=$(UNIT_SOURCES:.tex=.png)

$(shell echo "#!/bin/sh" > regressions.sh && chmod 0755 regressions.sh)

.NOTPARALLEL:

# .PRECIOUS: $(UNIT_PNGS)

.PHONY: references pdf png all

all: test.log

png: $(UNIT_PNGS)

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


%.png: %.pdf
	@rm -f $(@:.png=.regression.sh)
	convert $< -append $@
	@diff $@ references/$@; \
	if [ ! $$? -eq 0 ]; then \
		echo 'convert "$@" "references/$@" -compose difference -composite -colorspace gray miff:- | display' > $(@:.png=.regression.sh); \
		echo "echo $@" >> regressions.sh; \
		echo "sh $(@:.png=.regression.sh)" >> regressions.sh; \
		echo "$@ WAS UNEXPECTED. See regressions.sh"; \
		touch -t 01010000 $@; # make sure its older MMDDHHSS\
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


