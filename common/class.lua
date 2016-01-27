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
  
  if Object == nil then
    
    -- Define class as a new class with no superclass
    setmetatable(newClass, {
        __call = function(cls, ...)
          local self = setmetatable({}, cls)
          self:_init(...)
          return self
        end,
      })
  else
    
    -- Force all classes to inherit from Object if possible
    if superclass == nil then
      superclass = Object
    end
    
    -- Define class as a subclass of another class
    setmetatable(newClass, {
        __index = superclass,
        __metatable = superclass,
        __call = function(cls, ...)
          local self = setmetatable({}, cls)
          self:_init(...)
          return self
        end,
      })
  end
  
  return newClass
end
