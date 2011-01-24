
UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)

UNIT_PNG_REFERENCES=$(UNIT_SOURCES:%.tex=%_reference.png)

DEFAULT_REFERENCE_BRANCH=1.3.1

.NOTPARALLEL:

.PHONY: references

all: test.log

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


%.png: references

OLD_BRANCH_STORE=Makefile.oldbranch

references:
	@echo "Storing old branch into $(OLD_BRANCH_STORE) (if it does not already exist)"
	@if [ ! -f "$(OLD_BRANCH_STORE)" ]; then git branch | grep \* | cut -c 3- > $(OLD_BRANCH_STORE); fi
	@echo "Old branch = `cat $(OLD_BRANCH_STORE)`"
	git checkout $(DEFAULT_REFERENCE_BRANCH)
	@$(MAKE) -f Makefile.references REALLY_INVOKE=1; CODE=$$?; \
	echo "RESTORING `cat $(OLD_BRANCH_STORE)`";\
	git checkout `cat $(OLD_BRANCH_STORE)`;\
	echo "CHECKOUT OK; RESUMING MAKE"; \
	exit $$CODE


