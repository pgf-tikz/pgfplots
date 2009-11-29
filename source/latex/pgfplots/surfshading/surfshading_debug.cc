// I wrote this file to find a bug in the shader=interp  output.
// 
// Since it might be handy later, I included it into the git repository.
//
// Its more or less hackery! Handle at own risk.
//
// Use 
//
// vim -b <result.pdf>
// and
// set statusline=%<#%n:%f %h%m%r%=%-14.(%l,%c%V byte %o '%B' ('%b')%) %P
// (I suppose the 'byte %o' is the relevant one) to find the offsets.
// Or use a hex editor.
//
// compile with 
// g++ <file>.cc
//
// Also enable the \message's in the surf shading .code.tex file.
//
// Ah -- use 
// \pdfcompresslevel=0
// for the test .tex file!
#include <iostream>
#include <fstream>
#include <algorithm>
#include <limits>
#include <assert.h>

using namespace std;

int main(int argc, char** argv)
{
	string buf;
	string buf2;
	buf.resize(100000);
	buf2.resize(100000);

	string file = "surfshading_debug.pdf";
	ifstream f(file.c_str());
	if( !f ) {
		cerr <<"laden ging nich!" << endl;
		return 1;
	}

	size_t BitsPerCoordinate = 24;
	size_t BitsPerComponent = 16;
	size_t bytesPerCoord = BitsPerCoordinate/8;
	size_t bytesPerComponent = BitsPerComponent/8;

	size_t BINARY_START=0;
	size_t numPoints=0;
	size_t verticesPerRow = 0;
	if( file == "surfshading_debug.pdf" ) {
		BINARY_START = 518;
		numPoints = 100;
		verticesPerRow = 10;

	} else {
		cerr << "don't know BINARY_START offset for \"" << file << "\". hardcode it here." << endl;
		return 1;
	}
	f.read( &buf[0], BINARY_START );

	if( !f ) {
		cerr << "lesen ging nich! "<<endl;
		return 1;
	}

	std::cout.write( &buf[0], BINARY_START ) << std::endl;

	int i = 1;
	std::copy( (char*) &i, (char*)&i +sizeof(int), &buf2[0]);

	std::cout << "sizeof(unsigned int) = "  << sizeof(unsigned int) << "; sizeof(unsigned short) = " << sizeof(unsigned short) << ";" << endl;
	std::cout << "1 in binary is ";;
	std::cout.write( &buf2[0],4 );
	std::cout << std::endl;

	cout.precision(16);

	size_t LENGTH = numPoints * (2*bytesPerCoord + bytesPerComponent);
	f.read( &buf[0], LENGTH );
	size_t off = 0;
	double xmin = -16383.999992;
	double xmax = 16384;
	double ymin = -16383.999992;
	double ymax = 16384;
	double cmin = 0;
	double cmax = 1;
	size_t point = 0;


	cout << "assuming\n"
		"Length            = " << LENGTH << "\n"
		"BitsPerCoordinate = " << BitsPerCoordinate << "\n"
		"BitsPerComponent  = " << BitsPerComponent << "\n"
		"bytesPerCoord     = " << bytesPerCoord << "\n"
		"bytesPerComponent = " << bytesPerComponent << "\n";

	assert( bytesPerCoord < sizeof(size_t) );// might need a 64 bit machine. ..
	size_t x_encoded_MAX = (size_t(1) << BitsPerCoordinate) -1;
	size_t y_encoded_MAX = (size_t(1) << BitsPerCoordinate) -1;
	size_t c_encoded_MAX = (size_t(1) << BitsPerComponent) -1;
	cout << 
		"x_encoded_MAX = " <<x_encoded_MAX << "\n"
		"y_encoded_MAX = " <<y_encoded_MAX << "\n"
		"c_encoded_MAX = " <<c_encoded_MAX << "\n"
		<< flush;


	while( off < LENGTH ) {
		for( size_t i = 0; i<verticesPerRow; ++i, ++point ) {
			unsigned int xi = 0;
			unsigned int yi = 0;
			unsigned short ci = 0;
			std::cout << "DECODE point " << point << "; col " << i << " \n(";
			std::cout.write( &buf[off], 2*bytesPerCoord + bytesPerComponent );
			std::cout << ")\n yields\n";
			// input: big endian; output: little endian.
			std::reverse_copy( &buf[off], &buf[off+bytesPerCoord], (char*) (&xi) ); off+=bytesPerCoord;
			std::reverse_copy( &buf[off], &buf[off+bytesPerCoord], (char*) (&yi) ); off+=bytesPerCoord;
			std::reverse_copy( &buf[off], &buf[off+bytesPerComponent], (char*) (&ci) ); off+=bytesPerComponent;
			double x = xmin + double(xi)*(xmax-xmin)/x_encoded_MAX;
			double y = ymin + double(yi)*(ymax-ymin)/y_encoded_MAX;
			double c = cmin + double(ci)*(cmax-cmin)/c_encoded_MAX;
			double cc = 0. + double(ci)*1000./c_encoded_MAX;
			std::cout << 
					"\tx = " << x << ";\n"
					"\ty = " << y << ";\n"
					"\tc = " << c << "\t(=" <<cc << "\tin [0,1000]);\n";
			if( x < xmin ) { cerr << x << " < xmin ! " << std::endl; return 1; }
			if( y < ymin ) { cerr << y << " < ymin ! " << std::endl; return 1; }
			if( c < cmin ) { cerr << c << " < cmin ! " << std::endl; return 1; }
			if( x > xmax ) { cerr << x << " > xmax ! " << std::endl; return 1; }
			if( y > ymax ) { cerr << y << " > ymax ! " << std::endl; return 1; }
			if( c > cmax ) { cerr << c << " > cmax ! " << std::endl; return 1; }
			std::cout << endl;
		}
	}
	cout << " All points are in their respective number ranges." << endl;
	
	
	return 0;
}

