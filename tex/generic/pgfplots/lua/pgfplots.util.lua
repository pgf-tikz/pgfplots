local math=math
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable
local io=io
local print=print
local pairs = pairs
local table=table

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
    result.__index = result
    local allocator= function (cls, ...)
        local self = setmetatable({}, cls)
        self:constructor(...)
        return self
    end
    setmetatable(result, { __call = allocator })
    return result
end



-- Create a new class that inherits from a base class 
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
