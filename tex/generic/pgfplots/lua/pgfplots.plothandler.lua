local math=math
local pgfplotsmath = pgfplotsmath
local setmetatable = setmetatable

do
local _ENV = pgfplots
-----------------------------------

Coord = {}
Coord.__index = Coord

function Coord.new()
    local self = setmetatable({}, Coord)
    self.x = { nil, nil, nil }
    self.meta= nil
    return self
end

function Coord:__tostring()
    return '(' .. stringOrDefault(self.x[0], "--") .. 
        ',' .. stringOrDefault(self.x[1], "--") .. 
        ',' .. stringOrDefault(self.x[2], "--") .. 
        ') [' .. stringOrDefault(self.meta, "--") .. ']'
end

-------------------------------------------------------

Plothandler = {}
Plothandler.__index = Plothandler

function Plothandler.new(name)
    local self = setmetatable({}, Plothandler)
    self.name = name
    self.coordindex = 0
    return self
end

function Plothandler:__tostring()
    return 'plot handler ' .. self.name
end


function Plothandler:surveypoint(pt)
    -- FIXME : what about \pgfplots@set@perpointmeta@done !?
    parsed = gca.parsecoordinate(pt)
    prepared = gca.preparecoordinate(parsed)
    if prepared ~= nil then
        gca.updatelimitsforcoordinate(prepared)
    end
    gca.datapointsurveyed(prepared)
    
    self.coordindex = self.coordindex + 1;
end

-------------------------------------------------------

UnboundedCoords = { discard=0, jump=1 }

AxisConfig = {}
AxisConfig.__index = AxisConfig

function AxisConfig.new()
    local self = setmetatable({}, AxisConfig)
    self.unboundedCoords = UnboundedCoords.discard
    return self
end

-------------------------------------------------------

Axis = {}
Axis.__index =Axis

function Axis.new()
    local self = setmetatable({}, Axis)
    self.is3d = false
    self.isunbounded = { false, false, false}
    self.config = AxisConfig.new()
    return self
end

function Axis:preparecoord(dir, value)
    -- FIXME : user trafos, logs
    return value
end

function Axis:validatecoord(dir, value)
    local result = tonumber(value)
    
    if result == nil or result == pgfplotsmath.infty or result == -pgfplotsmath.infty or pgfplotsmath.isnan(result) then
        result = nil
        self.isunbounded[dir] = true
    end

    return result
end

function Axis:parsecoordinate(pt)
    if pt.x[2] ~= nil then
        self.is3d = true
    end
    
    local result = Coord.new()
    result.unfiltered = pt

    -- FIXME : self.prefilter(pt[i])
    for i = 0,2,1 do
        result.x[i] = self.preparecoord(i, pt.x[i])
        -- FIXME : 
        -- result.x[i] = self.filtercoord(i, result.x[i])
    end
    -- FIXME : result.x = self.xyzfilter(result.x)

    for i = 0,2,1 do
        result.x[i] = self.validatecoord(i, result.x[i])
    end
    
    local resultIsBounded = true
    for i = 0,2,1 do
        if result.x[i] == nil then
            resultIsBounded = false
        end
    end

    if not resultIsBounded then
        result = nil
    end

    return result    
end

function Axis:preparecoordinate(dir, pt)
    -- the default "preparation" is to return it as is (no number parsing)
    return pt
end

function Axis:updatelimitsforcoordinate(pt)
end

-- FIXME : it seems as if this here is more Plothandler:datapointsurveyed!
--
function Axis:datapointsurveyed(pt)
    if pt ~= nil then
        -- FIXME : setpointmeta(pt)
        -- FIXME : error bars
        -- FIXME: collect first plot as tick
        -- FIXME : collect first/last points in current stream
        -- FIXME : serialize data point
        --
    else
        -- COORDINATE HAS BEEN FILTERED AWAY
        -- FIXME : handle "unbounded coords"
    end
    
    -- note that the TeX variant would increase the coord index here.
    -- We do it it surveypoint.
end

function Axis:syncwithtex()
end

-- will be set by TeX code (in \begin{axis})
gca = nil


end
