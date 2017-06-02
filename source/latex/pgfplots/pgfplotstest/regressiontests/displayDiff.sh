#!/bin/bash
# 
# USAGE:
# displayDiff.sh unittest_1.diff.png

GENERATED_PAIRED_VIEW=1

SELECTED_PAGE=-1

if [ $# -ge 2 ]; then
	SELECTED_PAGE=$2
fi

if [ $# -ge 1 ]; then
	DIFF_PNG=$1
else
	echo "USAGE:"
	echo "$0 <diff-png>"
	echo "$0 <diff-png> <selectedpage>"
	echo "For example"
	echo "$0 unittest_1.diff.png"
	echo "$0 unittest_1.diff.png 2"
	exit 1
fi

ACTUAL=${DIFF_PNG%%.diff.png}.pdf
EXPECTED=references/$ACTUAL
echo "display $DIFF_PNG"
display $DIFF_PNG &

echo "cycling through diff($DIFF_PNG) $ACTUAL $EXPECTED (selected page $SELECTED_PAGE)..."

PAGES=$((`pdfinfo $ACTUAL | grep 'Pages:' | cut -c 7-`));

if [ $SELECTED_PAGE -ge 1 -a $PAGES -gt 1 ]; then
	DIFF_PNG=/tmp/displayDiff.diff$SELECTED_PAGE.png
	echo "recomputing diff for selected page $SELECTED_PAGE / $PAGES ..."
	./pdfdiff.sh -v $ACTUAL ${DIFF_PNG%%.png} $SELECTED_PAGE || exit 1
fi

PAIRED_IMAGES=""
if [ $GENERATED_PAIRED_VIEW -eq 1 ]; then
	for ((I=0;I<$PAGES;++I)); do
		P=$((I+1))
		if [ $SELECTED_PAGE -eq -1 -o $SELECTED_PAGE -eq $P ]; then
			ACTUAL_I=/tmp/displayDiff.actual$I.png 
			EXPECTED_I=/tmp/displayDiff.expected$I.png 
			convert $ACTUAL\[$I\] -draw "text 100,100 \"$ACTUAL (page $P/$PAGES)\"" $ACTUAL_I || exit 1
			convert $EXPECTED\[$I\] -draw "text 100,100 \"$EXPECTED (page $P/$PAGES)\"" $EXPECTED_I|| exit 1
			PAIRED_IMAGES="$PAIRED_IMAGES $ACTUAL_I $EXPECTED_I"
		fi
	done
else
	PAIRED_IMAGES="$ACTUAL $EXPECTED"
fi
display -delay 1 -loop 3 $PAIRED_IMAGES || break
