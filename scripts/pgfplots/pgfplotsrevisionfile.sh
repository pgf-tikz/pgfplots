#!/bin/sh

echo '\def\pgfplotsrevision{%' > tex/generic/pgfplots/pgfplots.revision.tex
git rev-parse HEAD >> tex/generic/pgfplots/pgfplots.revision.tex
echo '}' >>  tex/generic/pgfplots/pgfplots.revision.tex
