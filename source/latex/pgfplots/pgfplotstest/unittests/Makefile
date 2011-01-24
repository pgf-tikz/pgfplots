
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

references:
	@BRANCH=`git branch | grep \* | cut -c 3-`; \
	echo "CHECKING OUT $(DEFAULT_REFERENCE_BRANCH)"; \
	git checkout $(DEFAULT_REFERENCE_BRANCH) || exit 1;\
	$(MAKE) -f Makefile.references REALLY_INVOKE=1; CODE=$$?; \
	echo "RESTORING $$BRANCH";\
	git checkout $$BRANCH;\
	exit $$CODE


