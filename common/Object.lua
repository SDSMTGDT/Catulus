require "common/functions"

Object = {}
Object.__index = Object

setmetatable(Object, {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end,
  })



--
-- Constructor
--
-- Initializes data members to defaults.
--
function Object:_init()
  -- Nothing else to do; optional default constructor
end



--
-- Gets the table used as the class definition for this object. More accurately,
-- retrieves the metatable of this table.
--
-- Return: class table of this object.
--
function Object:getClass()
  return getmetatable(self)
end



--
-- Determines if this object is an instance of the given object. Compares
-- metatables of the current object with that of the supplied object.
--
-- Return: `true` if this object is a subclass of the supplied object.
--
function Object:instanceOf(other)
  return instanceOf(self, other)
end
