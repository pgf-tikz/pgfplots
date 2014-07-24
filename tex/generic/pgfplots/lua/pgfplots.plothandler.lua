local math=math
local pgfplotsmath = pgfplotsmath
local io=io
local tostring=tostring
local tonumber=tonumber
local error=error

do
local _ENV = pgfplots
-----------------------------------

Coord = newClass()

function Coord:constructor()
    self.x = { nil, nil, nil }
    self.unboundedDir = nil
    self.meta= nil
    self.unfiltered = nil
    return self
end

function Coord:__tostring()
    return '(' .. stringOrDefault(self.x[1], "--") .. 
        ',' .. stringOrDefault(self.x[2], "--") .. 
        ',' .. stringOrDefault(self.x[3], "--") .. 
        ') [' .. stringOrDefault(self.meta, "--") .. ']'
end

-------------------------------------------------------

Plothandler = newClass()

function Plothandler:constructor(name)
    self.name = name
    self.coordindex = 0
    self.metamin = { math.huge, math.huge }
    self.metamax = { -math.huge, -math.huge }
    self.coords = {}
    return self
end

function Plothandler:__tostring()
    return 'plot handler ' .. self.name
end

function Plothandler:surveyBeforeSetPointMeta()
end

function Plothandler:surveyAfterSetPointMeta()
end

function Plothandler:addSurveyedPoint(pt)
    table.insert(self.coords, pt)
end

function Plothandler:setperpointmetalimits(pt)
    if pt.meta ~= nil then
        self.metamin = math.min(self.metamin, pt.meta )
        self.metamax = math.max(self.metamax, pt.meta )
    end
end

function Plothandler:surveypoint(pt)
    parsed = gca.parsecoordinate(pt)
    prepared = gca.preparecoordinate(parsed)
    if prepared ~= nil then
        gca.updatelimitsforcoordinate(prepared)
    end
    gca.datapointsurveyed(prepared, self)
    
    self.coordindex = self.coordindex + 1;
end

-------------------------------------------------------

UnboundedCoords = { discard=0, jump=1 }

AxisConfig = newClass()

function AxisConfig:constructor()
    self.unboundedCoords = UnboundedCoords.discard
    self.warnForfilterDiscards=true
    return self
end

-------------------------------------------------------

PointMetaHandler = newClass()

-- @param isSymbolic
--    expands to either '1' or '0'
-- 		A numeric source will be processed numerically in float
-- 		arithmetics. Thus, the output of the @assign routine should be
-- 		a macro \pgfplots@current@point@meta in float format.
--
--		The output of a numeric point meta source will result in meta
--		limit updates and the final map to [0,1000] will be
--		initialised automatically.
--
-- 		A symbolic input routine won't be processed.
-- 	Default is '0'
--
-- @param explicitInput
--   expands to either
--   '1' or '0'. In case '1', it expects explicit input from the
--   coordinate input routines. For example, 'plot file' will look for
--   further input after the x,y,z coordinates.
--   Default is '0'
--
function PointMetaHandler:constructor(isSymbolic, explicitInput)
    self.isSymbolic =isSymbolic
    self.explicitInput = explicitInput
    return self
end

-- 	During the survey phase, this macro is expected to assign
-- 	\pgfplots@current@point@meta
--	if it is a numeric input method, it should return a
--	floating point number.
--	It is allowed to return an empty string to say "there is no point
--	meta".
--	PRECONDITION for '@assign':
--		- the coordinate input method has already assigned its
--		'\pgfplots@current@point@meta' (probably as raw input string).
--		- the other input coordinates are already read.
--	POSTCONDITION for '@assign':
--		- \pgfplots@current@point@meta is ready for use:
--		- EITHER a parsed floating point number 
--		- OR an empty string,
--		- OR a symbolic string (if the issymbolic boolean is true)
--	The default implementation is
--	\let\pgfplots@current@point@meta=\pgfutil@empty
--
function PointMetaHandler.assign(pt)
    error("This instance of PointMetaHandler is not implemented")
end


CoordAssignmentPointMetaHandler = newClassExtents( PointMetaHandler )
function CoordAssignmentPointMetaHandler:constructor(dir)
    PointMetaHandler:constructor(false,false)
    if not dir then error "nil argument for 'dir' is unsupported." end
    self.dir=dir 
end

function CoordAssignmentPointMetaHandler:assign(pt)
    pt.meta = tonumber(pt.x[self.dir])
end

XcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(1)
YcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(2)
ZcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(3)

ExplicitPointMetaHandler = newClassExtents( PointMetaHandler )
function ExplicitPointMetaHandler:constructor()
    PointMetaHandler:constructor(false,true)
end

function ExplicitPointMetaHandler:assign(pt)
    if pt.unfiltered ~= nil and pt.unfiltered.meta ~= nil then
        pt.meta = tonumber(pt.unfiltered.meta)
    end
end
-------------------------------------------------------

Axis = newClass()

function Axis:constructor(pointmetainputhandler)
    self.is3d = false
    self.config = AxisConfig()
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
    self.axiswidemetamin = { math.huge, math.huge }
    self.axiswidemetamax = { -math.huge, -math.huge }
    -- FIXME : move this to the plot handler
    self.plotHasJumps = false
    return self
end

function Axis:haspointmeta()
    return self.pointmetainputhandler ~=nil
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
    
    local result = Coord()
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

function Axis:preparecoordinate(pt)
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

function Axis:setperpointmeta(pt)
    if pt.meta == nil and self.pointmetainputhandler ~= nil then
        self.pointmetainputhandler:assign(pt)
    end
end

function Axis:addVisualizationDependencies(pt)
    -- FIXME : 'visualization depends on' 
    -- FIXME : 'execute for finished point'
    return pt
end

function Axis:datapointsurveyed(pt, plothandler)
    if pt ~= nil then
        plothandler:surveyBeforeSetPointMeta()
        self:setperpointmeta(pt)
        if not self.pointmetainputhandler.isSymbolic then
            -- update point meta limits _for this plot handler_.
            -- Note that these values will contribute to axiswidemetamax/min eventually
            plothandler:setperpointmetalimits(pt)
        end
        plothandler:surveyAfterSetPointMeta()

        -- FIXME : error bars
        -- FIXME: collect first plot as tick
        -- FIXME : collect first/last points in current stream

        local serialized = self:addVisualizationDependencies(pt)
        plothandler:addSurveyedPoint(serialized)
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

                local serialized = self:addVisualizationDependencies(pt)
                plothandler:addSurveyedPoint(serialized)
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
