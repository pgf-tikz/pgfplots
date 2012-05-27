echo "   [first compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

echo "   [makefile for images...]"
make -f "$@.makefile" || ( rm -f $@.pdf; exit 1 )

echo "   [second compile...]"
pdflatex -interaction batchmode -halt-on-error "$@" || ( rm -f $@.pdf; exit 1 )

