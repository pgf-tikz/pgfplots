#!/bin/bash

PDFFILE="$1"
METRIC_FILE="$2"
DIFF_IMAGE="$METRIC_FILE.png"

if [ ! -f references/$PDFFILE ]; then 
	echo "There is no reference solution for $PDFFILE. ";
	echo "Please call 'make references'.";
	exit 1;
fi

# this activates math mode in bash--and thus trimming: 
PAGES=$((`pdfinfo $PDFFILE | grep 'Pages:' | cut -c 7-`));

if [ $PAGES -eq 1 ]; then 
	echo "Comparing $PDFFILE in 1-page-mode ... "; 
	echo "compare -metric MAE $PDFFILE references/$PDFFILE $DIFF_IMAGE 2>$METRIC_FILE"; 
	compare -metric MAE $PDFFILE references/$PDFFILE $DIFF_IMAGE 2>$METRIC_FILE; 
else 
	echo "Comparing $PDFFILE in multi-page-mode APPEND mode for the $PAGES pages ... "; 
	echo "convert $PDFFILE -append $PDFFILE.png"; 
	convert $PDFFILE -append $PDFFILE.png || exit 1; 
	if [ "references/$PDFFILE" -nt "references/$PDFFILE.png" ]; then 
		echo "convert references/$PDFFILE -append references/$PDFFILE.png"; 
		convert references/$PDFFILE -append references/$PDFFILE.png || exit 1; 
	fi; 
	echo "compare -metric MAE $PDFFILE.png references/$PDFFILE.png $DIFF_IMAGE 2>$METRIC_FILE"; 
	compare -metric MAE $PDFFILE.png references/$PDFFILE.png $DIFF_IMAGE 2>$METRIC_FILE; 
fi; 
if [ $? -ne 0 ]; then 
	# error recovery:
	cat $METRIC_FILE; 
	rm $METRIC_FILE; 
	exit 1; 
fi
