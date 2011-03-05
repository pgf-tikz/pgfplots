#!/bin/bash
# USAGE: 
# pdfdiff.sh <pdffile> <output-diff-file>
#
# It then compares <pdffile> with references/<pdffile> and writes the result to <output-diff-file>.
# If the <output-diff-file> contains only "0 (0)", the images are equal on pixel-level.
# If they are not equal, the script also generates <output-diff-file>.png containing the references.
#
# If supports multi-page pdf files.

PDFFILE="$1"
METRIC_FILE="$2"
DIFF_IMAGE="$METRIC_FILE.png"

VERBOSE=0

function log()
{
	if [ $VERBOSE -eq 1 ]; then
		echo $*
	fi
}

if [ ! -f references/$PDFFILE ]; then 
	echo "There is no reference solution for $PDFFILE. ";
	echo "Please call 'make references'.";
	exit 1;
fi

# this activates math mode in bash--and thus trimming: 
PAGES=$((`pdfinfo $PDFFILE | grep 'Pages:' | cut -c 7-`));

if [ $PAGES -eq 1 ]; then 
	log "Comparing $PDFFILE in 1-page-mode ... "; 
	log "compare -metric MAE $PDFFILE references/$PDFFILE $DIFF_IMAGE 2>$METRIC_FILE"; 
	compare -metric MAE $PDFFILE references/$PDFFILE $DIFF_IMAGE 2>$METRIC_FILE; 
else 
	# this is more complicated because the 'compare' tools does not really support multi-page documents 
	# (it collapses all pages to one and the comparison fails).
	# So: make one HUGE image by appending all pages:
	log "Comparing $PDFFILE in multi-page-mode APPEND mode for the $PAGES pages ... "; 
	log "convert $PDFFILE -append $PDFFILE.png"; 
	convert $PDFFILE -append $PDFFILE.png || exit 1; 
	if [ "references/$PDFFILE" -nt "references/$PDFFILE.png" ]; then 
		log "convert references/$PDFFILE -append references/$PDFFILE.png"; 
		convert references/$PDFFILE -append references/$PDFFILE.png || exit 1; 
	fi; 
	log "compare -metric MAE $PDFFILE.png references/$PDFFILE.png $DIFF_IMAGE 2>$METRIC_FILE"; 
	compare -metric MAE $PDFFILE.png references/$PDFFILE.png $DIFF_IMAGE 2>$METRIC_FILE; 
fi; 
if [ $? -ne 0 ]; then 
	# error recovery:
	cat $METRIC_FILE; 
	rm $METRIC_FILE; 
	exit 1; 
fi
