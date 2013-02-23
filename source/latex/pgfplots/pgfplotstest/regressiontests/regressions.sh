#!/bin/bash

ARGS=""
if [ $# -ge 1 ]; then
	ARGS="-a -name '$1'"

	echo "Using search restriction: $ARGS"
fi
PROBLEMS=`eval find . -maxdepth 1 '\(' -name '"*.diff.png"' $ARGS '\)'`
echo "Found regressions in the following files:"
echo ${PROBLEMS//.diff.png/.tex}
echo "I will now display each of them."
	
for A in $PROBLEMS; do
	echo "./displayDiff.sh $A"
	./displayDiff.sh $A
done

