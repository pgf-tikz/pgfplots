# converts all examples from pgfplots and pgfplotstable to graphics and assembles a pretty-printed HTML gallery.
#
#
# REQUIREMENTS:
# make sure TEXINPUTS contains the doc/latex/pgfplots/ tree recursively.

# FIXME : this leads to strange sequences... sort correctly!
DOC_SRC=$(wildcard ../pgfplots.*.tex) ../pgfplotstable.tex
# DOC_SRC:=../pgfplotstable.tex

PREPARED_SRC=$(wildcard example*.tex)

.PHONY: all clean prepared

all: prepare
	$(MAKE) prepared
	$(MAKE) images

prepare: $(DOC_SRC)
	./extractexamples.pl ./example ./gallery.html $(DOC_SRC) 
	touch $@

clean:
	rm -f ./example* prepare gallery.html


prepared: $(PREPARED_SRC:%.tex=%.pdf)

images: $(PREPARED_SRC:%.tex=%.png)

%.png: %.pdf
	convert -transparent white -depth 150 $< $@

# eliminate the %.tex dependency to simplify remakes:
# %.pdf: %.tex

%.pdf:
	export TEXINPUTS="$(TEXINPUTS):..:../figures:" && lualatex -interaction batchmode -halt-on-error -shell-escape $(@:.pdf=) 2>/dev/null 1>/dev/null
	#pdfcrop $@ $@ 2>/dev/null 1>/dev/null
	@rm $(@:.pdf=.log) $(@:.pdf=.aux)
