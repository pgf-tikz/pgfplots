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

do
-- all globals will be read from/defined in pgfplots:
local _ENV = pgfplots

local pgftonumber =pgfluamathfunctions.tonumber

function texBoxPlotSurveyPoint(data)
	gca.currentPlotHandler:semiSurveyedValue(data)
end

-------------------------------------------------------
-- Replicates the survey phase of \pgfplotsplothandlerboxplot 
BoxPlotPlothandler = newClassExtends(Plothandler)

function BoxPlotPlothandler:constructor(axis, pointmetainputhandler)
    Plothandler.constructor(self,"boxplot", axis, pointmetainputhandler)
end

function BoxPlotPlothandler:surveystart()
	self.boxplotInput = {}
	self.boxplotSum = 0
	self.boxplotSurveyMode = true
end


function BoxPlotPlothandler:surveyend()
	self.boxplotSurveyMode = false

	local data = self.boxplotInput
	local sum = self.boxplotSum
	self.boxplotInput = nil
	self.boxplotSum = nil

	table.sort(data)
	
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


	local lowerQuartileOff, lowerQuartileIsInt = getOffset(0.25)
	local medianOff, medianIsInt = getOffset(0.5)
	local upperQuartileOff, upperQuartileIsInt = getOffset(0.75)

	local lowerWhisker
	local lowerQuartile = getValue(lowerQuartileOff, lowerQuartileIsInt)
	local median = getValue(medianOff, medianIsInt)
	local upperQuartile = getValue(upperQuartileOff, upperQuartileIsInt)
	local upperWhisker
	local average = sum / numCoords

	local whiskerRange = 1.5 -- FIXME : make it configurable
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

	-- FIXME : REPORT OUTLIERS!

	local texResult = 
		"\\pgfplotsplothandlersurveyend@boxplot@set{lower whisker}{"  .. toTeXstring(lowerWhisker) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{lower quartile}{" .. toTeXstring(lowerQuartile) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{median}{"         .. toTeXstring(median) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{upper quartile}{" .. toTeXstring(upperQuartile) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{upper whisker}{"  .. toTeXstring(upperWhisker) .. "}" ..
		"\\pgfplotsplothandlersurveyend@boxplot@set{sample size}{"    .. toTeXstring(numCoords) .. "}"
		
	-- FIXME : how should I invoke super.survey!?

	return texResult
end

function BoxPlotPlothandler:semiSurveyedValue(data)
    local result = pgftonumber(data)
	if result then
		self.boxplotSum = self.boxplotSum + result
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

end
