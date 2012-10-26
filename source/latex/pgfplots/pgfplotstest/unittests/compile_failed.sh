#!/bin/sh

TEX_FILE=$1
PDF_FILE=$2
MESSAGE=$3

LOG_FILE=${PDF_FILE%%.pdf}.log
DIFF_PNG_FILE=${TEX_FILE%%.tex}.diff.png
DIFF_PNG_FILE_FIXIT=${TEX_FILE%%.tex}.FIXIT.diff.png

echo "COMPILATION FAILED: $LOG_FILE $3";
rm -f $2;
touch $DIFF_PNG_FILE; 

grep -q "\\FIXIT" "$TEX_FILE"
if [ $? -eq 0 ]; then
	echo "FIXIT - test case marked as broken.";
	touch $DIFF_PNG_FILE_FIXIT; 
fi

exit 1
