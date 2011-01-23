
UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)

all: test.log

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


