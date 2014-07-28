local math=math
local string=string
local type=type
local tostring = tostring
local tonumber = tonumber
local setmetatable = setmetatable
local getmetatable = getmetatable
local io=io
local print=print
local pairs = pairs
local table=table

do
local _ENV = pgfplots
---------------------------------------
--

function stringOrDefault(str, default)
    if str == nil or type(str) == 'string' and string.len(str) == 0 then
        return default
    end
    return tostring(str)
end


pgfplotsmath = {}

function pgfplotsmath.isfinite(x)
    if pgfplotsmath.isnan(x) or x == pgfplotsmath.infty or x == -pgfplotsmath.infty then
        return false
    end
    return true
end

function pgfplotsmath.isnan(x)
    return x ~= x
end

pgfplotsmath.infty = 1/0

pgfplotsmath.nan = math.sqrt(-1)

-- like tonumber(x), but it also accepts nan, inf, infty, and the TeX FPU format
function pgfplotsmath.tonumber(x)
    if type(x) == 'number' then return x end
    if not x then return x end
    
    local len = string.len(x)
    local result = tonumber(x)
    if not result then 
        if len >2 and string.sub(x,2,2) == 'Y' and string.sub(x,len,len) == ']' then
            -- Ah - some TeX FPU input of the form 1Y1.0e3] . OK. transform it
            local flag = string.sub(x,1,1)
            if flag == '0' then
                -- ah, 0.0
                result = 0.0
            elseif flag == '1' then
                result = tonumber(string.sub(x,3, len-1))
            elseif flag == '2' then
                result = tonumber("-" .. string.sub(x,3, len-1))
            elseif flag == '3' then
                result = pgfplotsmath.nan
            elseif flag == '4' then
                result = pgfplotsmath.infty
            elseif flag == '5' then
                result = -pgfplotsmath.infty
            end
        else
            local lower = x:tolower()
            if lower == 'nan' then 
                result = pgfplotsmath.nan
            elseif lower == 'inf' or lower == 'infty' then 
                result = pgfplotsmath.infty
            elseif lower == '-inf' or lower == '-infty' then 
                result = -pgfplotsmath.infty 
            end
        end
    end    

    return result
end

-- a helper function which has no catcode issues when communicating with TeX:
function pgfplotsmath.tostringfixed(x)
    return string.format("%f", x)
end

function pgfplotsmath.toTeXstring(x)
    local result = ""
    if x ~= nil then
        if x == pgfplotsmath.infty then result = "4Y0.0e0]"
        elseif x == -pgfplotsmath.infty then result = "5Y0.0e0]"
        elseif pgfplotsmath.isnan(x) then result = "3Y0.0e0]"
        elseif x == 0 then result = "0Y0.0e0]"
        else
            -- FIXME : this is too long. But I do NOT want to loose digits!
            -- -> get rid of trailing zeros...
            result = string.format("%.10e", x)
            if x > 0 then
                result = "1Y" .. result .. "]"
            else
                result = "2Y" .. result:sub(2) .. "]"
            end
        end
    end
    return result
end

--------------------------------------- 
--


-- Creates and returns a new class object.
--
-- Usage:
-- complexclass = newClass()
-- function complexclass:constructor()
--      self.re = 0
--      self.im = 0
-- end
--
-- instance = complexclass()
--
function newClass()
    local result = {}

	-- we need this such that *instances* (which will have 'result' as meta table)
	-- will "inherit" the class'es methods.
    result.__index = result
    local allocator= function (class, ...)
		-- class == result in all cases
        local self = setmetatable({}, result)
        self:constructor(...)
        return self
    end
    setmetatable(result, { __call = allocator })
    return result
end



-- Create a new class that inherits from a base class 
--
-- base = pgfplots.newClass()
-- function base:constructor()
-- 	self.variable= 'a'
-- 	end
--
-- 	sub = pgfplots.newClassExtents(base)
-- 	function sub:constructor()
-- 		-- call super constructor.
-- 		-- it is ABSOLUTELY CRUCIAL to use <baseclass>.constructor here - not :constructor!
-- 		base.constructor(self)
-- 	end
--
-- 	instance = base()
--
-- 	instance2 = sub()
--
-- @see newClass
function newClassExtents( baseClass )
    if not baseClass then error "baseClass must not be nil" end

    local new_class = newClass()

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    local mt = getmetatable(new_class)
    mt.__index = baseClass
    setmetatable(new_class,mt)

    return new_class
end


end
