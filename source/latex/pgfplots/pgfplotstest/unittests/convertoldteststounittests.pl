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


$#ARGV >= 0 or die('expected INFILE[s].');

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

	if ( ($srcFile =~ /axislines\.tex/) )
	{
		$autoheaders .= '
\pgfplotsset{xlabel=$x$,ylabel=$y$}

\pgfplotsset{
	separate axis line style/.style={
		separate axis lines,
		axis line style={-stealth,thick},
		x axis line style={green},
		y axis line style={red},
	}
}


\def\smallplotstest{%
	\addplot[smooth,blue,mark=*] coordinates {
		(-1,	1)
		(-0.75,	0.5625)
		(-0.5,	0.25)
		(-0.25,	0.0625)
		(0,		0)
		(0.25,	0.0625)
		(0.5,	0.25)
		(0.75,	0.5625)
		(1,		1)
	};
}

\def\smallplotstestyoffset{%
\addplot[smooth,blue,mark=*] coordinates {
	(-1,	11)
	(-0.75,	10.5625)
	(-0.5,	10.25)
	(-0.25,	10.0625)
	(0,		10)
	(0.25,	10.0625)
	(0.5,	10.25)
	(0.75,	10.5625)
	(1,		11)
};
}

\def\smallplotstestyoffsetneg{%
\addplot[smooth,blue,mark=*] coordinates {
	(-1,	-11)
	(-0.75,	-10.5625)
	(-0.5,	-10.25)
	(-0.25,	-10.0625)
	(0,		-10)
	(0.25,	-10.0625)
	(0.5,	-10.25)
	(0.75,	-10.5625)
	(1,		-11)
};
}

\def\smallplotstestxoffset{%
\addplot[smooth,blue,mark=*] coordinates {
	(9,	1)
	(9.25,	0.5625)
	(9.5,	0.25)
	(9.75,	0.0625)
	(10,		0)
	(10.25,	-0.0625)
	(10.5,	-0.25)
	(10.75,	-0.5625)
	(11,		-1)
};
}

\def\smallplotstestxoffsetneg{%
\addplot[smooth,blue,mark=*] coordinates {
	(-9,	1)
	(-9.25,	0.5625)
	(-9.5,	0.25)
	(-9.75,	0.0625)
	(-10,		0)
	(-10.25,	-0.0625)
	(-10.5,	-0.25)
	(-10.75,	-0.5625)
	(-11,		-1)
};
}
';
	}
	if ( ($srcFile =~ /axislines.3d/) )
	{
		$autoheaders .= '
\pgfplotsset{
	samples=5,
	domain=-4:4,
	xtick=data,
	ytick=data,
%	ztick=data,
}
';

	}


	@matches = ( $content =~ m/\s*\\begin{tikzpicture}.*?\\end{tikzpicture}/gs );
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

		$autoheaders_q = $autoheaders;
		$i++;
		$outfile = $OUTPREFIX."_".$srcDisplayName."_".($q).".tex";
# print "$i PREFIX: ".$prefix."\n";
# print "$i : ".$match."\n\n";
# next;

		if ( $match =~ /\\smallplotstest/ )
		{
			$autoheaders_q .= '
\def\smallplotstest{%
	\addplot[smooth,blue,mark=*] coordinates {
		(-1,	1)
		(-0.75,	0.5625)
		(-0.5,	0.25)
		(-0.25,	0.0625)
		(0,		0)
		(0.25,	0.0625)
		(0.5,	0.25)
		(0.75,	0.5625)
		(1,		1)
	};
}
';
		}
		if ( $match =~ /\\loglogtestplot/ )
		{
			$autoheaders_q .= '
\def\loglogtestplot{
	\addplot plot coordinates {
		(5,	8.311600e-02)
		(17,	2.546856e-02)
		(49,	7.407153e-03)
		(129,	2.101922e-03)
		(321,	5.873530e-04)
		(769,	1.622699e-04)
		(1793,	4.442489e-05)
		(4097,	1.207141e-05)
		(9217,	3.261015e-06)
	};
	\addlegendentry{$d=2$}

	\addplot plot coordinates {
		(7,	8.471784e-02)
		(31,	3.044093e-02)
		(111,	1.022145e-02)
		(351,	3.303463e-03)
		(1023,	1.038865e-03)
		(2815,	3.196465e-04)
		(7423,	9.657898e-05)
		(18943,	2.873391e-05)
		(47103,	8.437499e-06)
	};
	\addlegendentry{$d=3$}
}%
';
		}
		if ( $match =~ /\\DoPlot/ )
		{
			$autoheaders_q .= '
\def\DoPlot{%
  \addplot+[no marks] expression[domain=1e1:1e5] { x^(.3) * (1 + 1e3*x^(-1)) / (1 + .5e3*x^(-1.3)) };
}
';
		}
		if ( $match =~ /\\manylogplots/ )
		{
			$autoheaders_q .= '
\long\def\manylogplotsnolegend{%
	\addplot plot coordinates {
		(5,		8.312e-02)
		(17,	2.547e-02)
		(49,	7.407e-03)
		(129,	2.102e-03)
		(321,	5.874e-04)
		(769,	1.623e-04)
		(1793,	4.442e-05)
		(4097,	1.207e-05)
		(9217,	3.261e-06)
	};

	\addplot plot coordinates {
		(7,		8.472e-02)
		(31,	3.044e-02)
		(111,	1.022e-02)
		(351,	3.303e-03)
		(1023,	1.039e-03)
		(2815,	3.196e-04)
		(7423,	9.658e-05)
		(18943,	2.873e-05)
		(47103,	8.437e-06)
	};

	\addplot plot coordinates {
		(9,	7.881e-02)
		(49,	3.243e-02)
		(209,	1.232e-02)
		(769,	4.454e-03)
		(2561,	1.551e-03)
		(7937,	5.236e-04)
		(23297,	1.723e-04)
		(65537,	5.545e-05)
		(178177,	1.751e-05)
	};

	\addplot plot coordinates {
		(11,	6.887e-02)
		(71,	3.177e-02)
		(351,	1.341e-02)
		(1471,	5.334e-03)
		(5503,	2.027e-03)
		(18943,	7.415e-04)
		(61183,	2.628e-04)
		(187903,	9.063e-05)
		(553983,	3.053e-05)
	};

	\addplot plot coordinates {
		(13,	5.755e-02)
		(97,	2.925e-02)
		(545,	1.351e-02)
		(2561,	5.842e-03)
		(10625,	2.397e-03)
		(40193,	9.414e-04)
		(141569,	3.564e-04)
		(471041,	1.308e-04)
		(1496065,	4.670e-05)
	};
	\legend{$d=2$\\\\$d=3$\\\\$d=4$\\\\$d=5$\\\\$d=6$\\\\}
}%

\def\manylogplots{%
	\manylogplotsnolegend
	\legend{$d=2$\\\\$d=3$\\\\$d=4$\\\\$d=5$\\\\$d=6$\\\\}
}%
';
		}

		$generated = "";
		$generated .= $header;
		$generated .= $autoheaders_q;
		$generated .= "\n\\begin{document}\n";
		$generated .= $match;
# $generated .= "\n\n";
# $match =~ s/\\begin{axis}\[/\\begin{axis}[separate axis line style,/g;
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
