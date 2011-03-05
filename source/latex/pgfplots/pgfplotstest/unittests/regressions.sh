#!/bin/bash


PROBLEMS="`find . -maxdepth 1 -name "*.diff.png"`"
echo "Found regressions in the following files:"
echo ${PROBLEMS//.diff.png/.tex}
echo "I will now display each of them."
	
for A in $PROBLEMS; do
	ACTUAL=${A%%.diff.png}.pdf
	EXPECTED=references/$ACTUAL
	echo "cycling through diff($A) $ACTUAL $EXPECTED ..."
	display -delay 1 $A $ACTUAL $EXPECTED || break
done

