#!/bin/bash

# cause nonzero exit status to fail the script:
set -e

echo "   [cleanup...]"
#ls $@-figure*
rm -f $@-figure*
#ls $@-figure*

# This line here appears to be unmotivated. However, it has its uses during
# the compilation of REFERENCEs: this step has search path .:.. . Consequently,
# it will find the .md5 file of the actual - and will fail.
# This here avoids the problem by means:
touch $@-figure0.md5


echo "   [first compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

echo "   [makefile for images...]"
make -f "$@.makefile" || ( rm -f $@.pdf; exit 1 )


echo "   [second compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

