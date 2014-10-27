-- This file has dependencies to BOTH, the TeX part of pgfplots and the LUA part.
-- It is the only LUA component with this property.
--
-- Its purpose is to encapsulate the communication between TeX and LUA in a central LUA file

local pgfplotsmath = pgfplots.pgfplotsmath
local error=error
local table=table
local string=string
local tostring=tostring
local type=type
local io=io
local mathfloor=math.floor
local pgfmathparse = pgfplots.pgfluamathparser.pgfmathparse

do
-- all globals will be read from/defined in pgfplots:
local _ENV = pgfplots

local pgftonumber =pgfluamathfunctions.tonumber

function texBoxPlotSurveyPoint(data)
	gca.currentPlotHandler:semiSurveyedValue(data)
end

-------------------------------------------------------

BoxPlotRequest = newClass()

-- lowerQuartialPercent: typically 0.25
-- upperQuartialPercent: typically 0.75
-- whiskerRange: typically 1.5
function BoxPlotRequest:constructor(lowerQuartialPercent, upperQuartialPercent, whiskerRange)
	if not lowerQuartialPercent or not upperQuartialPercent or not whiskerRange then error("Arguments must not be nil") end
	self.lowerQuartialPercent = pgftonumber(lowerQuartialPercent)
	self.upperQuartialPercent = pgftonumber(upperQuartialPercent)
	self.whiskerRange = pgftonumber(whiskerRange)
end

-------------------------------------------------------

BoxPlotResponse = newClass()

function BoxPlotResponse:constructor()
	self.lowerWhisker = nil
	self.lowerQuartile = nil
	self.median = nil
	self.upperQuartile = nil
	self.upperWhisker = nil
	self.average = nil
	self.outliers = {}
end

-- @param boxPlotRequest an instance of BoxPlotRequest
-- @param data an indexed array with float values
-- @return an instance of BoxPlotResponse
function boxPlotCompute(boxPlotRequest, data)
	if not boxPlotRequest or not data then error("Arguments must not be nil") end
	
	for i = 1,#data do
		local data_i = data[i]
		if data_i == nil or type(data_i) ~= "number" then
			error("Illegal input array at index " .. tostring(i) .. ": " .. tostring(data_i))
		end
	end

	table.sort(data)

	local sum = 0
	for i = 1,#data do
		sum = sum + data[i]
	end
	
	local numCoords = #data

	local function getOffset(factor)
		local off = numCoords * factor

		local res = mathfloor(off)
		local isInt = res == off

		return res, isInt
	end
	
	local function getValue(offset, isInt)
		local res = data[offset]
		if not isInt and offset < numCoords then
			res = 0.5 * (res + data[offset+1])
		end
		return res
	end


	local lowerQuartileOff, lowerQuartileIsInt = getOffset(boxPlotRequest.lowerQuartialPercent)
	local medianOff, medianIsInt = getOffset(0.5)
	local upperQuartileOff, upperQuartileIsInt = getOffset(boxPlotRequest.upperQuartialPercent)

	local lowerWhisker
	local lowerQuartile = getValue(lowerQuartileOff, lowerQuartileIsInt)
	local median = getValue(medianOff, medianIsInt)
	local upperQuartile = getValue(upperQuartileOff, upperQuartileIsInt)
	local upperWhisker
	local average = sum / numCoords

	local whiskerRange = boxPlotRequest.whiskerRange
	local whiskerWidth = whiskerRange*(upperQuartile - lowerQuartile)
	local upperWhiskerValue = upperQuartile + whiskerWidth
	local lowerWhiskerValue = lowerQuartile - whiskerWidth

	local outliers = {}
	for i = 1,numCoords do
		local current = data[i]
		if current < lowerWhiskerValue then
			table.insert(outliers, current)
		else
			lowerWhisker = current
			break
		end
	end

	for i = numCoords,1,-1 do
		local current = data[i]
		if upperWhiskerValue < current then
			table.insert(outliers, current)
		else
			upperWhisker = current
			break
		end
	end

	local result = BoxPlotResponse.new()
	result.lowerWhisker = lowerWhisker
	result.lowerQuartile = lowerQuartile
	result.median = median
	result.upperQuartile = upperQuartile
	result.upperWhisker = upperWhisker
	result.average = average
	result.outliers = outliers

	return result
end

-------------------------------------------------------
-- Replicates the survey phase of \pgfplotsplothandlerboxplot 
BoxPlotPlothandler = newClassExtends(Plothandler)

-- drawDirection : either "x" or "y".
function BoxPlotPlothandler:constructor(boxPlotRequest, drawDirection, drawPosition, axis, pointmetainputhandler)
	if not boxPlotRequest or not drawDirection or not drawPosition then error("Arguments must not be nil") end
    Plothandler.constructor(self,"boxplot", axis, pointmetainputhandler)
	self.boxPlotRequest = boxPlotRequest

	local function evaluateDrawPosition()
		local result = pgfmathparse(drawPosition)
		return result
	end

	if drawDirection == "x" then
		self.boxplotsetxy = function (a,b) return a,evaluateDrawPosition() + b end
	elseif drawDirection == "y" then
		self.boxplotsetxy = function (a,b) return evaluateDrawPosition() + b,a end
	else
		error("Illegal argument drawDirection="..tostring(drawDirection) )
	end
end

function BoxPlotPlothandler:surveystart()
	self.boxplotInput = {}
	self.boxplotSurveyMode = true
end


function BoxPlotPlothandler:surveyend()
	self.boxplotSurveyMode = false

	local computed = boxPlotCompute( self.boxPlotRequest, self.boxplotInput )
	self.boxplotInput = nil

	local texResult = 
		"\\pgfplotsplothandlersurveyend@boxplot@set{lower whisker}{"  .. toTeXstring(computed.lowerWhisker) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{lower quartile}{" .. toTeXstring(computed.lowerQuartile) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{median}{"         .. toTeXstring(computed.median) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{upper quartile}{" .. toTeXstring(computed.upperQuartile) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{upper whisker}{"  .. toTeXstring(computed.upperWhisker) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{sample size}{"    .. toTeXstring(computed.numCoords) .. "}"
		
	Plothandler.surveystart(self)
	
	local outliers = computed.outliers
	for i =1,#outliers do
		local outlier = outliers[i]
		local pt = Coord.new()
		-- this here resembles \pgfplotsplothandlersurveypoint@boxplot@prepared when it is invoked during boxplot:
		local X,Y = self.boxplotsetxy(outlier, 0)
		pt.x = { X, Y, nil }
		Plothandler.surveypoint(self,pt)
	end
	Plothandler.surveyend(self)

	return texResult
end

function BoxPlotPlothandler:semiSurveyedValue(data)
    local result = pgftonumber(data)
	if result then
		table.insert( self.boxplotInput, result )
	end
end

function BoxPlotPlothandler:surveypoint(pt)
	if self.boxplotSurveyMode then
		error("Unsupported Operation encountered: box plot survey in LUA are only in PARTIAL mode (i.e. only if almost all has been prepared in TeX. Use 'lua backend=false' to get around this.")
	else
		Plothandler.surveypoint(self,pt)
	end
end

-------------------------------------------------------

end
