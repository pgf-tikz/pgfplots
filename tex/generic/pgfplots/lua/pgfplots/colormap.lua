--
-- This file contains parts of pgfplotscolormap.code.tex
--

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

local pgftonumber = pgfluamathfunctions.tonumber
-----------------------------------

ColorSpace = newClass()
function ColorSpace:constructor(numComponents)
	self.numComponents=numComponents
end

rgb = ColorSpace.new(3)
cmyk = ColorSpace.new(4)
gray = ColorSpace.new(1)


ColorMap = newClass()

ColorMap.range =1000

-- h: mesh width between adjacent values
-- colorspace: an instance of ColorSpace
-- values: an array (1-based table) with color components. Each color component is supposed to be a table with K entries where K is colorspace:numComponents
-- positions: either an empty array (in which case the colormap is uniform) or one position per value. Positions are in [0,1000]
-- scaleOrderZ the specific scaling factor used for 'colormap access=const' (or negative or the empty string if this is disabled)
function ColorMap:constructor( h, colorspace, values, positions, scaleOrderZ)
	if not h or not colorspace or not positions or not values then error("arguments must not be nil")end

	self.name = name
	self.h = h
	self.invh = 1/h
	self.colorspace = colorspace
	self.values = values
	self.pos = positions
	self:setScaleOrderZ(scaleOrderZ)

	local numComponents = self.colorspace.numComponents
	for i = 1,#self.values do
		local value = self.values[i]
		if #value ~= numComponents then
			error("Some value has an unexpected number of color components, expected " .. self.colorspace.numComponents .. " but was ".. #value);
		end
	end
end

function ColorMap:isUniform()
	if #self.pos == 0 then
		return true
	else
		return false
	end
end

function ColorMap:setScaleOrderZ(scaleOrderZ)
	if type(scaleOrderZ) == "number" then
		self.scaleOrderZ = scaleOrderZ
	elseif #scaleOrderZ == 0 or type(scaleOrderZ) == "string" and scaleOrderZ == "h" then
		-- special case which means "h"
		self.scaleOrderZ = "h"
	else
		self.scaleOrderZ = pgftonumber(scaleOrderZ)
	end
end

function ColorMap:_transform(inMin, inMax, x)
	local transformed
	if inMin == 0 and inMax == ColorMap.range then
		transformed = x
	else
		local scale = ColorMap.range / (inMax - inMin)

		transformed = (x - inMin) * scale
	end
	transformed = math.max(0, transformed)
	transformed = math.min(ColorMap.range, transformed)
	return transformed
end

function ColorMap:findPrecomputed(inMin, inMax, x)
	local transformed = self:_transform(inMin, inMax, x)

	local divh = transformed * self.invh
	local intervalno = math.floor(divh)
	local factor = divh - intervalno
	local factor_two = 1-factor


	-- Step 2: interpolate the desired RGB value using vector valued interpolation on the identified interval
	if intervalno+1 == #self.values then
		-- ah- we are at the right end!
		return self.values[#self.values]
	end

	local left = self.values[intervalno+1]
	local right = self.values[intervalno+2]
	if not left or not right then error("Internal error: the color map does not have enough values for interval no " .. intervalno )end

	local result = {}
	for i = 1,self.colorspace.numComponents do
		local result_i = factor_two * left[i] + factor * right[i]

		result[i] = result_i
	end

	return result
end

function ColorMap:findPiecewiseConst(inMin, inMax, x)
	-- see docs in \pgfplotscolormapfindpiecewiseconst@precomputed@ for details

	local transformed = self:_transform(inMin, inMax, x)
	local intervalno =-1
	if self:isUniform() then
		if self.scaleOrderZ == "h" then
			invh = self.invh + 0.001
		else
			-- disable the extra interval
			invh = self.invh
		end

		local divh = transformed * invh
		intervalno = math.floor(divh)
	else
	 	-- FIXME : IMPLEMENT
	end

	if intervalno+1 == #self.values then
		-- we have artificially increased the "h" (see the comments
		-- above) -- meaning that this 'if' can happen.
		-- ->Map the rightmost point to the rightmost interval:
		return self.values[#self.values]
	end
	return self.values[intervalno+1]
end

-----------------------------------

-- global registry of all colormaps.
-- Key: colormap name
-- Value: an instance of ColorMap
ColorMaps = {}

end
