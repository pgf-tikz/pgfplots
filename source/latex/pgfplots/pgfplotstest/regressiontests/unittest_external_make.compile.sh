# cause nonzero exit status to fail the script:
set -e
rm -f $@.dat
echo "0 0" >> $@.dat
echo "1 1" >> $@.dat
echo "2 2" >> $@.dat
`dirname $0`/compile_external_make.sh "$@" || exit 1

grep -q '.dat' $@-figure0.dep || ( rm -f $@.pdf; echo "FAILURE: the .dep file does not contain the dependency."; exit 1 )
grep -q '.md5' $@.makefile || ( rm -f $@.pdf; echo "FAILURE: the makefile does not contain the dependency for MD5."; exit 1 )

echo "   [changing file $@.dat]"
echo "3 3" >> $@.dat

echo "   [first compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

echo "   [makefile for images...]"
make -f "$@.makefile" || ( rm -f $@.pdf; exit 1 )

echo "   [second compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

grep -q '.dat' $@-figure0.dep || ( rm -f $@.pdf; echo "FAILURE: the .dep file does not contain the dependency."; exit 1 )
grep -q '.md5' $@.makefile || ( rm -f $@.pdf; echo "FAILURE: the makefile does not contain the dependency for MD5."; exit 1 )
