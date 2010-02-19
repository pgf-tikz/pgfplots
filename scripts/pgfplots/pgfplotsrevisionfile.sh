#!/bin/sh

echo '\def\pgfplotsrevision{%' > tex/generic/pgfplots/pgfplots.revision.tex
git describe HEAD >> tex/generic/pgfplots/pgfplots.revision.tex
echo '}' >>  tex/generic/pgfplots/pgfplots.revision.tex
