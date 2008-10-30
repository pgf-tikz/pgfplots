
DOC_SRC=$(wildcard ../pgfplots.*.tex)

PREPARED_SRC=$(wildcard example*.tex)

.PHONY: all prepare clean prepared

all: prepare
	$(MAKE) prepared
	$(MAKE) images

prepare: $(DOC_SRC)
	./extractexamples.pl $(DOC_SRC) ./example

clean:
	rm ./example* 


prepared: $(PREPARED_SRC:%.tex=%.pdf)

images: $(PREPARED_SRC:%.tex=%.png)

%.png: %.pdf
	convert -depth 120 $< $@

%.pdf: %.tex
	pdflatex -interaction batchmode -halt-on-error -shell-escape $< 2>/dev/null 1>/dev/null
	pdfcrop $@ $@ 2>/dev/null 1>/dev/null
	@rm $(@:.pdf=.log) $(@:.pdf=.aux)
