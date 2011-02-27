#!/bin/sh


PROBLEMS="`find . -maxdepth 1 -name "*.diff.png"`"
for A in $PROBLEMS; do
	echo "$A ..."
	display $A
done
	
