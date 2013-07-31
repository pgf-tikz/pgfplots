#!/bin/bash

TMP_REPOSITORY=$1
echo "  Fixing regression in tikz.code.tex by work-around (compare 59ede5409)"

PATCHED_FILE=$TMP_REPOSITORY/tex/generic/pgfplots/pgfplots.code.tex
echo '\tikzoption{samples}{%' >> $PATCHED_FILE
echo '   \tikzset{/pgf/fpu/output format=fixed}%' >> $PATCHED_FILE
echo '  \pgfmathsetmacro\tikz@plot@samples{max(2,#1)}\expandafter\tikz@plot@samples@recalc\tikz@plot@domain\relax%' >> $PATCHED_FILE
echo '   \tikzset{/pgf/fpu/output format=float}%' >> $PATCHED_FILE
echo '}' >> $PATCHED_FILE
