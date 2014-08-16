local math=math
local string=string
local type=type
local tostring = tostring
local tonumber = tonumber
local setmetatable = setmetatable
local getmetatable = getmetatable
local print=print
local pairs = pairs
local table=table
local texio=texio

do
local _ENV = pgfplots
---------------------------------------
--

log=texio.write_nl

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

local isnan = function(x)
    return x ~= x
end

pgfplotsmath.isnan = isnan

local infty = 1/0
pgfplotsmath.infty = infty

local nan = math.sqrt(-1)
pgfplotsmath.nan = nan

local stringlen = string.len
local globaltonumber = tonumber
local stringsub=string.sub
local stringformat = string.format
local stringsub = string.sub

-- like tonumber(x), but it also accepts nan, inf, infty, and the TeX FPU format
function pgfplotsmath.tonumber(x)
    if type(x) == 'number' then return x end
    if not x then return x end
    
    local len = stringlen(x)
    local result = globaltonumber(x)
    if not result then 
        if len >2 and stringsub(x,2,2) == 'Y' and stringsub(x,len,len) == ']' then
            -- Ah - some TeX FPU input of the form 1Y1.0e3] . OK. transform it
            local flag = stringsub(x,1,1)
            if flag == '0' then
                -- ah, 0.0
                result = 0.0
            elseif flag == '1' then
                result = globaltonumber(stringsub(x,3, len-1))
            elseif flag == '2' then
                result = globaltonumber("-" .. stringsub(x,3, len-1))
            elseif flag == '3' then
                result = pgfplotsmath.nan
            elseif flag == '4' then
                result = pgfplotsmath.infty
            elseif flag == '5' then
                result = -pgfplotsmath.infty
            end
        else
            local lower = x:lower()
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
	if x == nil then
		return ""
	end

    return stringformat("%f", x)
end

-- this here is copied from the 'lua' experimental branch
-- +	self.tofixed = function(x)
-- +		local res = self.parsenumber(x)
-- +		-- printf is too stupid: I would like to have
-- +		-- 1. a fast method 
-- +		-- 2. a reliable method
-- +		-- 3. full precision of x
-- +		-- 4. a fixed point representation
-- +		-- the 'f' modifier has trailing zeros (stupid!)
-- +		-- the 'g' modified can switch to scientific notation (no-go!)
-- +		result = string.format("%.16f",res);
-- +		local periodOff = string.find(result, '.',1,true)
-- +		if periodOff ~= nil then
-- +			-- strip trailing zeros
-- +			local chars = { string.byte(result,1,#result) };
-- +			local lastNonZero = #chars
-- +			for i = #chars, periodOff, -1 do
-- +				if chars[i] ~= NULL_CHAR then lastNonZero=i; break; end
-- +			end
-- +			if lastNonZero == periodOff then
-- +				lastNonZero = lastNonZero-1
-- +			end
-- +			result = string.sub(result, 1, lastNonZero)
-- +		end
-- +		return result;
-- +	end


function pgfplotsmath.toTeXstring(x)
    local result = ""
    if x ~= nil then
        if x == infty then result = "4Y0.0e0]"
        elseif x == -infty then result = "5Y0.0e0]"
        elseif isnan(x) then result = "3Y0.0e0]"
        elseif x == 0 then result = "0Y0.0e0]"
        else
            -- FIXME : this is too long. But I do NOT want to loose digits!
            -- -> get rid of trailing zeros...
            result = stringformat("%.10e", x)
            if x > 0 then
                result = "1Y" .. result .. "]"
            else
                result = "2Y" .. stringsub(result,2) .. "]"
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
-- instance = complexclass.new()
--
function newClass()
    local result = {}

	-- we need this such that *instances* (which will have 'result' as meta table)
	-- will "inherit" the class'es methods.
    result.__index = result
    local allocator= function (...)
        local self = setmetatable({}, result)
        self:constructor(...)
        return self
    end
	result.new = allocator
    return result
end



-- Create a new class that inherits from a base class 
--
-- base = pgfplots.newClass()
-- function base:constructor()
-- 	self.variable= 'a'
-- 	end
--
-- 	sub = pgfplots.newClassExtends(base)
-- 	function sub:constructor()
-- 		-- call super constructor.
-- 		-- it is ABSOLUTELY CRUCIAL to use <baseclass>.constructor here - not :constructor!
-- 		base.constructor(self)
-- 	end
--
-- 	instance = base.new()
--
-- 	instance2 = sub.new()
--
-- @see newClass
function newClassExtends( baseClass )
    if not baseClass then error "baseClass must not be nil" end

    local new_class = newClass()

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    local mt = {} -- getmetatable(new_class)
    mt.__index = baseClass
    setmetatable(new_class,mt)

    return new_class
end


end
