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
    self.unboundedDir = nil
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
    self.warnForfilterDiscards=true
    return self
end

-------------------------------------------------------

Axis = {}
Axis.__index =Axis

function Axis.new()
    local self = setmetatable({}, Axis)
    self.is3d = false
    self.config = AxisConfig.new()
    self.filteredCoordsAway = false
    self.clipLimits = true
    self.autocomputeAllLimits = true -- FIXME : redundant!?
    self.autocomputeMin = { true, true, true }
    self.autocomputeMax = { true, true, true }
    self.isLinear = { true, true, true }
    self.min = { math.huge, math.huge, math.huge }
    self.max = { -math.huge, -math.huge, -math.huge }
    self.datamin = { math.huge, math.huge, math.huge }
    self.datamax = { -math.huge, -math.huge, -math.huge }
    -- FIXME : move this to the plot handler
    self.plotHasJumps = false
    return self
end

function Axis:preparecoord(dir, value)
    -- FIXME : user trafos, logs
    return value
end

function Axis:validatecoord(dir, point)
    local result = tonumber(point.x[dir])
    
    if result == nil then
        result = nil
    elseif result == pgfplotsmath.infty or result == -pgfplotsmath.infty or pgfplotsmath.isnan(result) then
        result = nil
        point.unboundedDir = dir
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
    for i = 1,self:loopMax(),1 do
        result.x[i] = self.preparecoord(i, pt.x[i])
        -- FIXME : 
        -- result.x[i] = self.filtercoord(i, result.x[i])
    end
    -- FIXME : result.x = self.xyzfilter(result.x)

    for i = 1,self:loopMax(),1 do
        result = self.validatecoord(i, result)
    end
    
    local resultIsBounded = true
    for i = 1,self:loopMax(),1 do
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

function Axis:loopMax()
    if self.is3d then return 3 else return 2 end
end

function Axis:updatelimitsforcoordinate(pt)
    local isClipped = false
    if self.clipLimits then
        for i = 1,self:loopMax(),1 do
            if not self.autocomputeMin[i] then
                isClipped = isClipped or pt.x[i] < self.min[i]
            end
            if not self.autocomputeMax[i] then
                isClipped = isClipped or pt.x[i] > self.max[i]
            end
        end                
    end
    
    if not isClipped then
        for i = 1,self:loopMax(),1 do
            if self.autocomputeMin[i] then
                self.min[i] = math.min(pt.x[i], self.min[i])
            end
            
            if self.autocomputeMax[i] then
                self.max[i] = math.max(pt.x[i], self.max[i])
            end
        end
    end

    -- Compute data range:
    if self.autocomputeAllLimits then
        -- the data range will be acquired simply from the axis
        -- range, see below!
    else
        for i = 1,self:loopMax(),1 do
            self.datamin[i] = math.min(pt.x[i], self.min[i])
            self.datamax[i] = math.max(pt.x[i], self.max[i])
        end
    end
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
        if self.config.unboundedCoords == UnboundedCoords.discard then
            self.filteredCoordsAway = true
            if self.config.warnForfilterDiscards then
                local reason
                if pt.unboundedDir == nil then
                    reason = "of a coordinate filter."
                else
                    reason = "it is unbounding (in " .. tostring(pt.unboundedDir) .. ")."
                end
                io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason)
            end
        elseif self.config.unboundedCoords == UnboundedCoords.jump then
            if pt.unboundedDir == nil then
                self.filteredCoordsAway = true
                if self.config.warnForfilterDiscards then
                    local reason = "of a coordinate filter."
                    io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason)
                end
            else
                self.plotHasJumps = true
                -- FIXME : serialize data point
            end
        end
    end
    
    -- note that the TeX variant would increase the coord index here.
    -- We do it it surveypoint.
end

function Axis:syncwithtex()
end

-- will be set by TeX code (in \begin{axis})
gca = nil


end
