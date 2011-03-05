#!/bin/bash
# 
# USAGE:
# displayDiff.sh unittest_1.diff.png

GENERATED_PAIRED_VIEW=1

DIFF_PNG=$1
ACTUAL=${DIFF_PNG%%.diff.png}.pdf
EXPECTED=references/$ACTUAL
echo "cycling through diff($DIFF_PNG) $ACTUAL $EXPECTED ..."

PAGES=$((`pdfinfo $ACTUAL | grep 'Pages:' | cut -c 7-`));

PAIRED_IMAGES=""
if [ $GENERATED_PAIRED_VIEW -eq 1 ]; then
	for ((I=0;I<$PAGES;++I)); do
		P=$((I+1))
		ACTUAL_I=/tmp/displayDiff.actual$I.png 
		EXPECTED_I=/tmp/displayDiff.expected$I.png 
		convert $ACTUAL\[$I\] -draw "text 100,100 \"$ACTUAL (page $P/$PAGES)\"" $ACTUAL_I || exit 1
		convert $EXPECTED\[$I\] -draw "text 100,100 \"$EXPECTED (page $P/$PAGES)\"" $EXPECTED_I|| exit 1
		PAIRED_IMAGES="$PAIRED_IMAGES $ACTUAL_I $EXPECTED_I"
	done
else
	PAIRED_IMAGES="$ACTUAL $EXPECTED"
fi
display -delay 1 $1 $PAIRED_IMAGES || break
