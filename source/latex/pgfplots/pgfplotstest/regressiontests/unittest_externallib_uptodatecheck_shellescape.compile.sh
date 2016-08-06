# cause nonzero exit status to fail the script:
set -e

INFILE=$@.tex
if [ ! -f $INFILE ]; then
	INFILE=../$INFILE
fi
if [ -z "$EXECUTABLE" ]; then
	EXECUTABLE="pdflatex -interaction batchmode -halt-on-error -shell-escape "
fi

sed 's/REPLACEMEHEREUSINGTHESCRIPT/draw (0,0) -- (1,0);/' < $INFILE > $@.generated.tex
$EXECUTABLE "$@.generated.tex" 

cat $@.generated-figure0.md5
grep -q 'D5ECA2A7B91E5F93BD67925A7DF37CFF' $@.generated-figure0.md5 || ( rm -f $@.pdf; echo "FAILURE: the .md5 file does not contain the expected MD5."; exit 1 )

echo "   [changing file $@.generated.tex]"
sed 's/REPLACEMEHEREUSINGTHESCRIPT/draw (0,0) -- (1,0); \\draw (0,0) -- (0,1);/' < $INFILE > $@.generated.tex

$EXECUTABLE "$@.generated.tex" 
grep -q '735BA88FF23AC7168AEBD4CE90CC65E7' $@.generated-figure0.md5 || ( rm -f $@.pdf; echo "FAILURE: the .md5 file does not contain the expected MD5."; exit 1 )

cp $@.generated.pdf $@.pdf
cat $@.generated-figure0.md5
