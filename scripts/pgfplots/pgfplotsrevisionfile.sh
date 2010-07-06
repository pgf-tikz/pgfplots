#!/bin/sh
# invoke this file from within the following three git-hooks:
# .git/hooks/post-checkout
# .git/hooks/post-commit
# .git/hooks/post-merge
#
# it generates tex/generic/pgfplots.revision.tex which, in turn, will be loaded
# by pgfplots.sty
#
# This is optional and it doesn't hurt if you don't do it.

echo '\def\pgfplotsrevision{%' > tex/generic/pgfplots/pgfplots.revision.tex
git describe --tags HEAD >> tex/generic/pgfplots/pgfplots.revision.tex
echo '}' >>  tex/generic/pgfplots/pgfplots.revision.tex
exit 0
