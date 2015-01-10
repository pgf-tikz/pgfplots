#!/bin/bash
# it generates tex/generic/pgfplots/pgfplots.revision.tex which, in turn, will be loaded
# by pgfplots.sty
#
# The resulting macros define the current version of pgfplots.

LATEST_TAG=`git describe --abbrev=0 --tags`
REVISION=`git describe --tags HEAD`


rm -f tex/generic/pgfplots/pgfplots.revision.tex
echo '\begingroup' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\-=12' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\/=12' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\.=12' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\:=12' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\+=12' >> tex/generic/pgfplots/pgfplots.revision.tex
echo '\catcode`\-=12' >> tex/generic/pgfplots/pgfplots.revision.tex

# this is the REVISION, i.e. the unique hash of the changeset.
echo '\gdef\pgfplotsrevision{'"$REVISION}" >> tex/generic/pgfplots/pgfplots.revision.tex

# this is the public version name. It corresponds to the latest tag name in the git repo.
echo '\gdef\pgfplotsversion{'"$LATEST_TAG}" >> tex/generic/pgfplots/pgfplots.revision.tex

# this is the commit date of the latest tag, i.e. the date when \pgfplotsversion has been committed.
# It is NOT the date of \pgfplotsrevision.
echo -n '\gdef\pgfplotsversiondatetime{' >> tex/generic/pgfplots/pgfplots.revision.tex
git log -n 1 "$LATEST_TAG" --pretty=format:"%ci" >> tex/generic/pgfplots/pgfplots.revision.tex
echo '}' >>  tex/generic/pgfplots/pgfplots.revision.tex

echo -n '\gdef\pgfplotsrevisiondatetime{' >> tex/generic/pgfplots/pgfplots.revision.tex
git log -n 1 "$REVISION" --pretty=format:"%ci" >> tex/generic/pgfplots/pgfplots.revision.tex
echo '}' >>  tex/generic/pgfplots/pgfplots.revision.tex

# convert to latex format YYYY/MM/DD :
echo '\gdef\pgfplots@glob@TMPa#1-#2-#3 #4\relax{#1/#2/#3}' >>  tex/generic/pgfplots/pgfplots.revision.tex
echo '\xdef\pgfplotsversiondate{\expandafter\pgfplots@glob@TMPa\pgfplotsversiondatetime\relax}' >>  tex/generic/pgfplots/pgfplots.revision.tex
echo '\xdef\pgfplotsrevisiondate{\expandafter\pgfplots@glob@TMPa\pgfplotsrevisiondatetime\relax}' >>  tex/generic/pgfplots/pgfplots.revision.tex
echo '\endgroup' >> tex/generic/pgfplots/pgfplots.revision.tex
exit 0
