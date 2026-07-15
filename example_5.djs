\begingroup\efdlspecials
\isdljstrue
\makeatletter
\obeyspaces\obeylines\let^^M=\jsR%
\catcode`\"=12%
\gdef\dljsexample_5iii{%
var _thereisdjs=true;
/*********************************************************************************
 * function sprintf() - written by Kevin van Zonneveld as part of the php to javascript
 * conversion project.
 *
 * More info at: http://kevin.vanzonneveld.net/techblog/article/phpjs_licensing/
 *
 * This is version: 1.33
 * php.js is copyright 2008 Kevin van Zonneveld.
 *
 * Portions copyright Michael White (http://crestidg.com), _argos, Jonas
 * Raoni Soares Silva (http://www.jsfromhell.com), Legaev Andrey, Ates Goral
 * (http://magnetiq.com), Philip Peterson, Martijn Wieringa, Webtoolkit.info
 * (http://www.webtoolkit.info/), Carlos R. L. Rodrigues
 * (http://www.jsfromhell.com), Ash Searle (http://hexmen.com/blog/),
 * Erkekjetter, GeekFG (http://geekfg.blogspot.com), Johnny Mast
 * (http://www.phpvrouwen.nl), marrtins, Alfonso Jimenez
 * (http://www.alfonsojimenez.com), Aman Gupta, Arpad Ray
 * (mailto:arpad@php.net), Karol Kowalski, Mirek Slugen, Thunder.m, Tyler
 * Akins (http://rumkin.com), d3x, mdsjack (http://www.mdsjack.bo.it), Alex,
 * Alexander Ermolaev (http://snippets.dzone.com/user/AlexanderErmolaev),
 * Allan Jensen (http://www.winternet.no), Andrea Giammarchi
 * (http://webreflection.blogspot.com), Arno, Bayron Guevara, Ben Bryan,
 * Benjamin Lupton, Brad Touesnard, Brett Zamir, Cagri Ekin, Cord, David,
 * David James, DxGx, FGFEmperor, Felix Geisendoerfer
 * (http://www.debuggable.com/felix), FremyCompany, Gabriel Paderni, Howard
 * Yeend, J A R, Leslie Hoare, Lincoln Ramsay, Luke Godfrey, MeEtc
 * (http://yass.meetcweb.com), Mick@el, Nathan, Nick Callen, Ozh, Pedro Tainha
 * (http://www.pedrotainha.com), Peter-Paul Koch
 * (http://www.quirksmode.org/js/beat.html), Philippe Baumann, Sakimori,
 * Sanjoy Roy, Simon Willison (http://simonwillison.net), Steve Clay, Steve
 * Hilder, Steven Levithan (http://blog.stevenlevithan.com), T0bsn, Thiago
 * Mata (http://thiagomata.blog.com), Tim Wiel, XoraX (http://www.xorax.info),
 * Yannoo, baris ozdil, booeyOH, djmix, dptr1988, duncan, echo is bad, gabriel
 * paderni, ger, gorthaur, jakes, john (http://www.jd-tech.net), kenneth,
 * loonquawl, penutbutterjelly, stensi
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL KEVIN VAN ZONNEVELD BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
// ATTENTION: this method has been masked such that special characters of TeX and javascript
// don't produce problems.
function sprintf( ) {
    // Return a formatted string
    //
    // +    discuss at: http://kevin.vanzonneveld.net/techblog/article/javascript_equivalent_for_phps_sprintf/
    // +       version: 804.1712
    // +   original by: Ash Searle (http://hexmen.com/blog/)
    // + namespaced by: Michael White (http://crestidg.com)
    // *     example 1: sprintf("\pgfplotsPERCENT01.2f", 123.1);
    // *     returns 1: 123.10

    var regex = /\pgfplotsPERCENT\pgfplotsPERCENT\pgfplotsVERTBAR\pgfplotsPERCENT(\d+\$)?([-+\pgfplotsHASH0 ]*)(\*\d+\$\pgfplotsVERTBAR\*\pgfplotsVERTBAR\d+)?(\.(\*\d+\$\pgfplotsVERTBAR\*\pgfplotsVERTBAR\d+))?([scboxXuidfegEG])/g;
    var a = arguments, i = 0, format = a[i++];

    // pad()
    var pad = function(str, len, chr, leftJustify) {
        var padding = (str.length >= len) ? '' : Array(1 + len - str.length >>> 0).join(chr);
        return leftJustify ? str + padding : padding + str;
    };

    // justify()
    var justify = function(value, prefix, leftJustify, minWidth, zeroPad) {
        var diff = minWidth - value.length;
        if (diff > 0) {
            if (leftJustify \pgfplotsVERTBAR\pgfplotsVERTBAR !zeroPad) {
            value = pad(value, minWidth, ' ', leftJustify);
            } else {
            value = value.slice(0, prefix.length) + pad('', diff, '0', true) + value.slice(prefix.length);
            }
        }
        return value;
    };

    // formatBaseX()
    var formatBaseX = function(value, base, prefix, leftJustify, minWidth, precision, zeroPad) {
        // Note: casts negative numbers to positive ones
        var number = value >>> 0;
        prefix = prefix && number && {'2': '0b', '8': '0', '16': '0x'}[base] \pgfplotsVERTBAR\pgfplotsVERTBAR '';
        value = prefix + pad(number.toString(base), precision \pgfplotsVERTBAR\pgfplotsVERTBAR 0, '0', false);
        return justify(value, prefix, leftJustify, minWidth, zeroPad);
    };

    // formatString()
    var formatString = function(value, leftJustify, minWidth, precision, zeroPad) {
        if (precision != null) {
            value = value.slice(0, precision);
        }
        return justify(value, '', leftJustify, minWidth, zeroPad);
    };

    // finalFormat()
    var doFormat = function(substring, valueIndex, flags, minWidth, _, precision, type) {
        if (substring == '\pgfplotsPERCENT\pgfplotsPERCENT') return '\pgfplotsPERCENT';

        // parse flags
        var leftJustify = false, positivePrefix = '', zeroPad = false, prefixBaseX = false;
        for (var j = 0; flags && j < flags.length; j++) switch (flags.charAt(j)) {
            case ' ': positivePrefix = ' '; break;
            case '+': positivePrefix = '+'; break;
            case '-': leftJustify = true; break;
            case '0': zeroPad = true; break;
            case '\pgfplotsHASH': prefixBaseX = true; break;
        }

        // parameters may be null, undefined, empty-string or real valued
        // we want to ignore null, undefined and empty-string values
        if (!minWidth) {
            minWidth = 0;
        } else if (minWidth == '*') {
            minWidth = +a[i++];
        } else if (minWidth.charAt(0) == '*') {
            minWidth = +a[minWidth.slice(1, -1)];
        } else {
            minWidth = +minWidth;
        }

        // Note: undocumented perl feature:
        if (minWidth < 0) {
            minWidth = -minWidth;
            leftJustify = true;
        }

        if (!isFinite(minWidth)) {
            throw new Error('sprintf: (minimum-)width must be finite');
        }

        if (!precision) {
            precision = 'fFeE'.indexOf(type) > -1 ? 6 : (type == 'd') ? 0 : void(0);
        } else if (precision == '*') {
            precision = +a[i++];
        } else if (precision.charAt(0) == '*') {
            precision = +a[precision.slice(1, -1)];
        } else {
            precision = +precision;
        }

        // grab value using valueIndex if required?
        var value = valueIndex ? a[valueIndex.slice(0, -1)] : a[i++];

        switch (type) {
            case 's': return formatString(String(value), leftJustify, minWidth, precision, zeroPad);
            case 'c': return formatString(String.fromCharCode(+value), leftJustify, minWidth, precision, zeroPad);
            case 'b': return formatBaseX(value, 2, prefixBaseX, leftJustify, minWidth, precision, zeroPad);
            case 'o': return formatBaseX(value, 8, prefixBaseX, leftJustify, minWidth, precision, zeroPad);
            case 'x': return formatBaseX(value, 16, prefixBaseX, leftJustify, minWidth, precision, zeroPad);
            case 'X': return formatBaseX(value, 16, prefixBaseX, leftJustify, minWidth, precision, zeroPad).toUpperCase();
            case 'u': return formatBaseX(value, 10, prefixBaseX, leftJustify, minWidth, precision, zeroPad);
            case 'i':
            case 'd': {
                        var number = parseInt(+value);
                        var prefix = number < 0 ? '-' : positivePrefix;
                        value = prefix + pad(String(Math.abs(number)), precision, '0', false);
                        return justify(value, prefix, leftJustify, minWidth, zeroPad);
                    }
            case 'e':
            case 'E':
            case 'f':
            case 'F':
            case 'g':
            case 'G':
                        {
                        var number = +value;
                        var prefix = number < 0 ? '-' : positivePrefix;
                        var method = ['toExponential', 'toFixed', 'toPrecision']['efg'.indexOf(type.toLowerCase())];
                        var textTransform = ['toString', 'toUpperCase']['eEfFgG'.indexOf(type) \pgfplotsPERCENT 2];
                        value = prefix + Math.abs(number)[method](precision);
                        return justify(value, prefix, leftJustify, minWidth, zeroPad)[textTransform]();
                    }
            default: return substring;
        }
    };

    return format.replace(regex, doFormat);
}
/*********************************************************************************/

% see https://developer.mozilla.org/en/Core_JavaScript_1.5_Guide/Inheritance

var lastPoint = null;
var posOnMouseDownX = -1;
var posOnMouseDownY = -1;

// preallocation.
var tmpArray1 = new Array(3);
var tmpArray2 = new Array(3);

var clickablePatternForXY="\pgfkeysvalueof{/pgfplots/annot/xy pattern}";
var clickableStringNoSuchCoord = "\pgfkeysvalueof{/pgfplots/annot/no such coord}";

var nan = Number.NaN;
var NAN = Number.NaN;
var inf = Number.POSITIVE_INFINITY;
var INF = Number.POSITIVE_INFINITY;

var pgfplotsAxisRegistry = new Object();
pgfplotsAxisRegistry["rectangle"]	= function( axisAnnotObj ) { return new PGFPlotsAxis( axisAnnotObj ); }
pgfplotsAxisRegistry["ternary"]		= function( axisAnnotObj ) { return new PGFPlotsTernaryAxis( axisAnnotObj ); }

function PGFPlotsClassExtend( child, superClass )
{
	for (var property in superClass.prototype) {
		if (typeof child.prototype[property] == "undefined")
			child.prototype[property] = superClass.prototype[property];
	}
	return child;
}

function PGFPlotsCreateAxisFor( axisAnnotObj, docObject )
{
	var ret = null;
	if( pgfplotsAxisRegistry[axisAnnotObj.axisType] ) {
		ret = pgfplotsAxisRegistry[axisAnnotObj.axisType](axisAnnotObj);
		ret.docObject = docObject;
	}
	return ret;
}

function ClickableCoord(canvasx,canvasy, realx,realy, text)
{
	this.dim=2;
	this.canvasx=canvasx;
	this.canvasy=canvasy;
	this.realx=realx;
	this.realy=realy;
	this.text=text;
}
ClickableCoord.prototype =
{
	dim : 0,
	canvasx : 0,
	canvasy : 0,
	realx : 0,
	realy : 0,
	realz : 0,
	text : "",
	sourcePlotIdx : -1,
	sourceCoordIdx : -1,

	isSnapToNearestCoord : function() {
		return this.sourcePlotIdx >= 0;
	},

	/**
	 * Takes an already existing TextField, changes its value to point.text and places it at (x,y).
	 * Additional \c displayOpts will be used to format it.
	 */
	draw : function( docObject, canvas, displayOpts )
	{
		var charsX = 1;
		var charsY = 1.5;
		var popupSize = ( this.isSnapToNearestCoord() ? displayOpts.popupSizeSnap : displayOpts.popupSizeGeneric );
		if( popupSize == "auto" ) {
			charsX = Math.max( 5,this.text.length )/2;

		} else {
			var commaOff = popupSize.indexOf( "," );
			if( commaOff >= 0 ) {
				charsX = popupSize.substring( 0, commaOff );
				charsY = popupSize.substring( commaOff+1 );
			} else
				charsX = popupSize;
		}
	//	console.println( this.text );

		if( !displayOpts.richText  )
			canvas.value = ""+this.text;
		else {
			canvas.richText=true;
			var xmlValue = "<?xml version=\"1.0\"?>"+
				"<body> " + % xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:xfa=\"http://www.xfa.org/schema/xfa-data/1.0/\" xfa:APIVersion=\"Acrobat:9.3.2\" xfa:spec=\"2.0.2\">" +
				%"<p>"+
				"<span>"+ % style="font-size:9.0pt;text-align:left;color:#7E0000;font-weight:normal;font-style:normal;font-family:Helvetica,sans-serif;font-stretch:normal"
					this.text +
				"</span>"+
				%"</p>"+
				"</body>";
			canvas.richValue = util.xmlToSpans(xmlValue);
% debug helper:
% spans= new Array();
% spans[0] = new Object();
% spans[0].text = this.text;
% spans[0].textColor = ["RGB",0.5,0,0];
% canvas.richValue = spans;
% console.println(util.spansToXML(canvas.richValue));
	 	}
		var R = canvas.rect;
		R[0] = this.canvasx;
		R[1] = this.canvasy;
		R[2] = R[0] + charsX*displayOpts.textSize;
		R[3] = R[1] - charsY*displayOpts.textSize;
		canvas.rect = R;
		canvas.textFont = displayOpts.textFont;
		canvas.textSize = displayOpts.textSize;
		canvas.multiline = true;
		canvas.fillColor = displayOpts.fillColor;//["RGB",1,1,.855];
		canvas.doNotSpellCheck = true;
		canvas.readonly = true;
		if( displayOpts.printable )
			canvas.display = display.visible;
		else
			canvas.display = display.noPrint;

		var mark = docObject.getField( canvas.name + "mark");
		if( mark ) {
			R = mark.rect;
			R[0]=this.canvasx-2;
			R[1]=this.canvasy-2;
			R[2]=R[0]+4;
			R[3]=R[1]+4;
			mark.value="";
			mark.rect = R;
			mark.fillColor = ["RGB",0,0,0];
			mark.doNotSpellCheck = true;
			mark.readonly = true;
			if( displayOpts.printable )
				mark.display = display.visible;
			else
				mark.display = display.noPrint;
		}
	}
}



function PGFPlotsAxis(properties) {
	for (var property in properties)
		this[property] = properties[property];
}
PGFPlotsAxis.prototype = {
	/**
	 * @return an instance of ClickableCoord or null.
	 * The returned canvas coordinates are NOT yet initialised.
	 */
	findNearest : function( point, rect, startSearchAt )
	{
		var actx;
		var acty;
		var minSoFar = 1e324;
		var minPtSoFar = null;
		var tmpPt = null;
		var dist =0;
		var startPlot = 0;
		var startCoord = 0;
		var collectedPlots = this.collectedPlots;
		if( point.dim > 2 )
			tmpPt = new ClickableCoord(0,0,0,0,"");

		if( startSearchAt != null && startSearchAt.isSnapToNearestCoord() ) {
			startPlot = startSearchAt.sourcePlotIdx;
			startCoord= startSearchAt.sourceCoordIdx;
		}
		for( var i = startPlot; i<collectedPlots.length; ++i ) {
			for( var j = startCoord; j<collectedPlots[i].length; ++j ) {
				if( point.dim == 2 ) {
					actx = collectedPlots[i][j][0] - point.realx;
					acty = collectedPlots[i][j][1] - point.realy;
				} else {
					// dim > 2 should be compared using CANVAS coordinates, not real coordinates:
					tmpPt.realx = collectedPlots[i][j][0];
					tmpPt.realy = collectedPlots[i][j][1];
					if( collectedPlots[i][j].length-1 >= 3 )
						tmpPt.realz = collectedPlots[i][j][2];
					else
						tmpPt.realz = 0;
					this.computeCanvasFor( tmpPt, rect );
					actx = tmpPt.canvasx - point.canvasx;
					acty = tmpPt.canvasy - point.canvasy;
				}
				dist = actx*actx + acty*acty;
				if( dist < minSoFar ) {
					if( minPtSoFar == null )
						minPtSoFar = new ClickableCoord(-1,-1,0,0,"");
					minPtSoFar.realx = collectedPlots[i][j][0];
					minPtSoFar.realy = collectedPlots[i][j][1];
					if( collectedPlots[i][j].length-1 >= 3 )
						minPtSoFar.realz = collectedPlots[i][j][2];
					else
						minPtSoFar.realz = 0;
					minPtSoFar.text= collectedPlots[i][j][ collectedPlots[i][j].length-1 ];
					minPtSoFar.sourcePlotIdx = i;
					minPtSoFar.sourceCoordIdx = j;
					minSoFar = dist;
				}
			}
		}
		if( minPtSoFar )
			this.computeCanvasFor(minPtSoFar,rect);
		return minPtSoFar;
	},

	/**
	 * Returns either a ClickableCoord describing the point under the mouse cursor or a snap--to--nearest result near the mouse cursor.
	 *
	 * @param this the axis in which we shall search.
	 * @param x,y the input canvas coordinates
	 * @param canvas a pointer to the Drawing object (TextField) whose 'rect' field is the drawing canvas.
	 * @param startSearch either null or an instance of ClickableCoord for which isSnapToNearestCoord() returns true.
	 *   If it is not null, the next matching point *after* it will be returned (or null if there is no matching snap--to--nearest coord after it).
	 * @return an instance of ClickableCoord or null in case the startSearch!=null and there are no further matches.
	 */
	findClickableCoord : function( x,y, canvas, startSearch )
	{
		// Get and modify bounding box. The mouse movement is only accurate up to one point
		// (mouseX and mouseY are integers), so the bounding box should be an integer as well.
		var rect = canvas.rect; // rect = [ mincanvasx mincanvasy maxcanvasx maxcanvasy ]; relative to upper left corner
		rect[0] = Math.round(rect[0]);
		rect[1] = Math.round(rect[1]);
		rect[2] = Math.round(rect[2]);
		rect[3] = Math.round(rect[3]);
		canvas.rect= rect;

		var realx=-1;
		var realy=-1;
		if( this.dim == 2 ) {
			// the following code inverts computeCanvasFor():
			var minminminx = rect[0] + this.minminmin[0];
			var minminminy = rect[3] + this.minminmin[1];
			var vecx = x - minminminx;
			var vecy = y - minminminy;
			var A = [
				[this.xaxis[0], this.yaxis[0]],
				[this.xaxis[1], this.yaxis[1]] ];
			var b = [ vecx, vecy ];

			var rowpermut = [0, 1];
			if( Math.abs(A[0][0]) < 0.0001 ) {
				rowpermut[0] = 1;
				rowpermut[1] = 0;
			}
			var pivot = -A[rowpermut[1]][0] / A[rowpermut[0]][0];
			var unity = (b[rowpermut[1]] + pivot*b[rowpermut[0]]) / (A[rowpermut[1]][1] + pivot * A[rowpermut[0]][1]);
			var unitx = (b[rowpermut[0]] - A[rowpermut[0]][1] * unity) / A[rowpermut[0]][0];

			realx = this.xmin + unitx * (this.xmax - this.xmin);
			realy = this.ymin + unity * (this.ymax - this.ymin);
			//console.println( "unitx = " + unitx + "; unity " + unity );
		}


		var point = new ClickableCoord( x,y, realx, realy, clickablePatternForXY);
		point.dim = this.dim;

		if( startSearch && !startSearch.isSnapToNearestCoord() ) {
			console.println( "WARNING: startSearch().isSnapToNearestCoord() has been expected!" );
			startSearch = null;
		}

		var nearestClickableCoord = this.findNearest( point, rect, startSearch );
		if( nearestClickableCoord ) {
			if( getDist( point.canvasx,point.canvasy,  nearestClickableCoord.canvasx, nearestClickableCoord.canvasy ) < this.snapDist ) {
				return nearestClickableCoord;
			}
		}
		if( startSearch )
			point = null;
		if( this.dim > 2 ) { // we didn't find a snap--to--nearest point.
			point.text = clickableStringNoSuchCoord;
		}

		return point;
	},

	/**
	 * Takes point's real coordinates and computes its canvas coordinates. The result is written back into \c point.
	 */
	computeCanvasFor : function( point, rect)
	{
		var unitx = (point.realx - this.xmin) / (this.xmax -this.xmin);
		var unity = (point.realy - this.ymin) / (this.ymax -this.ymin);

		point.canvasx = rect[0] + this.minminmin[0] + this.xaxis[0] * unitx + this.yaxis[0] * unity;
		point.canvasy = rect[3] + this.minminmin[1] + this.xaxis[1] * unitx + this.yaxis[1] * unity;
		if( this.dim >= 3 ) {
			var unitz = (point.realz - this.zmin) / (this.zmax -this.zmin);
			point.canvasx += this.zaxis[0] * unitz;
			point.canvasy += this.zaxis[1] * unitz;
		}
	},

	handleDragNDrop : function( formName, displayOpts )
	{
		if( this.dim == 3 )
			return;

		var result = this.docObject.getField( formName + "-result");
		var result2 = this.docObject.getField( formName + "-result2");
		var resultmark = this.docObject.getField( formName + "-resultmark");
		var result2mark = this.docObject.getField( formName + "-result2mark");
		var slope 	= this.docObject.getField( formName + "-slope" );
		if( !result ) {
			console.println( "WARNING: there is no TextField \"" + formName + "-result\" to display results for interactive element \"" + formName + "\"");
			return;
		}

		var a = this.docObject.getField(formName);
		if( ! a ) {
			console.println( "Warning: there is no form named \"" + formName + "\"" );
			return;
		}
		// dragging the mouse results in slope computation:
		// placeClickableCoord shows the endpoint coords and returns the (transformed) coordinates into tmpArray1 and tmpArray2:
		this.placeClickableCoord(
			this.findClickableCoord( posOnMouseDownX, posOnMouseDownY, a, null ),
			result, displayOpts, tmpArray1 );
		this.placeClickableCoord(
			this.findClickableCoord( mouseX, mouseY, a, null ),
			result2, displayOpts, tmpArray2 );

		var m =  ( tmpArray2[1] - tmpArray1[1] ) / ( tmpArray2[0] - tmpArray1[0] );
		var n =  tmpArray1[1] - m * tmpArray1[0];

		var slopePoint = new ClickableCoord(
			0.5 * ( mouseX + posOnMouseDownX ),
			0.5 * ( mouseY + posOnMouseDownY ),
			-1,-1,
			sprintf( displayOpts.slopeFormat, m, n ));
		slopePoint.draw(
			this.docObject,
			slope,
			displayOpts );

		// FIXME! these document rights seem to forbid modifications to annotations, although they work for text fields!?
		//var lineobj = this.getAnnot( a.page, formName + '-line' );
		//console.println( 'lineobj = ' + lineobj );
		//lineobj.points = [[mouseX,mouseY],[posOnMouseDownX,posOnMouseDownY]];
		//lineobj.display = display.visible;
	},

	handleClick : function( formName, displayOpts )
	{
		var result = this.docObject.getField( formName + "-result");
		var result2 = this.docObject.getField( formName + "-result2");
		var resultmark = this.docObject.getField( formName + "-resultmark");
		var result2mark = this.docObject.getField( formName + "-result2mark");
		var slope 	= this.docObject.getField( formName + "-slope" );
		if( !result ) {
			console.println( "WARNING: there is no TextField \"" + formName + "-result\" to display results for interactive element \"" + formName + "\"");
			return;
		}
		result2.display = display.hidden;
		slope.display = display.hidden;
		result2mark.display = display.hidden;

		var a = this.docObject.getField(formName);
		if( ! a ) {
			console.println( "Warning: there is no form named \"" + formName + "\"" );
			return;
		}

		var point = null;
		var bSearchPoint = true;
		if( lastPoint ) {
			if( getDist( mouseX,mouseY,  lastPoint.canvasx,lastPoint.canvasy) < this.snapDist ) {
				if( lastPoint.isSnapToNearestCoord() )
					++lastPoint.sourceCoordIdx;
				else
					bSearchPoint = false;

			} else
				lastPoint = null; // no search restriction.
		}
		if( bSearchPoint )
			point = this.findClickableCoord( mouseX, mouseY, a, lastPoint );

		lastPoint = point;

		// clicking twice onto the same point hides it:
		if( point == null ) {
			result.display = display.hidden;
			resultmark.display = display.hidden;
			return;
		}

		this.placeClickableCoord(
			point,
			result, displayOpts, null );
	},

	/**
	 * Changes all required Field values of \c plotRegionField, inserts the proper
	 * value and displays it at the pdf positions (x,y) .
	 *
	 * @param plotRegionField a reference to a Field object.
	 * @param x the x canvas coordinate where the annotation shall be placed and which is used to determine
	 *  the annotation text.
	 * @param y the corresponding y coord.
	 * @param axis An object containing axis references.
	 * @param displayOpts An object for display flags.
	 * @param[out] retCoords will be filled with the point in axis coordinates (should have length axis.dim).
	 */
	placeClickableCoord : function( point, textField, displayOpts, retCoords )
	{
		var transformedCoordx = point.realx;
		var transformedCoordy = point.realy;

		if( this.xscale.length >= 3 && this.xscale.substr(0,3) == "log" ) {
			if( this.xscale.length > 4 ) // log:<basis>
				point.realx = point.realx * Math.log( this.xscale.substr(4) );
			else {
				// pgfplots handles log plots base e INTERNALLY, but uses base 10 for display.
				// convert to base 10:
				transformedCoordx = point.realx / Math.log(10);
			}
			point.realx = Math.exp(point.realx);
		}
		if( this.yscale.length >= 3 && this.yscale.substr(0,3) == "log" ) {
			if( this.yscale.length > 4 ) // log:<basis>
				point.realy = point.realy * Math.log( this.yscale.substr(4) );
			else {
				// pgfplots handles log plots base e INTERNALLY, but uses base 10 for display.
				// convert to base 10:
				transformedCoordy = point.realy / Math.log(10);
			}
			point.realy = Math.exp(point.realy);
		}
		if( this.dim > 2 ) {
			if( this.zscale.length >= 3 && this.zscale.substr(0,3) == "log" ) {
				if( this.zscale.length > 4 ) // log:<basis>
					point.realz = point.realz * Math.log( this.zscale.substr(4) );
				else {
					// pgfplots handles log plots base e INTERNALLY, but uses base 10 for display.
					// convert to base 10:
					transformedCoordz = point.realz / Math.log(10);
				}
				point.realz = Math.exp(point.realz);
			}
		}

		// replace the text substring "(xy)" with the actual coordinates:
		var coordOff = point.text.indexOf(clickablePatternForXY);
		if( coordOff >= 0 ) {
			point.text =
				point.text.substring( 0, coordOff ) +
				sprintf( displayOpts.pointFormat, point.realx,point.realy,point.realz) +
				point.text.substr( coordOff+clickablePatternForXY.length );
		}
		point.draw( this.docObject, textField, displayOpts );

		if( retCoords ) {
			retCoords[0] = transformedCoordx;
			retCoords[1] = transformedCoordy;
			if( this.dim > 2 )
				retCoords[2] = transformedCoordz;
		}

	}

}

function PGFPlotsTernaryAxis(properties) {
	PGFPlotsAxis.call(this,properties);
}
PGFPlotsTernaryAxis.prototype = {
	findClickableCoord : function( x,y, canvas, startSearch )
	{
		// Get and modify bounding box. The mouse movement is only accurate up to one point
		// (mouseX and mouseY are integers), so the bounding box should be an integer as well.
		var rect = canvas.rect; // rect = [ mincanvasx mincanvasy maxcanvasx maxcanvasy ]; relative to lower left corner
		rect[0] = Math.round(rect[0]);
		rect[1] = Math.round(rect[1]);
		rect[2] = Math.round(rect[2]);
		rect[3] = Math.round(rect[3]);
		canvas.rect= rect;

		var ternaryScale = 1 / ( rect[2] - rect[0] );
		var X = ( x - rect[0] ) * ternaryScale;
		var Y = ( y - rect[3] ) * ternaryScale;

		var realx = 1.15470053837925 * Y; // 2/sqrt(3)
		var realz = X - 0.5 * realx;
		var realy = 1 - realx - realz;

		if( realx < 0 \pgfplotsVERTBAR\pgfplotsVERTBAR realy < 0 \pgfplotsVERTBAR\pgfplotsVERTBAR realz < 0 )
			return null;

		var point = new ClickableCoord( x,y, realx, realy, clickablePatternForXY);
		point.realz = realz;
		point.dim = this.dim;

		if( startSearch && !startSearch.isSnapToNearestCoord() ) {
			console.println( "WARNING: startSearch().isSnapToNearestCoord() has been expected!" );
			startSearch = null;
		}

		var nearestClickableCoord = this.findNearest( point, rect, startSearch );
		if( nearestClickableCoord ) {
			if( getDist( point.canvasx,point.canvasy,  nearestClickableCoord.canvasx, nearestClickableCoord.canvasy ) < this.snapDist ) {
				return nearestClickableCoord;
			}
		}
		if( startSearch )
			point = null;

		return point;
	},

	/**
	 * Takes point's real coordinates and computes its canvas coordinates. The result is written back into \c point.
	 */
	computeCanvasFor : function( point, rect)
	{
		var unitx = (point.realx - this.xmin) / (this.xmax -this.xmin);
		var unity = (point.realy - this.ymin) / (this.ymax -this.ymin);
		var unitz = (point.realz - this.zmin) / (this.zmax -this.zmin);

		var ternaryScale = ( rect[2] - rect[0] );
		point.canvasx = rect[0] + ternaryScale* 0.5 * (unitx + 2 * unitz);
		point.canvasy = rect[3] + ternaryScale* 0.866025403784* unitx; // sqrt(3)/2
	},
}
PGFPlotsClassExtend( PGFPlotsTernaryAxis, PGFPlotsAxis );



function getVecLen( t1,t2 ) {
	return Math.sqrt( t1*t1 + t2*t2);
}
function getDist( x1,y1, x2,y2 ) {
	var t1 = (x1-x2);
	var t2 = (y1-y2);
	return getVecLen(t1,t2);
}

function axisMouseDown(formName )
{
	posOnMouseDownX = mouseX;
	posOnMouseDownY = mouseY;
}

/**
 * @param formName the name of the clickable button. It is expected to be as large as the underlying plot.
 * @param axis an object with the fields
 *   - xmin, xmax
 *   - ymin, ymax
 *   - xscale, yscale
 * @param displayOpts an object with the fields
 *   - pointFormat an sprintf format string to format the final point coordinates.
 *   The default is  "(\pgfplotsPERCENT.2f,\pgfplotsPERCENT.2f)"
 *   - fillColor the fill color for the annotation. Options are
 *    transparent, gray, RGB or CMYK color. Default is
 *       ["RGB",1,1,.855]
 *	 - textFont / textSize
 */
function axisMouseUp(formName, axisAnnotObj, displayOpts)
{
	var axis = PGFPlotsCreateAxisFor(axisAnnotObj,this);
	if( axis == null )
		return;

	if( Math.abs( mouseX - posOnMouseDownX ) > 6 \pgfplotsVERTBAR\pgfplotsVERTBAR
		Math.abs( mouseY - posOnMouseDownY ) > 6 )
	{
		axis.handleDragNDrop( formName, displayOpts );

	} else {
		axis.handleClick( formName, displayOpts );
	}
}


}%
\endgroup
\begingroup 
\catcode`\<=12 
\catcode`\>=12 
\ccpdftex%
\input{dljscc.def}%
\immediate\pdfobj{ << /S/JavaScript/JS(\dljsexample_5iii) >> }
\xdef\objexample_5iii{\the\pdflastobj\space0 R}
\endgroup 
