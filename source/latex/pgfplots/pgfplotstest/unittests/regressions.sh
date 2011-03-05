#!/bin/sh


PROBLEMS="`find . -maxdepth 1 -name "*.diff.png"`"
for A in $PROBLEMS; do
	ACTUAL=${A%%.diff.png}.pdf
	EXPECTED=references/$ACTUAL
	echo "cycling through diff($A) $ACTUAL $EXPECTED ..."
	display -delay 1 $A $ACTUAL $EXPECTED
done
	
