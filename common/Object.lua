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

function Object:getClass()
  return getmetatable(self)
end

function Object:instanceOf(other)
  return instanceOf(self, other)
end
