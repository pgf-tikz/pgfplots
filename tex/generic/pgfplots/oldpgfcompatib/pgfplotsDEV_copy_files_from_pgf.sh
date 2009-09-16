#!/bin/sh

PGFDIR=~/code/tex/pgf_cvs/

HEADER="%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n%%% This file is part of PGF.\n%%% It has been copied here to provide both:\n%%%    compatibility with older PGF versions AND modifications contributed by Christian Feuersaenger.\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n"

echo -e "$HEADER" | cat - $PGFDIR/generic/pgf/utilities/pgfkeysfiltered.code.tex > pgfplotsoldpgfsupp_pgfkeysfiltered.code.tex || exit 1
echo -e "$HEADER" | cat - $PGFDIR/generic/pgf/utilities/pgfkeys.code.tex | sed 's/\\input pgfkeysfiltered\.code\.tex/% &/'  > pgfplotsoldpgfsupp_pgfkeys.code.tex || exit 1
echo -e "$HEADER" | cat - $PGFDIR/generic/pgf/libraries/pgflibraryfpu.code.tex > pgfplotsoldpgfsupp_pgflibraryfpu.code.tex || exit 1
echo -e "$HEADER" | cat - $PGFDIR/generic/pgf/libraries/pgflibraryplothandlers.code.tex > pgfplotsoldpgfsupp_pgflibraryplothandlers.code.tex ||exit 1
echo -e "$HEADER" | cat - $PGFDIR/generic/pgf/math/pgfmathfloat.code.tex > pgfplotsoldpgfsupp_pgfmathfloat.code.tex || exit 1
