#!/usr/bin/perl -w
#
# A script 
#  extractexamples.pl <PREFIX> <htmlfilename> <INFILES> 
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


sub maskForHTML {
	my $arg = $_[0];
#	$arg =~ s/
	return $arg;
}

$#ARGV > 0 or die('expected OUTPREFIX OUTHTML INFILE[s].');

$OUTPREFIX=$ARGV[0];
$OUTHTMLNAME=$ARGV[1];

$header = 
'\documentclass{article}
% translate with >> pdflatex -shell-escape <file>

% This file is an extract of the PGFPLOTS manual, copyright by Christian Feuersaenger.
% 
% Feel free to use it as long as you cite the pgfplots manual properly.
%
% See
%   http://pgfplots.sourceforge.net/pgfplots.pdf
% for the complete manual.
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

$plotcoord_cmd='
% \addplot table[x=dof,y=L2error] {d2data.dat};
\addplot coordinates {
(5,8.312e-02)    (17,2.547e-02)   (49,7.407e-03)
(129,2.102e-03)  (321,5.874e-04)  (769,1.623e-04)
(1793,4.442e-05) (4097,1.207e-05) (9217,3.261e-06)
};

% \addplot table[x=dof,y=L2error] {d3data.dat};
\addplot coordinates{
(7,8.472e-02)    (31,3.044e-02)    (111,1.022e-02)
(351,3.303e-03)  (1023,1.039e-03)  (2815,3.196e-04)
(7423,9.658e-05) (18943,2.873e-05) (47103,8.437e-06)
};

% \addplot table[x=dof,y=L2error] {d4data.dat};
\addplot coordinates{
(9,7.881e-02)     (49,3.243e-02)    (209,1.232e-02)
(769,4.454e-03)   (2561,1.551e-03)  (7937,5.236e-04)
(23297,1.723e-04) (65537,5.545e-05) (178177,1.751e-05)
};

% \addplot table[x=dof,y=L2error] {d5data.dat};
\addplot coordinates{
(11,6.887e-02)    (71,3.177e-02)     (351,1.341e-02)
(1471,5.334e-03)  (5503,2.027e-03)   (18943,7.415e-04)
(61183,2.628e-04) (187903,9.063e-05) (553983,3.053e-05)
};

% \addplot table[x=dof,y=L2error] {d6data.dat};
\addplot coordinates{
(13,5.755e-02)     (97,2.925e-02)     (545,1.351e-02)
(2561,5.842e-03)   (10625,2.397e-03)  (40193,9.414e-04)
(141569,3.564e-04) (471041,1.308e-04) 
(1496065,4.670e-05)
};
';

$i = 0;
open OUTHTML,'>',$OUTHTMLNAME or die('could not open $OUTHTMLNAME for writing.');
print OUTHTML 
'<html>
<head>
	<link rel="stylesheet" type="text/css" href="gallery.css">
</head>
<body>
<h2>PGFPlots Gallery</h2>
<h4>The following graphics have been generated with the LaTeX Packages <a href="http://pgfplots.sourceforge.net/pgfplots.pdf">PGFPlots</a> and <a href="http://pgfplots.sourceforge.net/pgfplotstable.pdf">PGFPlotsTable</a>.</h4>
';

for($j = 2; $j<=$#ARGV; ++$j ) {
	open FILE,$ARGV[$j] or die("could not open ".$ARGV[$j]);

	@S = stat(FILE);
	$fileSize = $S[7];
	read(FILE,$content,$fileSize) or die("could not read everything");
	close(FILE);

	$autoheaders = '';
	$largegraphics = 0;

	@matches = ( $content =~ m/(% [^\n]*\n)*([^\n]*)\\begin{codeexample}(\[[^\n]*\])\n(.*?)[\n \t]*\\end{codeexample}/gs );
	#	@matches = ( $content =~ m/(% [^\n]*\n)*\\begin{codeexample}(\[\])\n(\\begin{tikzpicture}.*?\\end{tikzpicture})/gs );

	if( $ARGV[$j] =~ m/pgfplotstable.tex/ ) {
		$largegraphics = 1;
		$autoheaders = $autoheaders.'
\usepackage{pgfplotstable}
\usepackage{array}
\usepackage{colortbl}
\usepackage{booktabs}
\usepackage{eurosym}
\usepackage{amsmath}
';
	}

	@libName = ($ARGV[$j] =~ m/pgfplots\.libs\.(.*)\.tex/ );
	if ($#libName >=0 ) {
		$autoheaders = $autoheaders.'
\usepgfplotslibrary{'.$libName[0].'}
';
	}

	for( $q=0; $q<=$#matches/4; $q++ ) {
		$prefix = $matches[4*$q];
		$prefix = "" if not defined($prefix);
		next if ($prefix =~ m/NO GALLERY/);
		$prefix =~ s/% //;

		$possiblecomment = $matches[4*$q+1];
		$possiblecomment = "" if not defined($possiblecomment);
		next if ($possiblecomment =~ m/%/);

		$codeexamplearg= $matches[4*$q+2];
		$match = $matches[4*$q+3];

		# Make sure we have only "relevant" pictures:
		next if not ($match =~ m/tikzpicture.*(axis|semilogxaxis|semilogyaxis|loglogaxis).*\\addplot|pgfplotstabletypeset/s);

		# no complete examples:
		next if ($match =~ m/\\begin{document}/); 

		$match =~ s/\\plotcoords/$plotcoord_cmd/o;

		if ( ($codeexamplearg =~ m/code only/) ) {
			print OUTHTML "<div class=\"img\">\n";
			print OUTHTML "\t<div class=\"codeonly\">".maskForHTML($match)."</div>\n";
			print OUTHTML "</div>\n";

		} else {
			$outfile = $OUTPREFIX."_".($i++).".tex";
	# print "$i PREFIX: ".$prefix."\n";
	# print "$i : ".$match."\n\n";
	# next;
			open(OUTFILE,">",$outfile) or die( "could not open $outfile for writing");
			print OUTFILE $header;
			print OUTFILE $autoheaders;
			print OUTFILE "\\usepackage{pgfplotstable}\n" if ($match =~ /pgfplotstable/);
			print OUTFILE "\\usepackage{hyperref}\n" if ($match =~ /\\url/);
			print OUTFILE "\\usepackage{textcomp}\n" if ($match =~ /\\textdegree/);
			print OUTFILE "\\usepackage{listings}\n" if ($match =~ /\\lst/);
			print OUTFILE $prefix;
			print OUTFILE "\n\\begin{document}\n";
			print OUTFILE $match;
			print OUTFILE "\n\\end{document}\n";
			close(OUTFILE);

			$png = $outfile;
			$png =~ s/.tex/.png/;
			$pdf = $outfile;
			$pdf =~ s/.tex/.pdf/;
			print OUTHTML "<div class=\"img\">\n";
			if( $largegraphics ) {
				print OUTHTML "\t<span class=\"largegraphics\">\n";
				print OUTHTML "\t\t<a class=\"texlink_from_image\" href=\"".$pdf."\"><img src=\"".$png."\"/></a><br/>\n";
				print OUTHTML "\t\t<a class=\"texlink\" href=\"".$outfile."\">[.tex]</a>\n";
				print OUTHTML "\t\t<a class=\"pdflink\" href=\"".$pdf."\">[.pdf]</a>\n";
				print OUTHTML "\t</span>\n";
				print OUTHTML "\t<div class=\"codeonly\">".maskForHTML($match)."</div>\n";
				print OUTHTML "</div>\n";
			} else {
				print OUTHTML "\t<span class=\"graphics\">\n";
				print OUTHTML "\t\t<a class=\"texlink_from_image\" href=\"".$pdf."\"><img src=\"".$png."\"/></a><br/>\n";
				print OUTHTML "\t\t<a class=\"texlink\" href=\"".$outfile."\">[.tex]</a>\n";
				print OUTHTML "\t\t<a class=\"pdflink\" href=\"".$pdf."\">[.pdf]</a>\n";
				print OUTHTML "\t</span>\n";
				print OUTHTML "\t<div class=\"texsrc\">".maskForHTML($match)."</div>\n";
				print OUTHTML "</div>\n";
			}
		}
	}

}
print OUTHTML 
'</body>
</html>
';
close OUTHTML;
print "Exported ".$i." examples.\n";
exit 0;
