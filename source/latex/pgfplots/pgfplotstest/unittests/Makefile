
UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)


.NOTPARALLEL:

.PHONY: references

all: test.log

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


%.png: references

OLD_BRANCH_STORE=Makefile.oldbranch

references:
	@$(MAKE) -f Makefile.references REALLY_INVOKE=1; CODE=$$?; \
	./Makefile.oldbranch && rm -f Makefile.oldbranch; \
	echo "CHECKOUT DONE; RESUMING MAKE"; \
	exit $$CODE


