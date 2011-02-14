# This is a unit-test framework for tex.
#
# The idea is as follows:
#
# 1. there is a reference revision on which a unittest runs as expected.
# 2. there is a way to generate the reference image (to pdf and to png)
# 3. you can compile the actual image
# 4. you can "diff" the actual image and the reference (and view the difference)
# 5. you can create a log of the single results and diffs
#
# This makefile assumes that references exist already. If so, it can accomplish steps (3), (4), and (5).
#
# The references can be generated with
# >> make references
# References are stored in a sub-folder called "references". You can *REMOVE* this directory
# to clean references.
#
# References are compiled using different revisions of the code. 
#
#
# HOW TO WRITE TESTS
# Simply write a minimal .tex file in this directory. The file is treated as self-contained unit test. It can have multiple
# pages.
#
# If your example needs a specific reference revision, create a file <base>.checkoutreferencerev.sh which contains something
# like "git checkout 1.3.1" . It will be invoked to checkout the reference revision.
#
# Then, type "make references".
#
# Then, everything is ready and you can use "make" to compile the example and compare against the reference.
# 
# COMPILING TESTS
# use 
# >> make unittest_polar_7.pdf
# to compile the pdf
# use
# >> make unittest_polar_7.png
# to compile the image and to compute the diff to its reference
#
# FIXME : in the moment this stuff is not yet ready.

UNIT_SOURCES=$(wildcard *.tex)

UNIT_PDFS=$(UNIT_SOURCES:.tex=.pdf)
UNIT_PNGS=$(UNIT_SOURCES:.tex=.png)

$(shell echo "#!/bin/sh" > regressions.sh && chmod 0755 regressions.sh)

.NOTPARALLEL:

# .PRECIOUS: $(UNIT_PNGS)

.PHONY: references pdf png all

png: $(UNIT_PNGS)

pdf: $(UNIT_PDFS)

%.pdf: %.tex
	pdflatex -halt-on-error -shell-escape $^


%.png: %.pdf
	@rm -f $(@:.png=.regression.sh)
	convert $< -append $@
	@diff $@ references/$@; \
	if [ ! $$? -eq 0 ]; then \
		echo 'convert "$@" "references/$@" -compose difference -composite -colorspace gray miff:- | display' > $(@:.png=.regression.sh); \
		echo "echo $@" >> regressions.sh; \
		echo "sh $(@:.png=.regression.sh)" >> regressions.sh; \
		echo "$@ WAS UNEXPECTED. See regressions.sh"; \
		touch -t 01010000 $@; # make sure its older MMDDHHSS\
		false;\
	fi
	
		

OLD_BRANCH_STORE=Makefile.oldbranch

cleanreferences:
	$(MAKE) -f Makefile.references REALLY_INVOKE=1 clean

references:
	@$(MAKE) -f Makefile.references REALLY_INVOKE=1; CODE=$$?; \
	./Makefile.oldbranch; \
	echo "CHECKOUT DONE; RESUMING MAKE"; \
	exit $$CODE


