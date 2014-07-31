-- This file has dependencies to BOTH, the TeX part of pgfplots and the LUA part.
-- It is the only LUA component with this property.
--
-- Its purpose is to encapsulate the communication between TeX and LUA in a central LUA file

local pgfplotsmath = pgfplots.pgfplotsmath
local io=io
local tex=tex
local tostring=tostring
local error=error
local table=table
local pairs=pairs

do
-- all globals will be read from/defined in pgfplots:
local _ENV = pgfplots

-- expands to the survey results 
-- @see \pgfplots@LUA@survey@end
function texSurveyEnd()
	tex.print(gca:surveyToPgfplots(gca.currentPlotHandler, true));
	gca.currentPlotHandler=nil
end

-- expands to the transformed point meta
function texPerpointMetaTrafo(metaStr)
    local meta = pgfplotsmath.tonumber(metaStr)
    local transformed = gca.currentPlotHandler:visualizationTransformMeta(meta);
    tex.print(pgfplotsmath.tostringfixed(transformed));
end

-- expands to '1' if LUA is available for this plot and '0' otherwise.
function texVisualizationInit(plotNum)
    local currentPlotHandler = gca.plothandlers[plotNum+1]
    gca.currentPlotHandler = currentPlotHandler; 
    if currentPlotHandler then
        currentPlotHandler:visualizationPhaseInit();
        tex.print("1") 
    else
        -- ok, this plot has no LUA support.
        tex.print("0") 
    end
end

-- Expands to the resulting coordinates
function texApplyZBufferReverseScanline(scanLineLength)
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseScanline(scanLineLength)
    
    tex.print(currentPlotHandler:surveyedCoordsToPgfplots(gca))
end 

-- Expands to the resulting coordinates
function texApplyZBufferReverseTransposed(scanLineLength)
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseTransposed(scanLineLength)
    
    tex.print(currentPlotHandler:surveyedCoordsToPgfplots(gca))
end 

-- Expands to the resulting coordinates
function texApplyZBufferReverseStream()
    local currentPlotHandler = gca.currentPlotHandler
    if not currentPlotHandler then error("This function cannot be used in the current context") end
    
    currentPlotHandler:reverseStream(scanLineLength)
    
    tex.print(currentPlotHandler:surveyedCoordsToPgfplots(gca))
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
		tex.print(str)
	end
end

-- generates TeX output '1' on success and '0' on failure
function texAddplotExpressionCoordinateGenerator(is3d, xExpr, yExpr, zExpr, sampleLine, domainxmin, domainxmax, domainymin, domainymax, samplesx, samplesy, variablex, variabley)
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

	local generator = AddplotExpressionCoordinateGenerator.new(
		coordoutputstream, 
		expressions,
		domainMin, domainMax,
		samples,
		variableNames)
	
	local success = generator:generateCoords()

	if success then
		tex.print("1")
	else
		tex.print("0")
	end
end

end
