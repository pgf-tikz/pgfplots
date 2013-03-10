
UNITTESTS=$(wildcard unittest_*.tex)

RESULTS=$(UNITTESTS:.tex=.pdf)

all: $(RESULTS)

clean:
	rm -fr $(RESULTS)

%.pdf: %.tex %.compile.sh
	@echo "$@: recompiling $< ..."
	@rm -f $@; sh ./$(@:.pdf=.compile.sh) $(<:.tex=) >/dev/null 2>&1  || \
		( sh ../scripts/compile_failed.sh "$<" "$@" "" $(AUTO_INDENT_PIPE); exit 1 )

%.compile.sh:
	@if [ ! -f $@ ]; then echo "generating default $@ ..."; echo 'pdflatex -shell-escape -interaction batchmode -halt-on-error "$$@"' > $@; fi

