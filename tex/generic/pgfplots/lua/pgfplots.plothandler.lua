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
-- all globals will be read from/defined in pgfplots:
local _ENV = pgfplots
-----------------------------------

Coord = newClass()

function Coord:constructor()
    self.x = { nil, nil, nil }
    self.unboundedDir = nil
    self.meta= nil
    self.metatransformed = nil -- assigned during vis phase only
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

LinearMap = newClass()

-- A map such that
-- [inMin,inMax] is mapped linearly to [outMin,outMax]
--
function LinearMap:constructor(inMin, inMax, outMin, outMax)
    if not inMin or not inMax or not outMin or not outMax then error("arguments must not be nil") end
    if inMin >= inMax then error("invalid input domain " .. tostring(inMin) .. ":" .. tostring(inMax)) end
    self.offset = outMin - (outMax-outMin)*inMin/(inMax-inMin)
    self.scale = (outMax-outMin)/(inMax-inMin)
end

function LinearMap:map(x)
    return x*self.scale + self.offset
end

PointMetaMap = newClass()

function PointMetaMap:constructor(inMin,inMax, warnForfilterDiscards)
    if not inMin or not inMax or not warnForfilterDiscards then error("arguments must not be nil") end
    self._mapper = LinearMap.new(inMin,inMax, 0, 1000)
    self.warnForfilterDiscards = warnForfilterDiscards
end

function PointMetaMap:map(meta)
    if pgfplotsmath.isfinite(meta) then
        local result = self._mapper:map(meta)
        result = math.max(0, result)
        result = math.min(1000, result)
        return result
    else
        if self.warnForfilterDiscards then  
            io.write("The per point meta data '" .. tostring(meta) .. " (and probably others as well) is unbounded - using the minimum value instead.\n")
            self.warnForfilterDiscards=false
        end
        return 0
    end
end
    
    

-------------------------------------------------------

-- Abstract base class of all plot handlers.
-- It offers basic functionality for the survey phase.
Plothandler = newClass()

-- @param name the plot handler's name (a string)
-- @param axis the parent axis
-- @param pointmetainputhandler an instance of PointMetaHandler or nil if there is none
function Plothandler:constructor(name, axis, pointmetainputhandler)
    if not name or not axis then
        error("arguments must not be nil")
    end
    self.axis = axis
    self.config = PlothandlerConfig.new()
    self.name = name
    self.coordindex = 0
    self.metamin = math.huge
    self.metamax = -math.huge
    self.autocomputeMetaMin = true
    self.autocomputeMetaMax = true
    self.coords = {}
    self.pointmetainputhandler = pointmetainputhandler
    self.pointmetamap = nil -- will be set later
    self.filteredCoordsAway = false
    self.plotHasJumps = false
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

-- PUBLIC
--
-- @return a string containing all surveyed coordinates in the format which is accepted \pgfplotsaxisdeserializedatapointfrom
function Plothandler:surveyedCoordsToPgfplots(axis)
    if not axis then error("arguments must not be nil") end
    local result = {}
	local coords = self.coords
    for i = 1,#coords,1 do
        local pt = coords[i]
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

function Plothandler:visualizationPhaseInit()
	if self.pointmetainputhandler ~=nil then
		local rangeMin
		local rangeMax
		if self.config.pointmetarel == PointMetaRel.axiswide then
			rangeMin = self.axis.axiswidemetamin
			rangeMax = self.axis.axiswidemetamax
		else
			rangeMin = self.metamin
			rangeMax = self.metamax
		end
		self.pointmetamap = PointMetaMap.new(rangeMin, rangeMax, self.config.warnForfilterDiscards)
	end
end

-- PRECONDITION: visualizationPhaseInit() has been called some time before.
function Plothandler:visualizationTransformMeta(meta)
    if meta == nil then
        io.write("could not access the 'point meta' (used for example by scatter plots and color maps). Maybe you need to add '\\addplot[point meta=y]' or something like that?\n")
        return 1
    else
        return self.pointmetamap:map(meta)
    end
end

-------------------------------------------------------
-- Generic plot handler: one which has the default survey phase
-- It is actually the same as Plothandler...

GenericPlothandler = newClassExtends(Plothandler)

function GenericPlothandler:constructor(name, axis, pointmetainputhandler)
    Plothandler.constructor(self,name, axis, pointmetainputhandler)
end


-------------------------------------------------------
-- Replicates \pgfplotsplothandlermesh (to some extend)
MeshPlothandler = newClassExtends(Plothandler)

function MeshPlothandler:constructor(axis, pointmetainputhandler)
    Plothandler.constructor(self,"mesh", axis, pointmetainputhandler)
end

-- see \pgfplot@apply@zbuffer
function MeshPlothandler:reverseScanline(scanLineLength)
    local coords = self.coords
    local tmp
    local scanlineOff
    local numScanLines = #coords / scanLineLength
    for scanline = 0,numScanLines-1,1 do
        scanlineOff = scanline * scanLineLength
        local reverseindex = scanlineOff + scanLineLength
        for i = 0,scanLineLength/2-1,1 do
            tmp = coords[1+scanlineOff+i]
            coords[1+scanlineOff+i] = coords[reverseindex]
            coords[reverseindex] = tmp
            
            reverseindex = reverseindex-1
        end
    end
end

-- see \pgfplot@apply@zbuffer
function MeshPlothandler:reverseTransposed(scanLineLength)
    local coords = self.coords
    local tmp
    local scanlineOff
    local numScanLines = #coords / scanLineLength
    local reverseScanline = numScanLines-1
    for scanline = 0,numScanLines/2-1,1 do
        scanlineOff = 1+scanline * scanLineLength
        reverseScanlineOff = 1+reverseScanline * scanLineLength
        for i = 0,scanLineLength-1 do
            tmp = coords[scanlineOff+i]
            coords[scanlineOff+i] = coords[reverseScanlineOff+i]
            coords[reverseScanlineOff+i] = tmp
        end

        reverseScanline = reverseScanline-1
    end
end

-- see \pgfplot@apply@zbuffer
function MeshPlothandler:reverseStream()
    local coords = self.coords
    local tmp
    local reverseindex = #coords
    for i = 1,#coords/2 do
        tmp = coords[i]
        coords[i] = coords[reverseindex]
        coords[reverseindex] = tmp
        reverseindex = reverseindex-1
    end
end


-------------------------------------------------------

UnboundedCoords = { discard="d", jump="j" }

PointMetaRel = { axiswide = 0, perplot =1 }


-- contains static configuration entities.
PlothandlerConfig = newClass()

function PlothandlerConfig:constructor()
    self.unboundedCoords = UnboundedCoords.discard
    self.warnForfilterDiscards=true
    self.pointmetarel = PointMetaRel.axiswide
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
CoordAssignmentPointMetaHandler = newClassExtends( PointMetaHandler )
function CoordAssignmentPointMetaHandler:constructor(dir)
    PointMetaHandler.constructor(self, false,false)
    if not dir then error "nil argument for 'dir' is unsupported." end
    self.dir=dir 
end

function CoordAssignmentPointMetaHandler:assign(pt)
    if not pt then error("arguments must not be nil") end
    pt.meta = pgfplotsmath.tonumber(pt.x[self.dir])
end

XcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler.new(1)
YcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler.new(2)
ZcoordAssignmentPointMetaHandler = CoordAssignmentPointMetaHandler.new(3)

-- A class of PointMetaHandler which takes the 'Coord.meta' as input
ExplicitPointMetaHandler = newClassExtends( PointMetaHandler )
function ExplicitPointMetaHandler:constructor()
    PointMetaHandler.constructor(self, false,true)
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
    -- will be populated by the TeX code:
    self.plothandlers = {}
    return self
end

-- PRIVATE
--
-- applies user transformations and logs
--
-- @see \pgfplots@prepared@xcoord
function Axis:preparecoord(dir, value)
    -- FIXME : user trafos, logs (switches off LUA backend)
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
    
    local result = Coord.new()
    
    local unfiltered = Coord.new()
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
        if plothandler.config.unboundedCoords == UnboundedCoords.discard then
            plothandler.filteredCoordsAway = true
            if plothandler.config.warnForfilterDiscards then
                local reason
                if pt.unboundedDir == nil then
                    reason = "of a coordinate filter."
                else
                    reason = "it is unbounding (in " .. tostring(pt.unboundedDir) .. ")."
                end
                io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason .. "\n")
            end
        elseif plothandler.config.unboundedCoords == UnboundedCoords.jump then
            if pt.unboundedDir == nil then
                plothandler.filteredCoordsAway = true
                if plothandler.config.warnForfilterDiscards then
                    local reason = "of a coordinate filter."
                    io.write("NOTE: coordinate " .. tostring(pt) .. " has been dropped because " .. reason .. "\n")
                end
            else
                plothandler.plotHasJumps = true

                local serialized = self:addVisualizationDependencies(pt)
                plothandler:addSurveyedPoint(serialized)
            end
        end
    end
    
    -- note that the TeX variant would increase the coord index here.
    -- We do it it surveypoint.
end

local function axisLimitToTeXString(name, value)
	if value == math.huge or value == -math.huge then
		return ""
	end
	return name .. "=" .. pgfplotsmath.toTeXstring(value) .. ","
end

-- PUBLIC
--
-- @return a set of (private) key-value pairs such that the TeX code of pgfplots can
-- access survey results of the provided plot handler
--
-- @param plothandler an instance of Plothandler
-- @param includeCoords true or false, depending on whether the plot coordinates should be returned
function Axis:surveyToPgfplots(plothandler, includeCoords)
    local firstCoord = plothandler.coords[1] or Coord.new()
    local lastCoord = plothandler.coords[#plothandler.coords] or Coord.new()
    local hasJumps
    local filteredCoordsAway
    if plothandler.plotHasJumps then hasJumps = 1 else hasJumps = 0 end
    if plothandler.filteredCoordsAway then filteredCoordsAway = 1 else filteredCoordsAway = 0 end

	-- FIXME : this could be rewritten by means of tex.spring("\\def\\macro{<value>}")
    local result = 
        axisLimitToTeXString("@xmin", self.min[1]) ..
        axisLimitToTeXString("@ymin", self.min[2]) ..
        axisLimitToTeXString("@zmin", self.min[3]) ..
        axisLimitToTeXString("@xmax", self.max[1]) ..
        axisLimitToTeXString("@ymax", self.max[2]) ..
        axisLimitToTeXString("@zmax", self.max[3]) ..
    -- FIXME : what about datamin/datamx!?
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
