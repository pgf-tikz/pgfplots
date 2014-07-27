--
-- This file contains parts of pgfplotscoordprocessing.code.tex and pgfplotsplothandlers.code.tex .
--
-- It contains
--
-- pgfplots.Axis
-- pgfplots.Coord
-- pgfplots.Plothandler
-- 
-- and some related classes.

local math=math
local pgfplotsmath = pgfplots.pgfplotsmath
local io=io
local type=type
local tostring=tostring
local error=error
local table=table

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
    local result = '(' .. stringOrDefault(self.x[1], "--") .. 
        ',' .. stringOrDefault(self.x[2], "--") .. 
        ',' .. stringOrDefault(self.x[3], "--") .. 
        ') [' .. stringOrDefault(self.meta, "--") .. ']'
    
    if not self.x[1] and self.unfiltered then
        result = result .. "(was " .. tostring(self.unfiltered) .. ")"
    end
    return result
end

-------------------------------------------------------

-- Abstract base class of all plot handlers.
-- It offers basic functionality for the survey phase.
--
-- It has cyclic dependencies to its axis (FIXME : break it)
Plothandler = newClass()

-- @param name the plot handler's name (a string)
-- @param axis the parent axis
-- @param pointmetainputhandler an instance of PointMetaHandler
function Plothandler:constructor(name, axis, pointmetainputhandler)
    if not name or not pointmetainputhandler or not axis then
        error("arguments must not be nil")
    end
    self.axis = axis
    self.name = name
    self.coordindex = 0
    self.metamin = math.huge
    self.metamax = -math.huge
    self.autocomputeMetaMin = true
    self.autocomputeMetaMax = true
    self.coords = {}
    self.pointmetainputhandler = pointmetainputhandler
    return self
end

function Plothandler:__tostring()
    return 'plot handler ' .. self.name
end

-- @see \pgfplotsplothandlersurveybeforesetpointmeta
function Plothandler:surveyBeforeSetPointMeta()
end

-- @see \pgfplotsplothandlersurveyaftersetpointmeta
function Plothandler:surveyAfterSetPointMeta()
end

-- PRIVATE
--
-- appends a fully surveyed point
function Plothandler:addSurveyedPoint(pt)
    table.insert(self.coords, pt)
    -- io.write("addSurveyedPoint(" .. tostring(pt) .. ") ...\n")
end

-- PRIVATE
--
-- assigns the point meta value by means of the PointMetaHandler
function Plothandler:setperpointmeta(pt)
    if pt.meta == nil and self.pointmetainputhandler ~= nil then
        self.pointmetainputhandler:assign(pt)
    end
end

-- PRIVATE
--
-- updates point meta limits
function Plothandler:setperpointmetalimits(pt)
    if pt.meta ~= nil then
        if not type(pt.meta) == 'number' then error("got unparsed input "..tostring(pt)) end
        if self.autocomputeMetaMin then
            self.metamin = math.min(self.metamin, pt.meta )
        end

        if self.autocomputeMetaMax then
            self.metamax = math.max(self.metamax, pt.meta )
        end
    end
end

-- @see \pgfplotsplothandlersurveystart
function Plothandler:surveystart()
    -- empty by default.
end

-- @see \pgfplotsplothandlersurveyend
function Plothandler:surveyend()
    -- empty by default.
end

-- @see \pgfplotsplothandlersurveypoint
function Plothandler:surveypoint(pt)
    local current = self.axis:parsecoordinate(pt)
    if current.x[1] ~= nil then
        current = self.axis:preparecoordinate(current)
        self.axis:updatelimitsforcoordinate(current)
    end
    self.axis:datapointsurveyed(current, self)
    
    self.coordindex = self.coordindex + 1;
end

-- PRIVATE
--
-- @return a string containing all surveyed coordinates in the format which is accepted \pgfplotsaxisdeserializedatapointfrom
function Plothandler:surveyedCoordsToPgfplots(axis)
    if not axis then error("arguments must not be nil") end
    local result = {}
    for i = 1,#self.coords,1 do
        local pt = self.coords[i]
        local ptstr = self:serializeCoordToPgfplots(pt)
        local axisPrivate = axis:serializeCoordToPgfplotsPrivate(pt)
        local serialized = "{" .. axisPrivate .. ";" .. ptstr .. "}"
        table.insert(result, serialized)
    end
    return table.concat(result)
end

-- PRIVATE 
--
-- does the same as \pgfplotsplothandlerserializepointto
function Plothandler:serializeCoordToPgfplots(pt)
    return 
        pgfplotsmath.toTeXstring(pt.x[1]) .. "," ..
        pgfplotsmath.toTeXstring(pt.x[2]) .. "," ..
        pgfplotsmath.toTeXstring(pt.x[3])
end


-- Replicates \pgfplotsplothandlermesh (to some extend)
MeshPlothandler = newClassExtents(Plothandler)

function MeshPlothandler:constructor(axis, pointmetainputhandler)
    Plothandler:constructor("mesh", axis, pointmetainputhandler)
end

-------------------------------------------------------

UnboundedCoords = { discard=0, jump=1 }

-- contains static axis configuration entities.
AxisConfig = newClass()

function AxisConfig:constructor()
    self.unboundedCoords = UnboundedCoords.discard
    self.warnForfilterDiscards=true
    return self
end

-------------------------------------------------------

-- An abstract base class for a handler of point meta.
-- @see \pgfplotsdeclarepointmetasource
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


-- A PointMetaHandler which merely acquires values of either x,y, or z.
CoordAssignmentPointMetaHandler = newClassExtents( PointMetaHandler )
function CoordAssignmentPointMetaHandler:constructor(dir)
    PointMetaHandler:constructor(false,false)
    if not dir then error "nil argument for 'dir' is unsupported." end
    self.dir=dir 
end

function CoordAssignmentPointMetaHandler:assign(pt)
    pt.meta = pgfplotsmath.tonumber(pt.x[self.dir])
end

XcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(1)
YcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(2)
ZcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler(3)

-- A class of PointMetaHandler which takes the 'Coord.meta' as input
ExplicitPointMetaHandler = newClassExtents( PointMetaHandler )
function ExplicitPointMetaHandler:constructor()
    PointMetaHandler:constructor(false,true)
end

function ExplicitPointMetaHandler:assign(pt)
    if pt.unfiltered ~= nil and pt.unfiltered.meta ~= nil then
        pt.meta = pgfplotsmath.tonumber(pt.unfiltered.meta)
    end
end
-------------------------------------------------------

-- An axis. 
Axis = newClass()

function Axis:constructor()
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

-- PRIVATE
--
-- applies user transformations and logs
--
-- @see \pgfplots@prepared@xcoord
function Axis:preparecoord(dir, value)
    -- FIXME : user trafos, logs
    return value
end

-- PRIVATE
-- @see \pgfplotsaxisserializedatapoint@private
function Axis:serializeCoordToPgfplotsPrivate(pt)
    return pgfplotsmath.toTeXstring(pt.meta)
end


-- PRIVATE
--
function Axis:validatecoord(dir, point)
    if not dir or not point then error("arguments must not be nil") end
    local result = pgfplotsmath.tonumber(point.x[dir])
    
    if result == nil then
        result = nil
    elseif result == pgfplotsmath.infty or result == -pgfplotsmath.infty or pgfplotsmath.isnan(result) then
        result = nil
        point.unboundedDir = dir
    end

    point.x[dir] = result
end

-- PRIVATE
--
-- @see \pgfplotsaxisparsecoordinate
function Axis:parsecoordinate(pt)
    -- replace empty strings by 'nil':
    for i = 1,3,1 do
        pt.x[i] = stringOrDefault(pt.x[i], nil)
    end
    pt.meta = stringOrDefault(pt.meta)

    if pt.x[3] ~= nil then
        self.is3d = true
    end
    
    local result = Coord()
    
    local unfiltered = Coord()
    unfiltered.x = {}
    unfiltered.meta = pt.meta
    for i = 1,3,1 do
        unfiltered.x[i] = pt.x[i]
    end
    result.unfiltered = unfiltered

    -- FIXME : self:prefilter(pt[i])
    for i = 1,self:loopMax(),1 do
        result.x[i] = self:preparecoord(i, pt.x[i])
        -- FIXME : 
        -- result.x[i] = self:filtercoord(i, result.x[i])
    end
    -- FIXME : result.x = self:xyzfilter(result.x)

    for i = 1,self:loopMax(),1 do
        self:validatecoord(i, result)
    end
    
    local resultIsBounded = true
    for i = 1,self:loopMax(),1 do
        if result.x[i] == nil then
            resultIsBounded = false
        end
    end

    if not resultIsBounded then
        result.x = { nil, nil, nil}
    end

    return result    
end

-- PROTECTED
--
-- @see \pgfplotsaxispreparecoordinate
function Axis:preparecoordinate(pt)
    -- the default "preparation" is to return it as is (no number parsing)
    return pt
end

-- PRIVATE
--
-- returns either 2 if this axis is 2d or 3 otherwise
--
-- FIXME : shouldn't this depend on the current plot handler!?
function Axis:loopMax()
    if self.is3d then return 3 else return 2 end
end

-- PRIVATE:
--
-- updates axis limits for pt
-- @param pt an instance of Coord
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

-- PRIVATE
--
-- unfinished, see its fixmes
function Axis:addVisualizationDependencies(pt)
    -- FIXME : 'visualization depends on' 
    -- FIXME : 'execute for finished point'
    return pt
end

-- PROTECTED
--
-- indicates that a data point has been surveyed by the axis and that it can be consumed 
function Axis:datapointsurveyed(pt, plothandler)
    if not pt or not plothandler then error("arguments must not be nil") end
    if pt.x[1] ~= nil then
        plothandler:surveyBeforeSetPointMeta()
        plothandler:setperpointmeta(pt)
        plothandler:setperpointmetalimits(pt)
        plothandler:surveyAfterSetPointMeta()

        -- FIXME : error bars
        -- FIXME: collect first plot as tick

        -- note that that TeX code would also remember the first/last coordinate in a stream.
        -- This is unnecessary here.

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
                io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason .. "\n")
            end
        elseif self.config.unboundedCoords == UnboundedCoords.jump then
            if pt.unboundedDir == nil then
                self.filteredCoordsAway = true
                if self.config.warnForfilterDiscards then
                    local reason = "of a coordinate filter."
                    io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason .. "\n")
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

-- PUBLIC
--
-- @return a set of (private) key-value pairs such that the TeX code of pgfplots can
-- access survey results of the provided plot handler
--
-- @param plothandler an instance of Plothandler
-- @param includeCoords true or false, depending on whether the plot coordinates should be returned
function Axis:surveyToPgfplots(plothandler, includeCoords)
    local firstCoord = plothandler.coords[1]
    local lastCoord = plothandler.coords[#plothandler.coords]
    local hasJumps
    local filteredCoordsAway
    if self.plotHasJumps then hasJumps = 1 else hasJumps = 0 end
    if self.filteredCoordsAway then filteredCoordsAway = 1 else filteredCoordsAway = 0 end

    local result = 
        "@xmin=" .. pgfplotsmath.toTeXstring(self.min[1]) .. "," ..
        "@ymin=" .. pgfplotsmath.toTeXstring(self.min[2]) .. "," ..
        "@zmin=" .. pgfplotsmath.toTeXstring(self.min[3]) .. "," ..
        "@xmax=" .. pgfplotsmath.toTeXstring(self.max[1]) .. "," ..
        "@ymax=" .. pgfplotsmath.toTeXstring(self.max[2]) .. "," ..
        "@zmax=" .. pgfplotsmath.toTeXstring(self.max[3]) .. "," ..
        "point meta min=" .. pgfplotsmath.toTeXstring(plothandler.metamin) ..","..
        "point meta max=" .. pgfplotsmath.toTeXstring(plothandler.metamax) ..","..
        "@is3d=" .. tostring(self.is3d) .. "," ..
        "@first coord={" .. Plothandler:serializeCoordToPgfplots(firstCoord) .. "}," ..
        "@last coord={" .. Plothandler:serializeCoordToPgfplots(lastCoord) .. "}," ..
        "@plot has jumps=" .. tostring(hasJumps) .. "," ..
        "@filtered coords away=" .. tostring(filteredCoordsAway) .. "," ..
        ""
    
    if includeCoords then
        result = result .. 
        "@surveyed coords={" .. plothandler:surveyedCoordsToPgfplots(self) .. "}," ..
        "@surveyed coordindex=" .. tostring(plothandler.coordindex) .. "," ..
        "";
    end
    
    return result
end

-- will be set by TeX code (in \begin{axis})
gca = nil


end
