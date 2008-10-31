# converts all examples from pgfplots and pgfplotstable to graphics and assembles a pretty-printed HTML gallery.

DOC_SRC=$(wildcard ../pgfplots.*.tex) ../pgfplotstable.tex
# DOC_SRC:=../pgfplotstable.tex

PREPARED_SRC=$(wildcard example*.tex)

.PHONY: all prepare clean prepared

all: prepare
	$(MAKE) prepared
	$(MAKE) images

prepare: $(DOC_SRC)
	./extractexamples.pl ./example ./index.html $(DOC_SRC) 

clean:
	rm ./example* 


prepared: $(PREPARED_SRC:%.tex=%.pdf)

images: $(PREPARED_SRC:%.tex=%.png)

%.png: %.pdf
	convert -transparent white -depth 150 $< $@

%.pdf: %.tex
	pdflatex -interaction batchmode -halt-on-error -shell-escape $< 2>/dev/null 1>/dev/null
	pdfcrop $@ $@ 2>/dev/null 1>/dev/null
	@rm $(@:.pdf=.log) $(@:.pdf=.aux)
