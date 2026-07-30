#!/bin/bash
# USAGE: 
# pdfdiff.sh <pdffile> <output-diff-file>
#
# It then compares <pdffile> with references/<pdffile> and writes the result to <output-diff-file>.
# If the <output-diff-file> contains only "0 (0)", the images are equal on pixel-level.
# If they are not equal, the script also generates <output-diff-file>.png containing the references.
#
# If supports multi-page pdf files.

VERBOSE=0

if [ "$1" == "-v" ]; then
	VERBOSE=1
	shift
fi

PDFFILE="$1"
REFERENCE_PDFFILE="$2"
METRIC_FILE="$3"
DIFF_IMAGE="$METRIC_FILE.png"

SELECTED_PAGE=-1

if [ $# -ge 4 ]; then
	SELECTED_PAGE=$4
fi

if [ $# -lt 3 ]; then
	echo "USAGE: "
	echo "pdfdiff.sh [-v] <pdffile> <referencepdffile> <output-diff-file>"
	echo "pdfdiff.sh [-v] <pdffile> <referencepdffile> <output-diff-file> <selectedpage>"
	exit 1
fi


function log()
{
	if [ $VERBOSE -eq 1 ]; then
		echo $*
	fi
}

# Run ImageMagick 'compare' on two images and write ONLY the MAE metric
# ("<mae> (<normalized>)") to $METRIC_FILE. The Ghostscript/poppler delegates
# may print warnings to stderr (e.g. "AcroForm field 'Btn' with no AP not
# implemented") which would otherwise pollute the metric and fail the test;
# keep just the metric line. The exit code of 'compare' is preserved.
function run_compare()
{
	local raw="$METRIC_FILE.raw"
	compare -metric MAE "$1" "$2" "$DIFF_IMAGE" 2>"$raw"
	local rc=$?
	grep -oE '[-0-9.eE+]+ \([-0-9.eE+]+\)' "$raw" | tail -n1 > "$METRIC_FILE"
	rm -f "$raw"
	return $rc
}

if [ ! -f $REFERENCE_PDFFILE ]; then 
	echo "There is no reference solution for $PDFFILE. ";
	echo "Please call 'make references'.";
	exit 1;
fi

# this activates math mode in bash--and thus trimming: 
PAGES=$((`pdfinfo $PDFFILE | grep 'Pages:' | cut -c 7-`));

if [ $PAGES -eq 1 ]; then 
	log "Comparing $PDFFILE in 1-page-mode ... "; 
	log "compare -metric MAE $PDFFILE $REFERENCE_PDFFILE $DIFF_IMAGE 2>$METRIC_FILE";
	run_compare "$PDFFILE" "$REFERENCE_PDFFILE";
else 
	if [ $SELECTED_PAGE -eq -1 ]; then
		# this is more complicated because the 'compare' tools does not really support multi-page documents 
		# (it collapses all pages to one and the comparison fails).
		# So: make one HUGE image by appending all pages:
		log "Comparing $PDFFILE in multi-page-mode APPEND mode for the $PAGES pages ... "; 
		log "convert $PDFFILE -append $PDFFILE.png"; 
		convert $PDFFILE -append $PDFFILE.png || exit 1; 
		if [ "$REFERENCE_PDFFILE" -nt "$REFERENCE_PDFFILE.png" ]; then 
			log "convert $REFERENCE_PDFFILE -append $REFERENCE_PDFFILE.png"; 
			convert $REFERENCE_PDFFILE -append $REFERENCE_PDFFILE.png || exit 1; 
		fi; 
		log "compare -metric MAE $PDFFILE.png $REFERENCE_PDFFILE.png $DIFF_IMAGE 2>$METRIC_FILE";
		run_compare "$PDFFILE.png" "$REFERENCE_PDFFILE.png";
	else
		log "Comparing $PDFFILE in 1-page-mode for page $SELECTED_PAGE ... "; 
		SELECTED_PAGE_ZERO_BASED=$(($SELECTED_PAGE-1))
		log "compare -metric MAE $PDFFILE[$SELECTED_PAGE_ZERO_BASED] $REFERENCE_PDFFILE[$SELECTED_PAGE_ZERO_BASED] $DIFF_IMAGE 2>$METRIC_FILE";
		run_compare "$PDFFILE[$SELECTED_PAGE_ZERO_BASED]" "$REFERENCE_PDFFILE[$SELECTED_PAGE_ZERO_BASED]";
	fi
fi; 

# exitcode 2 means error; 1 means "not similar"
if [ $? -eq 2 ]; then 
	# error recovery:
	cat $METRIC_FILE; 
	rm $METRIC_FILE; 
	exit 1; 
fi
