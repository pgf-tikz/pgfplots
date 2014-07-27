
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
    local currentPlotHandler = gca.plothandlers[plotNum]
    gca.currentPlotHandler = currentPlotHandler; 
    if currentPlotHandler then
        currentPlotHandler:visualizationPhaseInit();
        tex.print("1") 
    else
        -- ok, this plot has no LUA support.
        tex.print("0") 
    end
end

end
