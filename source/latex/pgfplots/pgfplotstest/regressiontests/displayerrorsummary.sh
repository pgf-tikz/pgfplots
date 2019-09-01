#!/bin/bash

ERROR_DIFFS=$(ls *.diff.png)
DIR="references"

for A in $ERROR_DIFFS; do
	LOG=${A%%.diff.png}.log
	REFLOG=$DIR/$LOG

	if [ -s "$A" ]; then
		echo "Pixel difference : $A";
	else
		IDENTIFIED=0
		if [ -f "$REFLOG" ]; then
			grep -q "Fatal error" $REFLOG
			if [ $? -eq 0 ]; then
				echo "Compile reference: $REFLOG";
				IDENTIFIED=1
			fi
		fi

		if [ -f "$LOG" ]; then
			grep -q "Fatal error" $LOG
			if [ $? -eq 0 ]; then
				echo "Compile actual   : $LOG";
				IDENTIFIED=1
			fi
		fi

		if [ $IDENTIFIED -eq 0 ]; then
			echo "Unknown issue   : $A";
		fi
	fi
done

