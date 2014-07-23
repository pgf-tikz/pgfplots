local math=math
local tostring = tostring
local setmetatable = setmetatable

do
local _ENV = pgfplots
---------------------------------------

function stringOrDefault(str, default)
    if str == nil then
        return default
    end
    return tostring(str)
end


pgfplotsmath = {}

function pgfplotsmath.isnan(x)
    return x ~= x
end

pgfplotsmath.infty = 1/0

end
