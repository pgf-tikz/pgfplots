-- This file has dependencies to BOTH, the TeX part of pgfplots and the LUA part.
-- It is the only LUA component with this property.
--
-- Its purpose is to encapsulate the communication between TeX and LUA in a central LUA file

local pgfplotsmath = pgfplots.pgfplotsmath
local tex=tex
local tostring=tostring
local error=error
local table=table
local string=string
local pairs=pairs
local pcall=pcall
local type=type

do
-- all globals will be read from/defined in pgfplots:
local _ENV = pgfplots

-- expands to the survey results 
-- @see \pgfplots@LUA@survey@end
function texSurveyEnd()
	tex.sprint(gca:surveyToPgfplots(gca.currentPlotHandler, true));
	gca.currentPlotHandler=nil
end

-- expands to the transformed point meta
function texPerpointMetaTrafo(metaStr)
    local meta = pgfplotsmath.tonumber(metaStr)
    local transformed = gca.currentPlotHandler:visualizationTransformMeta(meta);
    tex.sprint(pgfplotsmath.tostringfixed(transformed));
end

-- expands to '1' if LUA is available for this plot and '0' otherwise.
function texVisualizationInit(plotNum, plotIs3d)
	if not plotNum or not plotIs3d then error("arguments must not be nil") end

    local currentPlotHandler = gca.plothandlers[plotNum+1]
    gca.currentPlotHandler = currentPlotHandler; 
    if currentPlotHandler then
		currentPlotHandler.plotIs3d = plotIs3d
        currentPlotHandler:visualizationPhaseInit();
        tex.sprint("1") 
    else
        -- ok, this plot has no LUA support.
        tex.sprint("0") 
    end
end

local tostringfixed = pgfplotsmath.tostringfixed
local pgfXyCoordSerializer = function(pt)
	-- FIXME : it is unsure of whether this here really an improvement - or if it would be faster to compute that stuff in TeX...
	return "{" .. tostringfixed(pt.pgfXY[1]) .. "}{" .. tostringfixed(pt.pgfXY[2]) .. "}"
end

-- expands to the resulting coordinates. Note that these coordinates are already mapped somehow (typically: to fixed point)
function texVisualizePlot(visualizerFactory)
	if not visualizerFactory then error("arguments must not be nil") end
	if type(visualizerFactory) ~= "function" then error("arguments must be a function (a factory)") end

    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("Illegal state: The current plot has no LUA plot handler!") end

	local visualizer = visualizerFactory(currentPlotHandler)

	local result = visualizer:getVisualizationOutput()
	local result_str = currentPlotHandler:getCoordsInTeXFormat(gca, result, pgfplotsmath.tostringfixed, pgfXyCoordSerializer)
    tex.sprint(result_str)
end

-- Expands to nothing
function texApplyZBufferReverseScanline(scanLineLength)
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseScanline(scanLineLength)
end 

-- Expands to nothing
function texApplyZBufferReverseTransposed(scanLineLength)
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseTransposed(scanLineLength)
end 

-- Expands to nothing
function texApplyZBufferReverseStream()
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseStream(scanLineLength)
end 

-- Expands to the resulting coordinates
function texGetSurveyedCoordsToPgfplots()
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    tex.sprint(currentPlotHandler:surveyedCoordsToPgfplots(gca))
end

function texColorMapPrecomputed(mapName, inMin, inMax, x)
	local colormap = ColorMaps[mapName];
	if colormap then
		local result = colormap:findPrecomputed(
			pgfplotsmath.tonumber(inMin),
			pgfplotsmath.tonumber(inMax),
			pgfplotsmath.tonumber(x))

		local str = ""
		for i = 1,#result do
			if i>1 then str = str .. "," end
			str = str .. tostring(result[i])
		end
		tex.sprint(str)
	end
end

local function isStripPrefixOrSuffixChar(char)
	return char == ' ' or char == '{' or char == "}"
end

-- Expressions can be something like
-- 	( {(6+(sin(3*(x+3*y))+1.25)*cos(x))*cos(y)},
--    {(6+(sin(3*(x+3*y))+1.25)*cos(x))*sin(y)},
--    {((sin(3*(x+3*y))+1.25)*sin(x))} );
--
-- These result in expressions = { " {...}", " {...}", " {...} " }
-- -> this function removes the surrounding braces and the white spaces.
local function removeSurroundingBraces(expressions)
	for i=1,#expressions do
		local expr = expressions[i]
		local startIdx
		local endIdx
		startIdx=1
		while startIdx<#expr and isStripPrefixOrSuffixChar(string.sub(expr,startIdx,startIdx)) do
			startIdx = startIdx+1
		end
		endIdx = #expr
		while endIdx > 0 and isStripPrefixOrSuffixChar(string.sub(expr,endIdx,endIdx)) do
			endIdx = endIdx-1
		end

		expr = string.sub(expr, startIdx, endIdx )
		expressions[i] = expr
	end
end

-- generates TeX output '1' on success and '0' on failure
function texAddplotExpressionCoordinateGenerator(is3d, xExpr, yExpr, zExpr, sampleLine, domainxmin, domainxmax, domainymin, domainymax, samplesx, samplesy, variablex, variabley, debugMode)
	local plothandler = gca.currentPlotHandler
	local coordoutputstream = SurveyCoordOutputStream.new(plothandler)
	
	local domainxmin = pgfplotsmath.tonumber(domainxmin)
	local domainxmax = pgfplotsmath.tonumber(domainxmax)
	local samplesx = pgfplotsmath.tonumber(samplesx)

	local expressions
	local domainMin
	local domainMax
	local samples
	local variableNames

	-- allow both, even if sampleLine=1. We may want to assign a dummy value to y.
	variableNames = { variablex, variabley }

	if sampleLine==1 then
		domainMin = { domainxmin }
		domainMax = { domainxmax }
		samples = { samplesx }
	else
		local domainymin = pgfplotsmath.tonumber(domainymin)
		local domainymax = pgfplotsmath.tonumber(domainymax)
		local samplesy = pgfplotsmath.tonumber(samplesy)

		domainMin = { domainxmin, domainymin }
		domainMax = { domainxmax, domainymax }
		samples = { samplesx, samplesy }
	end
	if is3d then
		expressions = {xExpr, yExpr, zExpr}
	else
		expressions = {xExpr, yExpr}
	end
	removeSurroundingBraces(expressions)

	local generator = AddplotExpressionCoordinateGenerator.new(
		coordoutputstream, 
		expressions,
		domainMin, domainMax,
		samples,
		variableNames)
	
	local success
	if debugMode then
		success = generator:generateCoords()
	else
		local resultOfGenerator
		success, resultOfGenerator = pcall(generator.generateCoords, generator)
		if success then
			-- AH: "pcall" returned 'true'. In this case, 'success' is the boolean returned by generator
			success = resultOfGenerator
		end

		if not success and type(resultOfGenerator) ~= "boolean" then
			log("log", "LUA survey failed:\n " .. resultOfGenerator .. "\nFalling back to TeX survey. Use \\pgfplotsset{lua debug} to see more.\n")
		end
	end

	if not type(success) == 'boolean' then error("Illegal state: expected boolean result") end

	if success then
		tex.sprint("1")
	else
		tex.sprint("0")
	end
end

function defaultPlotVisualizerFactory(plothandler)
	return PlotVisualizer.new(plothandler)
end

end
