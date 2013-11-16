# cause nonzero exit status to fail the script:
export EXECUTABLE="lualatex -interaction batchmode -halt-on-error -shell-escape "

SCRIPT=unittest_externallib_uptodatecheck_shellescape.compile.sh
if [ -f $SCRIPT ]; then
	sh $SCRIPT "$@" ||exit 1
else
	sh ../$SCRIPT "$@" || exit 1
fi
