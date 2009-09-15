#!/bin/sh
#
# A scripts which assembles a TDS complaient archive
# ../pgfplots.tgz
# ../pgfplots.zip
# assuming that pgfplots is in  '../pgfplots'
#
# This script is NOT part of the final pgfplots release.

cd `dirname $0`/..
rm -f pgfplots.tgz
tar czf pgfplots.tgz \
		 --dereference \
		 --exclude='.*.sw?' \
		 --exclude='*.aux' \
		 --exclude='*.log' \
		 --exclude='*.toc' \
		 --exclude='*.ilg' \
		 --exclude='*.ind' \
		 --exclude='*.dvi' \
		 --exclude='*.blg' \
		 --exclude='potentialauthors.txt' \
		 --exclude='pgfplots/doc/latex/pgfplots/gnuplot/*' \
		 --exclude='pgfplots/doc/latex/pgfplots/gallery' \
		 --exclude='pgfplots/generic/pgfplots/oldpgfcompatib/generatesymlinks.sh' \
		 --exclude='pgfplotstest.pdf' \
		 --exclude='pgfmathlogtest.pdf' \
		 --exclude='numtabletest.pdf' \
		 --exclude='liststructuretest.pdf' \
		 --exclude='pgfkeysadditiontest.pdf' \
		 --exclude='createTDSzipfile.sh' \
		 --exclude='*.bbl' \
		 --exclude='*.out' \
		 --exclude='*.idx' \
		 --exclude='*.pgf' \
		 --exclude='*.tmp' \
		 --exclude='.*' \
		 --exclude='.cvsignore' \
		 --exclude='*.mp' \
		 --exclude='*.tui' \
		 --exclude='*.tuo' \
		 --exclude='*~' \
		 --exclude='CVS' \
		pgfplots  \
		|| exit 1

echo "Re-ordering directory structure ... "
DIR=`pwd`

# unpack into $TEMP :
TEMP=/tmp/pgfplots.tmp
rm -fr $TEMP
mkdir -p $TEMP
cd $TEMP || exit 1
tar xzf $DIR/pgfplots.tgz || exit 1
rm $DIR/pgfplots.tgz

cd pgfplots || exit 1
echo "entering `pwd`"

# reorder to get a good TDS:

# 0.: copy README to doc
mkdir -p doc/generic/pgfplots || exit 1
cp README doc/generic/pgfplots || exit 1

# 1. create the 'tex/' tree:
mkdir tex || exit 1 
mv plain generic latex context tex/ || exit 1

# 2. I misunderstood the 'source' tree.
# So: shuffle this around:
for A in latex context; do
	case $A in
		context)
			TARGET=source/context/third/pgfplots;;
		*)	
			TARGET=source/$A/pgfplots;;
	esac
	mkdir -p $TARGET || exit 1
	mv source/pgfplots/$A/* $TARGET || exit 1
	rmdir source/pgfplots/$A || exit 1
	cd $TARGET || exit 1
	zip -q -m -r pgfplotstests.zip . || exit 1
	cd - 1>/dev/null
done
rmdir source/pgfplots || exit 1

# 3. re-create archives (zip and tgz).
zip -q -r pgfplots.zip . || exit 1
tar czf pgfplots.tgz --exclude pgfplots.zip --exclude pgfplots.tgz . || exit 1

# 4. move archives into the original directory.
mv pgfplots.{tgz,zip} $DIR/ || exit 1
cd $DIR
echo "entering `pwd`"


# 5. cleanup
rm -fr $TEMP

# 6. show files
echo "Showing archive contents ..."
tar tzf pgfplots.tgz

find `pwd` -maxdepth 1 \( -name pgfplots.zip -o -name pgfplots.tgz \) -ls
