#!/usr/bin/perl -w
#
# A script 
# convertoldteststounittests.pll <PREFIX> <htmlfilename> <INFILES> 
# which 
# - processes every input .tex file
# - extracts all tikzpicture-environments which are inside of a codeexample
# - generates <PREFIX>_<index>.tex
# - writes an index-html file into <htmlfilename>
#
# Furthermore, it processes every LaTeX Comment which is DIRECTLY before the codeexample to export:
#
# % \usepackage{array}
# \begin{codeexample}[]
# \begin{tikzpicture}
# ...
#
# will be interpreted as required preamble-information for the gallery. Thus,
# \usepackage{array} will be included into the particular output file.
# 
# See the associated Makefile which also exports each thing into pdf and png.


$#ARGV > 0 or die('expected INFILE[s].');

$OUTPREFIX="unittest";

$header = 
'\documentclass{article}
% translate with >> pdflatex -shell-escape <file>

% This file is used as unit test for pgfplots, copyright by Christian Feuersaenger.
% 
% See
%   http://pgfplots.sourceforge.net/pgfplots.pdf
% for pgfplots.
%
% Any required input files (for <plot table> or <plot file> or the table package) can be downloaded
% at
% http://www.ctan.org/tex-archive/graphics/pgf/contrib/pgfplots/doc/latex/
% and
% http://www.ctan.org/tex-archive/graphics/pgf/contrib/pgfplots/doc/latex/plotdata/

\usepackage{pgfplots}
\pgfplotsset{compat=newest}

\pagestyle{empty}
';

$i = 0;

for($j = 0; $j<=$#ARGV; ++$j ) {
	$srcFile = $ARGV[$j];
	$srcDisplayName = $srcFile;
	$srcDisplayName =~ s/\.\.\/pgfplotstest\.?//;
	$srcDisplayName =~ s/\.tex//;
	$srcDisplayName =~ s/\./_/;

	open FILE,$srcFile or die("could not open ".$ARGV[$j]);
	@S = stat(FILE);
	$fileSize = $S[7];
	read(FILE,$content,$fileSize) or die("could not read everything");
	close(FILE);

	$autoheaders = '';
	$largegraphics = 0;

	@matches = ( $content =~ m/\\begin{tikzpicture}.*?\\end{tikzpicture}/gs );
	#	@matches = ( $content =~ m/(% [^\n]*\n)*\\begin{codeexample}(\[\])\n(\\begin{tikzpicture}.*?\\end{tikzpicture})/gs );

	print "Processing $srcDisplayName (".$srcFile."; ".($#matches+1)." matches)...\n";

	if( $ARGV[$j] =~ m/pgfplotstable.tex/ ) {
		$largegraphics = 1;
		$autoheaders = '
\usepackage{array}
\usepackage{colortbl}
\usepackage{booktabs}
\usepackage{eurosym}
\usepackage{amsmath}
';
	}

	for( $q=0; $q<=$#matches; $q++ ) {
		$match = $matches[$q];

		$i++;
		$outfile = $OUTPREFIX."_".$srcDisplayName."_".($q).".tex";
# print "$i PREFIX: ".$prefix."\n";
# print "$i : ".$match."\n\n";
# next;

		$generated = "";
		$generated .= $header;
		$generated .= $autoheaders;
		$generated .= "\n\\begin{document}\n";
		$generated .= $match;
		$generated .= "\n\\end{document}\n";

		$exists = 1;
		open FILE,$outfile or $exists=0;
		if ($exists)
		{
			@S = stat(FILE);
			$fileSize = $S[7];
			read(FILE,$content,$fileSize) or die("could not read everything");
			close(FILE);
			$isGenerated = ($content eq $generated);
			if (!$isGenerated)
			{
				print "$outfile has been modified already; skipping it!\n";
				next;
			}
		}
		else
		{
			#print "creating $outfile [did not exist yet]\n";
		}

		open(OUTFILE,">",$outfile) or die( "could not open $outfile for writing");
		print OUTFILE "$generated";
		close(OUTFILE);
	}

}
print "Exported ".$i." examples.\n";
exit 0;
