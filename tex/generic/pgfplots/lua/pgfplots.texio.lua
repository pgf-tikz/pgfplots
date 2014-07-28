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

do
local _ENV = pgfplots

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
end
