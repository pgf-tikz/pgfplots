PGFPLOTS_GIT_BASEDIR=$(WORKING_DIR:source/latex/pgfplots/pgfplotstest/unittest=)
# the following two variables control which PGF version is to be used for the references and the actual files, respectively:
#PGF_ACTUAL_PATH=~/code/tex/pgf
#PGF_ACTUAL_PATH=~/code/tex/pgf_2.10/tex
#PGF_ACTUAL_PATH=~/code/tex/pgf_3.0.0/tex
PGF_ACTUAL_PATH=~/code/tex/pgf_3.0.1/tex

UNITTESTS=$(wildcard unittest_*.tex)

RESULTS=$(UNITTESTS:.tex=.pdf)

all: $(RESULTS)

clean:
	rm -fr $(RESULTS)

%.pdf: %.tex %.compile.sh
	@echo "$@: recompiling $< ..."
	@export TEXINPUTS="./:$(PGFPLOTS_GIT_BASEDIR)/tex//:$(PGF_ACTUAL_PATH)/generic//:$(PGF_ACTUAL_PATH)/latex//:"; \
	export LUAINPUTS="$(PGFPLOTS_GIT_BASEDIR)/tex/generic/pgfplots/lua/:$(PGFPLOTS_GIT_BASEDIR)/tex/generic/pgfplots/lua/pgfplotsoldpgfsupp:$(PGF_ACTUAL_PATH)/generic//:$(PGF_ACTUAL_PATH)/generic/pgf/libraries/luamath/:"; \
	rm -f $@; sh ./$(@:.pdf=.compile.sh) $(<:.tex=) >/dev/null 2>&1  || \
		( sh ../scripts/compile_failed.sh "$<" "$@" "" $(AUTO_INDENT_PIPE); exit 1 )

%.compile.sh:
	@if [ ! -f $@ ]; then echo "generating default $@ ..."; echo 'pdflatex -shell-escape -interaction batchmode -halt-on-error "$$@"' > $@; fi

