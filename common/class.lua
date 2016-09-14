require "common/Object"
require "common/functions"

--
-- Builds a new class using the supplied table as a superclass..
-- If no superclass is provided, then the object will not extend
-- any other class.
--
function buildClass(superclass)
  if superclass ~= nil then
    assertType(superclass, "superclass", "table")
  end
  
  local newClass = {}
  newClass.__index = newClass
  
  -- Force all classes to inherit from Object if possible
  if superclass == nil then
    superclass = Object
  end
  
  local newMetatable = {
    __call = function(cls, ...)
      local self = setmetatable({}, cls)
      self:_init(...)
      return self
    end
  }
  
  if superclass ~= nil then
    newMetatable.__index = superclass
    newMetatable.__metatable = superclass
  end
  
  -- Define class as a subclass of another class
  setmetatable(newClass, newMetatable)
  
  -- Define any default static methods or fields
  newClass.superclass = superclass
  
  return newClass
end
