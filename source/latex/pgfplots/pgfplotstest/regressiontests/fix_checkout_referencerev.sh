#!/bin/bash

for A in `grep -LF . *.checkoutreferencerev.sh `; do 
	REV=`sed -ne 's/git checkout //p' < $A`; 
	if [ $? -eq 0 -a ! -z "$REV"  ]; then
		REVNORMALIZED=`git describe --tags $REV`; 
		if [ $? -eq 0 ]; then
			# echo "$A: $REV -> $REVNORMALIZED"; 
			echo "git checkout $REVNORMALIZED" > $A;
		else
			echo "FAIL for $A (git describe --tags $REV)" 1>&2
		fi 

	else
		echo "FAIL for $A (sed failed)" 1>&2
	fi
done
