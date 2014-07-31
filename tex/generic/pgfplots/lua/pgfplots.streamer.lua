-- Contains coordinate streamers, i.e. classes which generate coordinates and stream them to some output stream

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

CoordOutputStream = newClass()

function CoordOutputStream:constructor()
end

function CoordOutputStream:startStream()
end

-- @param pt an instance of Coord
function CoordOutputStream:coord(pt)
end

function CoordOutputStream:endStream()
end

-----------------------------------

SurveyCoordOutputStream = newClassExtends(CoordOutputStream)

function SurveyCoordOutputStream:constructor(targetPlothandler)
	if not targetPlothandler then error("arguments must not be nil") end
	self.plothandler=  targetPlothandler
end

function SurveyCoordOutputStream:coord(pt)
	self.plothandler:surveypoint(pt)
end

-------------

AddplotExpressionCoordinateGenerator = newClass()

function AddplotExpressionCoordinateGenerator:constructor(coordoutputstream, expressionsByDimension, domainMin, domainMax, samples, variableNames)
	if not coordoutputstream or not expressionsByDimension or not domainMin or not domainMax or not samples or not variableNames then error("arguments must not be nil") end
	if #variableNames ~= 2 then error("Expected 2 variableNames") end
	self.coordoutputstream = coordoutputstream
	self.is3d = #expressionsByDimension == 3
	self.expressions = expressionsByDimension
	self.domainMin = domainMin
	self.domainMax = domainMax
	self.samples = samples
	self.variableNames = variableNames
	
	io.write("initialized " .. tostring(self) )
end

-- @return true on success or false if the operation cannot be carried out.
function AddplotExpressionCoordinateGenerator:generateCoords()
	local coordoutputstream = self.coordoutputstream
	local is3d = self.is3d
	local expressions = self.expressions
	local xExpr = expressions[1]
	local yExpr = expressions[2]
	local zExpr = expressions[3]

	local domainMin = self.domainMin
	local domainMax = self.domainMax
	local samples = self.samples
	local h = {}
	for i = 1,#domainMin do
		h[i] = (domainMax[i] - domainMin[i]) / samples[i]
	end

	local variableNames = self.variableNames
	
	local x,y
	local sampleLine = #samples==1
	
	local function pseudoconstantx() return x end
	local pseudoconstanty
	if sampleLine then
		local didWarn = false
		pseudoconstanty = function()
			if not didWarn then
				io.write("Sorry, you can't use 'y' in this context. PGFPlots expected to sample a line, not a mesh. Please use the [mesh] option combined with [samples y>0] and [domain y!=0:0] to indicate a twodimensional input domain")
				didWarn = true
			end
			return 0
		end
	else
		pseudoconstanty = function() return y end
	end
	pgfluamathfunctions.stringToFunctionMap[variableNames[1]] = pseudoconstantx
	pgfluamathfunctions.stringToFunctionMap[variableNames[2]] = pseudoconstanty

	local prepareX
	if xExpr == variableNames[1] then
		prepareX = function() return x end
	else
		prepareX = function() return pgfluamathparser.pgfmathparse(xExpr) end
	end

	local prepareY
	if not sampleLine and yExpr == variableNames[2] then
		prepareY = function() return y end
	else
		prepareY = function() return pgfluamathparser.pgfmathparse(yExpr) end
	end

	local function computeXYZ()
		local X = prepareX()
		local Y = prepareY()
		local Z = nil
		if is3d then
			Z = pgfluamathparser.pgfmathparse(zExpr)
		end
		
		local pt = Coord.new()
		pt.x = { X, Y, Z}

		coordoutputstream:coord(pt)
	end
	
	if is3d then
		if not sampleLine then
			local xmin = domainMin[1]
			local ymin = domainMin[2]
			local hx = h[1]
			local hy = h[2]
			-- samples twodimensionally (a lattice):
			for j = 1,samples[2] do
				-- FIXME : pgfplots@plot@data@notify@next@y
				y = ymin + j*hy
				for i = 1,samples[1] do
					-- FIXME : pgfplots@plot@data@notify@next@x
					x = xmin + i*hx
					computeXYZ()
				end
				-- FIXME : \pgfplotsplothandlernotifyscanlinecomplete
			end
		else
			-- FIXME
			return false
		end
	else
		-- FIXME
		return false
	end
	
	pgfluamathfunctions.stringToFunctionMap[variableNames[1]] = nil
	pgfluamathfunctions.stringToFunctionMap[variableNames[2]] = nil
	return true
end

function AddplotExpressionCoordinateGenerator:__tostring()
	local result = "AddplotExpressionCoordinateGenerator[\n"
	result = result .. "\n  variable(s)=" .. self.variableNames[1] .. " " .. self.variableNames[2]
	result = result .. "\n  expressions="
	for i = 1,#self.expressions do
		result = result .. self.expressions[i] ..", "
	end
	result = result .. "\n  domain=" .. self.domainMin[1] .. ":" .. self.domainMax[1]
	result = result .. "\n  samples=" .. self.samples[1] 
	if #self.domainMin == 2 then
		result = result .. "\n  domain y=" .. self.domainMin[2] .. ":" .. self.domainMax[2]
	result = result .. "\n  samples y=" .. self.samples[2] 
	end
	result = result .. "]"
	return result
end

end
