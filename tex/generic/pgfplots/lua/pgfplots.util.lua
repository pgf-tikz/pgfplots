local math=math
local tostring = tostring
local setmetatable = setmetatable
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

-- Create a new class that inherits from a base class with a default constructor
--
function inheritsFrom( baseClass, constructor )

    -- The following lines are equivalent to the SimpleClass example:

    -- Create the table and metatable representing the class.
    local new_class = {}
    local class_mt = { __index = new_class }

    -- Note that this function uses class_mt as an upvalue, so every instance
    -- of the class will share the same metatable.
    --
    function new_class.new(...)
        local newinst = {}
        setmetatable( newinst, class_mt )
        constructor(newinst,...)
        return newinst
    end

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    return new_class
end


end
