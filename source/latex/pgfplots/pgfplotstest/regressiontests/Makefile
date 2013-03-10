# This is a regression-test framework for tex.
#
# The idea is as follows:
#
# 1. there is a reference revision on which a unittest runs as expected.
# 2. there is a way to generate the reference image (to pdf and to png)
# 3. you can compile the actual image
# 4. you can "diff" the actual image and the reference (and view the difference)
# 5. you can create a log of the single results and diffs
#
# This makefile can do all of these steps.
#
# The references can be generated with
# >> make references
# References are stored in a sub-folder called "references". You can *REMOVE* this directory
# to clean references.
#
# References are compiled using different revisions of the code; they are checked out into /tmp. 
#
#
# HOW TO WRITE TESTS
# Simply write a minimal, self-contained .tex file (say, unittest_42.tex) in this directory. It can have multiple
# pages.
# 
# If a test contains \FIXIT, it is marked as "this test is known to be broken - test issue"
#
#
# If your example needs a specific reference revision, create a file <base>.checkoutreferencerev.sh which contains something
# like "git checkout 1.3.1" . It will be invoked to checkout the reference revision.
#
# If your example needs a specific command to translate it, create a file <base>.compile.sh which runs it. Its first argument will be the base file name (without .tex).
#
# Then, type "make unittest_42.diff" to create reference, actual, and difference.
#
# Typing 'make' will make all unittests (all *.tex files in this directory).
#  
# COMPILING TESTS
# 1. compile reference, actual, and diff:
# >> make unittest_polar_7.diff
# 2. compile reference only
# >> make references/unittest_polar_7.pdf
# 3. compile actual only
# >> make unittest_polar_7.pdf
#
# The makefile will avoid re-creation of test cases in order to allow concentrate on failures.
# If you want to remake tests, you can either type 
# >> make clean
# or you can use the (standard) make feature 
# >> make unittest_polar_7.diff -B
# which forces remake, even if modtimes are unchanged 
#
#
# SPECIALTIES:
# create a file unittest_*.diff.accepted containing accepted diff results 
# (in case you approved that they are "not an error"). 
# The file should contain what the failure-output of the 'make test.diff' target.

UNIT_SOURCES=$(wildcard unittest_*.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)
DIFF_MEASURES=$(UNIT_SOURCES:.tex=.diff)

# REQUIRES apcalc package ('calc' executable)
ACCEPTED_NORMALIZED_ERROR=5e-4
DIRECTORY_FOR_ACCEPTED_ERRORS=./pgfplotsUTaccepted

INCLUDE_GRAPHICS_FROM_DIR_DIRECTORY=plotdata/risingdrop3d.png plotdata/plotgraphics3dsurf.png

# -------------------------------------------------
# stuff for references:
# allow dynamic creation of reference files. I have never used something else.
ENABLE_DYNAMIC_REFERENCES=1

STATISTICS=$$(ls unittest_*.pdf | wc -l)/$$(ls unittest_*.tex | wc -l) [F=$$(ls unittest_*.diff.png | wc -l)]

UNIT_PDF_REFERENCES=$(UNIT_SOURCES:%.tex=references/%.pdf)
WORKING_DIR=$(shell pwd)
PGFPLOTS_GIT_BASEDIR=$(WORKING_DIR:source/latex/pgfplots/pgfplotstest/regressiontests=)
TMP_REPOSITORY=/tmp/pgfplots_copy
DEFAULT_REFERENCE_BRANCH:=$(shell git describe --tags HEAD)

PGF_CVS_PATH=~/code/tex/pgf

.PRECIOUS:  $(UNIT_SOURCES:%.tex=%.checkoutreferencerev.sh) $(UNIT_SOURCES:%.tex=%.compile.sh) $(UNIT_PDF_REFERENCES) $(UNIT_SOURCES:%.tex=%.pdf)

AUTO_INDENT_PIPE=2>&1 | sed -e 's/^/  /'
$(shell mkdir -p gnuplot references/gnuplot references/plotdata)
# -------------------------------------------------

.NOTPARALLEL:

# .PRECIOUS: $(UNIT_PNGS)

.PHONY: references pdf png  cleanX clean setupdirs

diff: $(DIFF_MEASURES) 

pdf: $(UNIT_PDFS) 

clean: cleanX
	rm -fr references 

# clean all except for references:
cleanX:
	rm -fr $(DIFF_MEASURES) $(UNIT_PDFS) unittest*.png $(DIRECTORY_FOR_ACCEPTED_ERRORS)

%.diff.png: %.diff
	@

%.diff: %.pdf references/%.pdf
	@echo "$<: diffing --> $@ ..."
	@./pdfdiff.sh $< references/$< $@
	@if [ "`cat $@`" = "0 (0)" ]; then \
		echo "  PASSED: no differences detected (removing superfluos diff-pngs)"; \
		rm -f $@.png $<.png $(DIRECTORY_FOR_ACCEPTED_ERRORS)/$@ $(DIRECTORY_FOR_ACCEPTED_ERRORS)/$@.png; # no need to keep the images (the latter for multi-page mode). \
	else \
		#echo "$<: found nonzero pixel differences `cat $@`."; \
		sed -e 's/.*(\(.*\)).*/\1/' < $@  > $@.normalized || exit 1; \
		NORMALIZED=`cat $@.normalized`; \
		rm -f $@.normalized; \
		calc -p "$$NORMALIZED < $(ACCEPTED_NORMALIZED_ERROR)" > $@.isaccepted || ( echo "calc invocation failed. Please ensure that apcalc package is installed."; exit 1 ); \
		if [ ! -f $@.accepted -a "`cat $@.isaccepted`" = "1" ]; then \
			echo "  PASSED: only approved differences `cat $@` detected and no *.accepted (less than $(ACCEPTED_NORMALIZED_ERROR); moving superfluos diff-pngs to $(DIRECTORY_FOR_ACCEPTED_ERRORS))"; \
			mkdir -p $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			mv $@.png $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			cp $@ $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			rm -f $@.png $<.png; # no need to keep the images (the latter for multi-page mode). \
		elif [ -f $@.accepted -a "`cat $@`" = "`cat $@.accepted`" ]; then \
			echo "  PASSED: only manually approved differences `cat $@` detected (moving superfluos diff-pngs to $(DIRECTORY_FOR_ACCEPTED_ERRORS))"; \
			mkdir -p $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			mv $@.png $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			cp $@ $(DIRECTORY_FOR_ACCEPTED_ERRORS); \
			rm -f $@.png $<.png; # no need to keep the images (the latter for multi-page mode). \
		else \
			echo "  FAILURE: found pixel differences for $<: " `cat $@`; \
			echo "  (if not a bug: 'echo \"`cat $@`\" > $@.accepted')"; \
			echo "  Call './displayDiff.sh $@.png' (see summarize of regressions.sh)"; \
			rm $@; # make sure it will be recomputed! \
			false; \
		fi; \
		CODE=$$?; \
		rm -f $@.isaccepted; \
		exit $$CODE; \
	fi
		


#	convert $< -append $@
#	@diff $@ references/$@; \
#	if [ ! $$? -eq 0 ]; then \
#		echo 'convert "$@" "references/$@" -compose difference -composite -colorspace gray miff:- | display' > $(@:.png=.regression.sh); \
#		echo "echo $@" >> regressions.sh; \
#		echo "sh $(@:.png=.regression.sh)" >> regressions.sh; \
#		echo "$@ WAS UNEXPECTED. See regressions.sh"; \
#		touch -t 01010000 $@; # make sure its older MMDDHHSS\
#		false;\
#	fi
	
		

references: $(UNIT_PDF_REFERENCES)

%.checkoutreferencerev.sh:
	@if [ ! -f $@ ]; then pwd; echo "generating $@ (with $(DEFAULT_REFERENCE_BRANCH))..."; echo "git checkout $(DEFAULT_REFERENCE_BRANCH)" > $@ || exit 1; fi

ifeq ($(ENABLE_DYNAMIC_REFERENCES),1)

references/%.pdf: %.tex %.checkoutreferencerev.sh %.compile.sh
	@echo "$<: generating $@"; \
	REFERENCE_SCRIPT=$(<:.tex=.checkoutreferencerev.sh);\
	#echo "  checking out reverence revision to $(TMP_REPOSITORY)..."; \
	if [ ! -d $(TMP_REPOSITORY) ]; then \
		cd $(dir $(TMP_REPOSITORY)) || exit 1; \
		git clone $(PGFPLOTS_GIT_BASEDIR) $(notdir $(TMP_REPOSITORY)) || exit 1; \
	fi; \
	cd $(TMP_REPOSITORY) || exit 1; \
	cat $(WORKING_DIR)/$$REFERENCE_SCRIPT $(AUTO_INDENT_PIPE); \
	sh $(WORKING_DIR)/$$REFERENCE_SCRIPT  1>/dev/null 2>&1; \
	if [ $$? -ne 0 ]; then \
		echo "CHECKOUT FAILED." $(AUTO_INDENT_PIPE); \
		echo "(cleaning $(TMP_REPOSITORY))..." $(AUTO_INDENT_PIPE); \
		rm -fr $(TMP_REPOSITORY); \
		exit 1; \
	fi
	@cd references || exit 1;\
	export TEXINPUTS=.:..:$(TMP_REPOSITORY)/tex//:$(PGF_CVS_PATH)/generic//:$(PGF_CVS_PATH)/latex//:$(TEXINPUTS); \
	echo "export TEXINPUTS=$${TEXINPUTS}:\$$TEXINPUTS" $(AUTO_INDENT_PIPE); \
	echo "cd references && \"compile $<\" ..." $(AUTO_INDENT_PIPE); \
	# create *.diff.png -> this makes it much more visible that it failed: \
	sh ../$(<:.tex=.compile.sh) $(<:.tex=) 1>/dev/null 2>&1 || \
		( sh ../../scripts/compile_failed.sh "../$<" "$@" "\nPlease check $(<:.tex=.checkoutreferencerev.sh)" $(AUTO_INDENT_PIPE); exit 1 )

else
#disable dynamic reference (re-)creation:
references/%.pdf: %.tex 
	@if [ ! -f $@ ]; then echo "  REFERENCE IS MISSING AND CAN'T BE CREATED AUTOMATICALLY (ENABLE_DYNAMIC_REFERENCES=0)"; exit 1; fi

endif

# make sure this rule is AFTER references/%.pdf !
%.pdf: %.tex %.compile.sh $(INCLUDE_GRAPHICS_FROM_DIR_DIRECTORY)
	@echo "$(STATISTICS) $@: recompiling $< ..."
	@rm -f $@; sh ./$(@:.pdf=.compile.sh) $(<:.tex=) >/dev/null 2>&1  || \
		( sh ../scripts/compile_failed.sh "$<" "$@" "" $(AUTO_INDENT_PIPE); exit 1 )

%.compile.sh:
	@if [ ! -f $@ ]; then echo "generating default $@ ..."; echo 'pdflatex -shell-escape -interaction batchmode -halt-on-error "$$@"' > $@; fi

# temporary links to graphics which are in the doc directory:
# see $(INCLUDE_GRAPHICS_FROM_DIR_DIRECTORY)
plotdata/%: 
	cd plotdata && ln -fs ../../../../../../doc/latex/pgfplots/plotdata/$(notdir $@)
