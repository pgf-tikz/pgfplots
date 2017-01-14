#!/bin/bash

PGFDIR=~/code/tex/pgf/

HEADER='%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This file is a copy of some part of PGF/Tikz.
%%% It has been copied here to provide :
%%%  - compatibility with older PGF versions
%%%  - availability of PGF contributions by Christian Feuersaenger
%%%    which are necessary or helpful for pgfplots.
%%%
%%% For reasons of simplicity, I have copied the whole file, including own contributions AND
%%% PGF parts. The copyrights are as they appear in PGF.
%%%
%%% Note that pgfplots has compatible licenses.
%%%
%%% This copy has been modified in the following ways:
%%%  - nested \input commands have been updated
%%%
%
% Support for the contents of this file will NOT be done by the PGF/TikZ team.
% Please contact the author and/or maintainer of pgfplots (Christian Feuersaenger) if you need assistance in conjunction
% with the deployment of this patch or partial content of PGF. Note that the author and/or maintainer of pgfplots has no obligation to fix anything:
% This file comes without any warranty as the rest of pgfplots; there is no obligation for help.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'

HEADER="$HEADER\n%%% Date of this copy: `date` %%%\n\n\n"

	#--------------------------------------------------
	# $PGFDIR/generic/pgf/utilities/pgfkeysfiltered.code.tex  \
	# $PGFDIR/generic/pgf/utilities/pgfkeys.code.tex  \
	# $PGFDIR/generic/pgf/libraries/pgflibraryfpu.code.tex \
	# $PGFDIR/generic/pgf/math/pgfmathfloat.code.tex \
	# $PGFDIR/generic/pgf/libraries/pgflibraryplothandlers.code.tex \
	# $PGFDIR/generic/pgf/basiclayer/pgfcoreexternal.code.tex \
	# $PGFDIR/generic/pgf/basiclayer/pgfcorescopes.code.tex \
	# $PGFDIR/generic/pgf/basiclayer/pgfcorelayers.code.tex \
	# $PGFDIR/latex/pgf/frontendlayer/libraries/tikzlibraryexternal.code.tex \
	# $PGFDIR/latex/pgf/utilities/tikzexternal.sty \
	# $PGFDIR/generic/pgf/frontendlayer/tikz/libraries/tikzexternalshared.code.tex \
	# $PGFDIR/generic/pgf/utilities/pgfutil-common-lists.tex \
	# $PGFDIR/generic/pgf/libraries/pgflibraryfillbetween.code.tex \
	#--------------------------------------------------
FILES=(\
	`find $PGFDIR/latex/pgf/doc -name '*.tex'`\
	$PGFDIR/generic/pgf/libraries/pgflibraryfpu.code.tex \
	$PGFDIR/generic/pgf/math/pgfmathfloat.code.tex \
)
for A in "${FILES[@]}"; do
	echo "creating compatibility version for `basename $A` ... "
	echo -e "$HEADER" | \
		cat - "$A" | \
		sed 's/\\input \(pgf\|tikz\)\(.*\)\.code\.tex/\\input pgfplotsoldpgfsupp_\1\2.code.tex/' \
		> pgfplotsoldpgfsupp_`basename $A` \
		|| exit 1
done

